//
//  AppDelegate.swift
//  OpenSimHelper
//
//  Created by Luo Sheng on 11/10/2016.
//  Copyright © 2016 Pop Tap. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let components = Bundle.main.bundleURL.pathComponents
        let path = NSString.path(withComponents: [String](components[0...components.count - 4]))
        NSWorkspace.shared().launchApplication(path)
        NSApp.terminate(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

