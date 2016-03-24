//
//  AppDelegate.swift
//  SimPholders
//
//  Created by Luo Sheng on 11/9/15.
//  Copyright © 2015 Luo Sheng. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    var statusItem: NSStatusItem!
    var watcher: DirectoryWatcher!
    var subWatchers: [DirectoryWatcher?]?
    var block: dispatch_cancelable_block_t?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        statusItem.image = NSImage(named: "menubar")
        statusItem.image!.template = true
        statusItem.menu = NSMenu()
        
        buildMenu()
        
        watcher = DirectoryWatcher(URL: URLHelper.deviceURL)
        watcher.completionCallback = {
            self.reloadWhenReady()
            self.buildSubWatchers()
        }
        try! watcher.start()
        self.buildSubWatchers()
    }
    
    private func reloadWhenReady() {
        dispatch_cancel_block_t(self.block)
        self.block = dispatch_block_t(1) { [weak self] in
            self?.buildMenu()
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
    
    private func buildFileInfoList() -> [FileInfo?] {
        return try! NSFileManager.defaultManager().contentsOfDirectoryAtURL(URLHelper.deviceURL, includingPropertiesForKeys: FileInfo.prefetchedProperties, options: .SkipsSubdirectoryDescendants).map { FileInfo(URL: $0) }
    }
    
    func buildMenu() {
        statusItem.menu!.removeAllItems()
        
        // extract devices and sort based on runtime version so latest is on the bottom
        DeviceManager.defaultManager.reload()
        let iOSDevices = DeviceManager.defaultManager.deviceMapping

        var currentRuntime = ""
        iOSDevices.forEach { device in
            if (currentRuntime != "" && device.runtime.name != currentRuntime) {
                // add filler
                statusItem.menu?.addItemWithTitle("", action: nil, keyEquivalent: "")
            }
            
            currentRuntime = device.runtime.name
            
            let deviceMenuItem = statusItem.menu?.addItemWithTitle("\(device.name) (\(device.runtime))", action: nil, keyEquivalent: "")
            deviceMenuItem?.onStateImage = NSImage(named: "active")
            deviceMenuItem?.offStateImage = NSImage(named: "inactive")
            deviceMenuItem?.state = device.state == .Booted ? NSOnState : NSOffState
            deviceMenuItem?.submenu = NSMenu()
            device.applications.forEach { app in
                let appMenuItem = deviceMenuItem?.submenu?.addItemWithTitle(app.bundleDisplayName, action: #selector(appMenuItemClicked(_:)), keyEquivalent: "")
                appMenuItem?.representedObject = DeviceApplicationPair(device: device, application: app)
            }
        }
        
        statusItem.menu!.addItem(NSMenuItem.separatorItem())
        statusItem.menu!.addItemWithTitle("Quit", action: #selector(quit), keyEquivalent: "")
    }
    
    func quit() {
        NSApplication.sharedApplication().terminate(self)
    }
    
    func appMenuItemClicked(sender: NSMenuItem) {
        guard let pair = sender.representedObject as? DeviceApplicationPair,
            URL = pair.device.containerURLForApplication(pair.application),
            path = URL.path where NSFileManager.defaultManager().fileExistsAtPath(path) else {
            return
        }
        
        NSWorkspace.sharedWorkspace().openURL(URL)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

