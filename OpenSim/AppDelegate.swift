//
//  AppDelegate.swift
//  SimPholders
//
//  Created by Luo Sheng on 11/9/15.
//  Copyright © 2015 Luo Sheng. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, MenuManagerDelegate {

    @IBOutlet weak var window: NSWindow!
    
    var menuManager: MenuManager!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        menuManager = MenuManager()
        menuManager.delegate = self
        menuManager.start()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func shouldQuitApp() {
        NSApplication.shared.terminate(self)
    }

}

