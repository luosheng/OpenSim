//
//  SimulatorController.swift
//  OpenSim
//
//  Created by Bradley Van Dyk on 6/20/16.
//  Copyright © 2016 Luo Sheng. All rights reserved.
//

import Foundation
import Cocoa

struct SimulatorController {
    
    static func uninstall(_ application: Application) {
        _ = shell("/usr/bin/xcrun", arguments: ["simctl", "uninstall", application.device.UDID, application.bundleID])
    }
    
    static func listDevices() -> [Runtime] {
        guard let jsonString = shell("/usr/bin/xcrun", arguments: ["simctl", "list", "-j", "devices"]),
            let data = jsonString.data(using: String.Encoding.utf8),
            let json = try? JSONSerialization.jsonObject(with: data, options:[]) as? [String: AnyObject],
            let devicesJson = json?["devices"] as? [String:AnyObject] else {
                return []
        }
        
        var runtimes = [Runtime]()
        for (runtimeName, deviceList) in devicesJson {
            let runtime = Runtime(name: runtimeName)
            if let deviceList = deviceList as? [[String:String]] {
                for deviceJson in deviceList {
                    if let state = deviceJson["state"],
                        let availability = deviceJson["availability"],
                        let name = deviceJson["name"],
                        let udid = deviceJson["udid"] {
                        let device = Device(udid: udid, type: name, name: name, state: state, availability: availability)
                        
                        if let apps = device.applications, apps.count > 0, device.availability == .available {
                            runtime.devices.append(device)
                        }
                    }
                }
            }
            runtimes.append(runtime)
        }
        
        let filteredRuntime = runtimes.filter { $0.name.contains("iOS") && $0.devices.count > 0 }
        
        return filteredRuntime
    }
}
