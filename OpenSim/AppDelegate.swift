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

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        buildMenu()
    }
    
    func buildMenu() {
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        statusItem.image = NSImage(named: "menubar")
        statusItem.image!.template = true
        
        statusItem.menu = NSMenu()
        
        let iOSDevices = DeviceManager.defaultManager.deviceMapping.filter { $0.0.containsString("iOS") }.flatMap { $0.1 }
        iOSDevices.forEach { device in
            let deviceMenuItem = statusItem.menu?.addItemWithTitle("\(device.name) (\(device.state))", action: nil, keyEquivalent: "")
            deviceMenuItem?.submenu = NSMenu()
            device.applications.forEach { app in
                let appMenuItem = deviceMenuItem?.submenu?.addItemWithTitle(app.bundleDisplayName, action: "appMenuItemClicked:", keyEquivalent: "")
                appMenuItem?.representedObject = DeviceApplicationPair(device: device, application: app)
            }
        }
        
        statusItem.menu!.addItem(NSMenuItem.separatorItem())
        statusItem.menu!.addItemWithTitle("Quit", action: "quit", keyEquivalent: "")
    }
    
    func quit() {
        NSApplication.sharedApplication().terminate(self)
    }
    
    func appMenuItemClicked(sender: NSMenuItem) {
        if let pair = sender.representedObject as? DeviceApplicationPair {
            if let appState = pair.device.applicationStates[pair.application.bundleID] {
                NSWorkspace.sharedWorkspace().openURL(NSURL(fileURLWithPath: appState.sandboxPath))
            }
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

