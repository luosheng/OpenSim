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
    
    static let shared = SimulatorController()
    
    private let activeDeveloperPath: String
    
    init() {
        activeDeveloperPath = shell("/usr/bin/xcode-select", arguments: ["-p"]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func uninstall(_ application: Application) {
        _ = shell("\(activeDeveloperPath)/usr/bin/simctl", arguments: ["uninstall", application.device.UDID, application.bundleID])
    }
    
    func boot(_ application: Application) {
        _ = shell("\(activeDeveloperPath)/usr/bin/simctl", arguments: ["boot", application.device.UDID])
    }

    func listDevices(callback: @escaping ([Runtime]) -> ()) {
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
                if let deviceList = deviceList as? [[String:String]] {
                    for deviceJson in deviceList {
                        if let state = deviceJson["state"],
                            let availability = deviceJson["availability"],
                            let name = deviceJson["name"],
                            let udid = deviceJson["udid"] {
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

    private let maxAttempt = 8

    private func getDevicesJson(currentAttempt: Int, callback: @escaping (String) -> ()) {
        let jsonString = shell("\(activeDeveloperPath)/usr/bin/simctl", arguments: ["list", "-j", "devices"])
        if !jsonString.isEmpty || currentAttempt >= maxAttempt {
            callback(jsonString)
            return
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            self.getDevicesJson(currentAttempt: currentAttempt + 1, callback: callback)
        }
    }
}
