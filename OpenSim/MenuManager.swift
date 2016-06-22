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
    func shouldOpenContainer(pair: DeviceApplicationPair)
    func shouldUninstallContianer(pair: DeviceApplicationPair)
}

@objc final class MenuManager: NSObject {
    
    let statusItem: NSStatusItem
    
    var watcher: DirectoryWatcher!
    
    var subWatchers: [DirectoryWatcher?]?
    
    var block: dispatch_cancelable_block_t?
    
    var delegate: MenuManagerDelegate?
    
    override init() {
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        statusItem.image = NSImage(named: "menubar")
        statusItem.image!.template = true
        
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
                menu.addItem(NSMenuItem.separatorItem())
            }
            currentRuntime = device.runtime.name
            
            if let deviceMenuItem = menu.addItemWithTitle(device.fullName, action: nil, keyEquivalent: "") {
                deviceMenuItem.onStateImage = NSImage(named: "active")
                deviceMenuItem.offStateImage = NSImage(named: "inactive")
                deviceMenuItem.state = device.state == .Booted ? NSOnState : NSOffState
                
                let submenu = NSMenu()
                device.applications.forEach { app in
                    if let appMenuItem = submenu.addItemWithTitle(app.bundleDisplayName, action: #selector(appMenuItemClicked(_:)), keyEquivalent: "") {
                        appMenuItem.representedObject = DeviceApplicationPair(device: device, application: app)
                        appMenuItem.target = self
                        
                        if (device.state == .Booted) {
                            if let controlItem = submenu.addItemWithTitle("Uninstall \(app.bundleDisplayName)", action: #selector(appMenuItemClicked(_:)), keyEquivalent: "") {
                                controlItem.representedObject = DeviceApplicationPair(device: device, application: app)
                                controlItem.target = self
                                
                                controlItem.alternate = true
                                controlItem.keyEquivalentModifierMask = Int(NSEventModifierFlags.ControlKeyMask.rawValue)
                            }
                        }
                    }
                    deviceMenuItem.submenu = submenu
                }
            }
        }
        
        menu.addItem(NSMenuItem.separatorItem())
        if let quitMenu = menu.addItemWithTitle("Quit", action: #selector(quitItemClicked(_:)), keyEquivalent: "q") {
            quitMenu.target = self
        }
        
        statusItem.menu = menu
    }
    
    private func buildWatcher() {
        watcher = DirectoryWatcher(URL: URLHelper.deviceURL)
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
            let deviceDirectories = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(URLHelper.deviceURL, includingPropertiesForKeys: FileInfo.prefetchedProperties, options: .SkipsSubdirectoryDescendants)
            subWatchers = deviceDirectories.map(createSubWatcherForURL)
        } catch {
            
        }
    }
    
    private func createSubWatcherForURL(URL: NSURL) -> DirectoryWatcher? {
        guard let info = FileInfo(URL: URL) where info.isDirectory else {
            return nil
        }
        let watcher = DirectoryWatcher(URL: URL)
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
    
    func quitItemClicked(sender: AnyObject) {
        delegate?.shouldQuitApp()
    }
    
    func appMenuItemClicked(sender: AnyObject) {
        if let pair = sender.representedObject as? DeviceApplicationPair {
            // if control click
            if let event = NSApp.currentEvent where event.modifierFlags.contains(.ControlKeyMask) {
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