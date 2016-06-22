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
    func shouldOpenContainer(_ pair: DeviceApplicationPair)
    func shouldUninstallContianer(_ pair: DeviceApplicationPair)
}

@objc final class MenuManager: NSObject {
    
    let statusItem: NSStatusItem
    
    var watcher: DirectoryWatcher!
    
    var subWatchers: [DirectoryWatcher?]?
    
    var block: dispatch_cancelable_block_t?
    
    var delegate: MenuManagerDelegate?
    
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
            device.applications.forEach { app in
                let appMenuItem = submenu.addItem(withTitle: app.bundleDisplayName, action: #selector(appMenuItemClicked(_:)), keyEquivalent: "")
                appMenuItem.representedObject = DeviceApplicationPair(device: device, application: app)
                appMenuItem.target = self

                if let iconFile = app.iconFiles?.last,
                    bundle = Bundle(url: app.url) {
                    appMenuItem.image = bundle.image(forResource: iconFile)?.resize(size: NSSize(width: 32, height: 32))
                } else {
                    appMenuItem.image = NSImage(named: "DefaultAppIcon")
                }

                if (device.state == .Booted) {
                    let controlItem = submenu.addItem(withTitle: "Uninstall \(app.bundleDisplayName)", action: #selector(appMenuItemClicked(_:)), keyEquivalent: "")
                    controlItem.representedObject = DeviceApplicationPair(device: device, application: app)
                    controlItem.target = self

                    controlItem.isAlternate = true
                    controlItem.keyEquivalentModifierMask = NSEventModifierFlags.control
                }
                deviceMenuItem.submenu = submenu
            }
        }

        menu.addItem(NSMenuItem.separator())
        let quitMenu = menu.addItem(withTitle: "Quit", action: #selector(quitItemClicked(_:)), keyEquivalent: "q")
        quitMenu.target = self

        statusItem.menu = menu
    }

    private func buildWatcher() {
        watcher = DirectoryWatcher(in: URLHelper.deviceURL)
        watcher.completionCallback = {
            self.reloadWhenReady()
            self.buildSubWatchers()
        }
        do {
            try watcher.start()
        } catch {
            
        }
    }
    
    private func buildSubWatchers() {
        subWatchers?.forEach { $0?.stop() }
        do {
            let deviceDirectories = try FileManager.default().contentsOfDirectory(at: URLHelper.deviceURL as URL, includingPropertiesForKeys: FileInfo.prefetchedProperties, options: .skipsSubdirectoryDescendants)
            subWatchers = deviceDirectories.map(createSubWatcherForURL)
        } catch {
            
        }
    }
    
    private func createSubWatcherForURL(_ URL: Foundation.URL) -> DirectoryWatcher? {
        guard let info = FileInfo(URL: URL) where info.isDirectory else {
            return nil
        }
        let watcher = DirectoryWatcher(in: URL)
        watcher.completionCallback = { [weak self] in
            self?.reloadWhenReady()
        }
        do {
            try watcher.start()
        } catch {
            
        }
        return watcher
    }
    
    
    private func reloadWhenReady() {
        dispatch_cancel_block_t(self.block)
        self.block = dispatch_block_t(1) { [weak self] in
            self?.buildMenu()
        }
    }
    
    func quitItemClicked(_ sender: AnyObject) {
        delegate?.shouldQuitApp()
    }
    
    func appMenuItemClicked(_ sender: AnyObject) {
        if let pair = sender.representedObject as? DeviceApplicationPair {
            // if control click
            if let event = NSApp.currentEvent where event.modifierFlags.contains(.control) {
                delegate?.shouldUninstallContianer(pair)
                
                // rebuild menu
                self.buildMenu()
            }
            else {
                // open the app directory
                delegate?.shouldOpenContainer(pair)
            }
        }
    }
    
}
