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
    
    static func boot(_ application: Application) {
        _ = shell("/usr/bin/xcrun", arguments: ["simctl", "boot", application.device.UDID])
    }
    
    static func run(_ application: Application) {
        _ = shell("/usr/bin/open", arguments: ["-a", "Simulator"])
    }

    static func launch(_ application: Application) {
        _ = shell("/usr/bin/xcrun", arguments: ["simctl", "launch", application.device.UDID, application.bundleID])
    }
    
    static func uninstall(_ application: Application) {
        _ = shell("/usr/bin/xcrun", arguments: ["simctl", "uninstall", application.device.UDID, application.bundleID])
    }
    
    static func listDevices(callback: @escaping ([Runtime]) -> ()) {
        getDevicesJson(currentAttempt: 0) { (jsonString) in
            guard let data = jsonString.data(using: String.Encoding.utf8) else {
                callback([])
                return
            }
            do {
                let decoder = JSONDecoder()
                let simulator = try decoder.decode(Simulator.self, from: data)
                let filteredRuntime = simulator.runtimes.filter { $0.devices.count > 0 }
                callback(filteredRuntime)
            } catch {
                callback([])
            }
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
