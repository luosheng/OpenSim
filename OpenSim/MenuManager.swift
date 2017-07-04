//
//  MenuManager.swift
//  OpenSim
//
//  Created by Luo Sheng on 16/3/24.
//  Copyright © 2016年 Luo Sheng. All rights reserved.
//

import Foundation
import Cocoa

protocol MenuManagerDelegate {
    func shouldQuitApp()
}

@objc final class MenuManager: NSObject, NSMenuDelegate {
    
    let statusItem: NSStatusItem
    
    var watcher: DirectoryWatcher!
    
    var subWatchers: [DirectoryWatcher?]?
    
    var block: dispatch_cancelable_block_t?
    
    var delegate: MenuManagerDelegate?

    var menuObserver: CFRunLoopObserver?
    
    override init() {
        statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        statusItem.image = NSImage(named: "menubar")
        statusItem.image!.isTemplate = true
        
        super.init()
        
        buildMenu()
    }
    
    deinit {
        stop()
    }
    
    func start() {
        buildWatcher()
        buildSubWatchers()
    }
    
    func stop() {
        watcher.stop()
        subWatchers?.forEach { $0?.stop() }
    }
    
    private func buildMenu() {
        let menu = NSMenu()
        
        DeviceManager.defaultManager.reload { (runtimes) in
            runtimes.forEach { (runtime) in
                let devices = runtime.devices.filter { $0.applications?.count ?? 0 > 0 }
                if devices.count == 0 {
                    return
                }
                menu.addItem(NSMenuItem.separator())
                let titleItem = NSMenuItem(title: "\(runtime) Simulators", action: nil, keyEquivalent: "")
                titleItem.isEnabled = false
                menu.addItem(titleItem)

                devices.forEach({ (device) in
                    let deviceMenuItem = menu.addItem(withTitle: device.fullName, action: nil, keyEquivalent: "")
                    deviceMenuItem.onStateImage = NSImage(named: "active")
                    deviceMenuItem.offStateImage = NSImage(named: "inactive")
                    deviceMenuItem.state = device.state == .Booted ? NSOnState : NSOffState

                    let submenu = NSMenu()
                    submenu.delegate = self
                    device.applications?.forEach { app in
                        let appMenuItem = AppMenuItem(application: app)
                        appMenuItem.submenu = ActionMenu(device: device, application: app)
                        submenu.addItem(appMenuItem)
                    }
                    deviceMenuItem.submenu = submenu
                })

            }

            menu.addItem(NSMenuItem.separator())

            let refreshMenuItem = menu.addItem(withTitle: NSLocalizedString("Refresh", comment: ""), action: #selector(self.refreshItemClicked(_:)), keyEquivalent: "r")
            refreshMenuItem.target = self

            let launchAtLoginMenuItem = menu.addItem(withTitle: NSLocalizedString("Launch at Login", comment: ""), action: #selector(self.launchItemClicked(_:)), keyEquivalent: "")
            launchAtLoginMenuItem.target = self
            if existingItem(itemUrl: Bundle.main.bundleURL) != nil {
                launchAtLoginMenuItem.state = NSOnState
            } else {
                launchAtLoginMenuItem.state = NSOffState
            }

            let quitMenu = menu.addItem(withTitle: NSLocalizedString("Quit", comment: ""), action: #selector(self.quitItemClicked(_:)), keyEquivalent: "q")
            quitMenu.target = self
            
            self.statusItem.menu = menu
        }
    }

    private func buildWatcher() {
        watcher = DirectoryWatcher(in: URLHelper.deviceURL)
        watcher.completionCallback = { [weak self] in
            self?.reloadWhenReady()
            self?.buildSubWatchers()
        }
        try? watcher.start()
    }
    
    private func buildSubWatchers() {
        subWatchers?.forEach { $0?.stop() }
        let deviceDirectories = try? FileManager.default.contentsOfDirectory(at: URLHelper.deviceURL as URL, includingPropertiesForKeys: FileInfo.prefetchedProperties, options: .skipsSubdirectoryDescendants)
        subWatchers = deviceDirectories?.map(createSubWatcherForURL)
    }
    
    private func createSubWatcherForURL(_ URL: Foundation.URL) -> DirectoryWatcher? {
        guard let info = FileInfo(URL: URL), info.isDirectory else {
            return nil
        }
        let watcher = DirectoryWatcher(in: URL)
        watcher.completionCallback = { [weak self] in
            self?.reloadWhenReady()
        }
        try? watcher.start()
        return watcher
    }
    
    
    private func reloadWhenReady() {
        dispatch_cancel_block_t(self.block)
        self.block = dispatch_block_t(1) { [weak self] in
            self?.watcher.stop()
            self?.buildMenu()
            try? self?.watcher.start()
        }
    }
    
    func quitItemClicked(_ sender: AnyObject) {
        delegate?.shouldQuitApp()
    }

    func refreshItemClicked(_ sender: AnyObject) {
        reloadWhenReady()
    }
    
    func launchItemClicked(_ sender: NSMenuItem) {
        let wasOn = sender.state == NSOnState
        sender.state = (wasOn ? NSOffState : NSOnState)
        setLaunchAtLogin(itemUrl: Bundle.main.bundleURL, enabled: !wasOn)
    }
    
}
