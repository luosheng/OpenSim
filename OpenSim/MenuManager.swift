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
        
        DeviceManager.defaultManager.reload()

        var currentRuntime = ""
        DeviceManager.defaultManager.deviceMapping.forEach { device in
            if (currentRuntime != "" && device.runtime.name != currentRuntime) {
                menu.addItem(NSMenuItem.separator())
            }
            currentRuntime = device.runtime.name

            let deviceMenuItem = menu.addItem(withTitle: device.fullName, action: nil, keyEquivalent: "")
            deviceMenuItem.onStateImage = NSImage(named: "active")
            deviceMenuItem.offStateImage = NSImage(named: "inactive")
            deviceMenuItem.state = device.state == .Booted ? NSOnState : NSOffState

            let submenu = NSMenu()
            submenu.delegate = self
            device.applications.forEach { app in
                let appMenuItem = AppMenuItem(application: app)
                appMenuItem.submenu = ActionMenu(device: device, application: app)
                submenu.addItem(appMenuItem)
            }
            deviceMenuItem.submenu = submenu
        }

        menu.addItem(NSMenuItem.separator())

        let refreshMenuItem = menu.addItem(withTitle: NSLocalizedString("Refresh", comment: ""), action: #selector(refreshItemClicked(_:)), keyEquivalent: "r")
        refreshMenuItem.target = self
        
        let launchAtLoginMenuItem = menu.addItem(withTitle: NSLocalizedString("Launch at Login", comment: ""), action: #selector(launchItemClicked(_:)), keyEquivalent: "")
        launchAtLoginMenuItem.target = self
        if existingItem(itemUrl: Bundle.main.bundleURL) != nil {
            launchAtLoginMenuItem.state = NSOnState
        } else {
            launchAtLoginMenuItem.state = NSOffState
        }

        let quitMenu = menu.addItem(withTitle: NSLocalizedString("Quit", comment: ""), action: #selector(quitItemClicked(_:)), keyEquivalent: "q")
        quitMenu.target = self

        statusItem.menu = menu
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

    // MARK: - NSMenuDelegate

    func menuWillOpen(_ menu: NSMenu) {
        menuObserver =  CFRunLoopObserverCreateWithHandler(nil, CFRunLoopActivity.beforeWaiting.rawValue, true, 0) { (observer, activity) in
            if let view = menu.highlightedItem?.view as? ModifyFlagsResponsive {
                view.processModifyFlags(flags: NSEvent.modifierFlags())
            }
        }
        CFRunLoopAddObserver(CFRunLoopGetCurrent(), menuObserver, CFRunLoopMode.commonModes)
    }

    func menuDidClose(_ menu: NSMenu) {
        if let menuObserver = menuObserver {
            CFRunLoopObserverInvalidate(menuObserver)
            self.menuObserver = nil
        }
    }
    
}
