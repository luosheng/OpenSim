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
    
    static func dialogOKCancel(_ question: String, text: String) -> Bool {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlertStyle.critical
        myPopup.addButton(withTitle: NSLocalizedString("OK", comment: ""))
        myPopup.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
        let res = myPopup.runModal()
        if res == NSAlertFirstButtonReturn {
            return true
        }
        return false
    }
    
    static func uninstall(_ application: Application) {
        let answer = dialogOKCancel(NSLocalizedString("Confirm Delete?", comment: ""), text: NSLocalizedString("Are you sure you want to delete \(application.bundleDisplayName) for \(application.device.fullName)", comment: ""))
        if answer {
            // delete the app
            _ = shell("/usr/bin/xcrun", arguments: ["simctl", "uninstall", application.device.UDID, application.bundleID])
        }
    }
    
    static func deviceList() -> [Device] {
        // extract json from xcrun simctl list -j devices
        // to get a list of devices
        
        var jsonString = shell("/usr/bin/xcrun", arguments: ["simctl", "list", "-j", "devices"]);
        jsonString = jsonString.replacingOccurrences(of: "\n", with: "")
        jsonString = jsonString.trimmingCharacters(in: CharacterSet.newlines)
        let data: Data = jsonString.data(using: String.Encoding.utf8)!
        
        // array of devices to return
        var mapping = [String: [Device]]()
        
        if let json = try? JSONSerialization.jsonObject(with: data, options:[]) as? [String: AnyObject] {
            if let osVersions = json?["devices"] as? [String:AnyObject] {
                
                // parse out only the iOS os
                // then parse through the devices for that OS
                let filtered = osVersions.filter { $0.0.contains("iOS") }
                
                for os in filtered {
                    // os.0 is iOS version ex "iOS 9.2"
                    // os.1 is an array of devices
                    
                    // devices array to build
                    // for sorting purposes
                    var iPhones = [Device]()
                    var iPads = [Device]()
                    var otherDevices = [Device]()
                    
                    for device in os.1 as! [[String:String]] {
                        let state = Device.State(rawValue: device["state"]!) ?? .Unknown
                        
                        let newDevice = Device(
                            UDID: device["udid"]!,
                            type: device["name"]!,
                            name: device["name"]!,
                            runtime: os.0,
                            state: state
                        )
                        
                        if (newDevice.name.hasPrefix("iPhone")) {
                            iPhones.append(newDevice)
                        }
                        else if (newDevice.name.hasPrefix("iPad")) {
                            iPads.append(newDevice)
                        }
                        else {
                            otherDevices.append(newDevice)
                        }
                    }
                    
                    let sortedDevices = iPhones.reversed() + iPads.reversed() + otherDevices
                    mapping[os.0] = sortedDevices.filter { $0.applications?.count ?? 0 > 0 }.map { $0 }
                }
            }
        }
        var deviceMapping = [Device]()

        // sort so it appears
        // in similar order that Xcode dispalys simulators
        
        // old iOS
        // oldest iPads
        // newest iPads
        // oldest iPhones
        // newer iPhones
        for str in mapping.keys.sorted() {
            if let map = mapping[str] {
                for dev:Device in map.reversed() {
                    deviceMapping.append(dev)
                }
            }
        }
        
        return deviceMapping
    }
}
