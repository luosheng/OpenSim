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
    
    static func boot(_ application: Application) {
        _ = shell("/usr/bin/xcrun", arguments: ["simctl", "boot", application.device.UDID])
    }

    static func listDevices(callback: @escaping ([Runtime]) -> ()) {
        getDevicesJson(currentAttempt: 0) { (jsonString) in
            guard let data = jsonString.data(using: String.Encoding.utf8),
            let json = try? JSONSerialization.jsonObject(with: data, options:[]) as? [String: AnyObject],
            let devicesJson = json?["devices"] as? [String:AnyObject] else {
                callback([])
                return
            }

            var runtimes = [Runtime]()
            devicesJson.forEach({ (runtimeName, deviceList) in
                let runtime = Runtime(name: runtimeName)
                if let deviceList = deviceList as? [[String:AnyObject]] {
                    for deviceJson in deviceList {
                        if let state = deviceJson["state"] as? String,
                            let availability = deviceJson["availability"] as? String,
                            let name = deviceJson["name"] as? String,
                            let udid = deviceJson["udid"] as? String {
                            let device = Device(udid: udid, type: name, name: name, state: state, availability: availability)

                            if device.availability == .available {
                                runtime.devices.append(device)
                            }
                            runtime.devices.sort(by: { (d1, d2) -> Bool in
                                return d1.name.compare(d2.name) == .orderedAscending
                            })
                        }
                    }
                }
                runtimes.append(runtime)
            })

            let filteredRuntime = runtimes.filter { $0.name.contains("iOS") && $0.devices.count > 0 }
            
            callback(filteredRuntime)
        }
    }

    private static let maxAttempt = 8

    private static func getDevicesJson(currentAttempt: Int, callback: @escaping (String) -> ()) {
        let jsonString = shell("/usr/bin/xcrun", arguments: ["simctl", "list", "-j", "devices"])
        if jsonString.count > 0 || currentAttempt >= maxAttempt {
            callback(jsonString)
            return
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            getDevicesJson(currentAttempt: currentAttempt + 1, callback: callback)
        }
    }
}
