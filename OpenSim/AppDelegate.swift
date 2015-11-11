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
    var fileInfoList: [FileInfo?]!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        fileInfoList = buildFileInfoList()
        let timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "checkFileInfoList:", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        buildMenu()
    }
    
    private func buildFileInfoList() -> [FileInfo?] {
        return try! NSFileManager.defaultManager().contentsOfDirectoryAtURL(URLHelper.deviceURL, includingPropertiesForKeys: FileInfo.prefetchedProperties, options: .SkipsSubdirectoryDescendants).map { FileInfo(URL: $0) }
    }
    
    func checkFileInfoList(timer: NSTimer) {
        let newFileInfoList = buildFileInfoList()
        if fileInfoList != newFileInfoList {
            print("yes")
        }
        fileInfoList = newFileInfoList
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

