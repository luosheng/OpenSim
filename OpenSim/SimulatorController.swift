//
//  SimulatorController.swift
//  OpenSim
//
//  Created by Bradley Van Dyk on 6/20/16.
//  Copyright © 2016 Luo Sheng. All rights reserved.
//

import Foundation
import Cocoa

class SimulatorController: NSObject {
    
    static func dialogOKCancel(question: String, text: String) -> Bool {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlertStyle.CriticalAlertStyle
        myPopup.addButtonWithTitle("OK")
        myPopup.addButtonWithTitle("Cancel")
        let res = myPopup.runModal()
        if res == NSAlertFirstButtonReturn {
            return true
        }
        return false
    }
    
    static func uninstall(pair:DeviceApplicationPair) {
        let answer = dialogOKCancel("Confirm Delete?", text: "Are you sure you want to delete \(pair.application.bundleDisplayName) for \(pair.device.fullName)")
        if answer {
            // delete the app
            shell("/usr/bin/xcrun", arguments: ["simctl", "uninstall", pair.device.UDID, pair.application.bundleID])
            
            // rebuild menu
//            self.buildMenu()
        }
    }
}
