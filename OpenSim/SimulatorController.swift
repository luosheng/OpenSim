//
//  SimulatorController.swift
//  OpenSim
//
//  Created by Bradley Van Dyk on 6/20/16.
//  Copyright © 2016 Luo Sheng. All rights reserved.
//

import Foundation
import Cocoa
import FBSimulatorControl

private func shell(_ launchPath: String, arguments: [String]) -> String {
    let progress = Process()
    progress.launchPath = launchPath
    progress.arguments = arguments
    
    let pipe = Pipe()
    progress.standardOutput = pipe
    progress.standardError = Pipe()
    progress.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: String.Encoding.utf8)
    
    return output ?? ""
}

struct SimulatorController {
    
    static let shared = SimulatorController()
    
    private let activeDeveloperPath: String
    
    private func simctl(_ arguments: String...) -> String {
        return shell("\(activeDeveloperPath)/usr/bin/simctl", arguments: arguments)
    }
    
    private let control :FBSimulatorControl?
    
    init() {
        activeDeveloperPath = shell("/usr/bin/xcode-select", arguments: ["-p"]).trimmingCharacters(in: .whitespacesAndNewlines)
        let options = FBSimulatorManagementOptions()
        let config = FBSimulatorControlConfiguration(deviceSetPath: nil, options: options)
        let logger = FBControlCoreGlobalConfiguration.defaultLogger
        control = try? FBSimulatorControl.withConfiguration(config, logger: logger)
    }
    
    func uninstall(_ application: Application) {
        _ = simctl("uninstall", application.device.UDID, application.bundleID)
    }
    
    func boot(_ application: Application) {
        _ = simctl("boot", application.device.UDID)
    }

    func listDevices(callback: ([Runtime]) -> ()) {
        var runtimes = [String:Runtime]()
        control?.set.allSimulators.forEach({ (simulator) in
            let name = "\(simulator.osVersion.name)"
            let runtime = runtimes[name] ?? Runtime(name: name)
            runtimes[name] = runtime
            let device = Device(udid: simulator.udid, type: "", name: simulator.name, state: "", availability: "available")
            runtime.devices.append(device)
        })
        var result = [Runtime]()
        runtimes.forEach { (_, runtime) in
            result.append(runtime)
        }
        callback(result)
    }
}
