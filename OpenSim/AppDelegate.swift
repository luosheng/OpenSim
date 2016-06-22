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

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        menuManager = MenuManager()
        menuManager.delegate = self
        menuManager.start()
    }
    
    func shouldQuitApp() {
        NSApplication.sharedApplication().terminate(self)
    }
    
    func shouldOpenContainer(pair: DeviceApplicationPair) {
        guard let URL = pair.device.containerURLForApplication(pair.application),
            path = URL.path where NSFileManager.defaultManager().fileExistsAtPath(path) else {
                return
        }
        
        NSWorkspace.sharedWorkspace().openURL(URL)
    }
    
    func shouldUninstallContianer(pair: DeviceApplicationPair) {
        SimulatorController.uninstall(pair)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

