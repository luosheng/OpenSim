//
//  AppDelegate.swift
//  SimPholders
//
//  Created by Luo Sheng on 11/9/15.
//  Copyright © 2015 Luo Sheng. All rights reserved.
//

import Cocoa
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, MenuManagerDelegate {

    @IBOutlet weak var window: NSWindow!
    
    var menuManager: MenuManager!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        menuManager = MenuManager()
        menuManager.delegate = self
        menuManager.start()
    }
    
    func shouldQuitApp() {
        NSApplication.shared().terminate(self)
    }
    
    func shouldOpenContainer(_ pair: DeviceApplicationPair) {
        guard let URL = pair.device.containerURLForApplication(pair.application),
            FileManager.default.fileExists(atPath: URL.path) else {
                return
        }
        
        NSWorkspace.shared().open(URL)
    }
    
    func shouldUninstallContianer(_ pair: DeviceApplicationPair) {
        SimulatorController.uninstall(pair)
    }

    func shouldEnableLoginAtStartup(enabled: Bool) {
        let appBundleId = "com.pop-tap.OpenSimHelper"
        SMLoginItemSetEnabled(appBundleId as CFString, enabled)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

