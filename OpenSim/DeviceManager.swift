//
//  DeviceMapping.swift
//  SimPholders
//
//  Created by Luo Sheng on 11/9/15.
//  Copyright © 2015 Luo Sheng. All rights reserved.
//

import Foundation

final class DeviceManager {
    
    static let devicesKey = "DefaultDevices"
    static let deviceRuntimePrefix = "com.apple.CoreSimulator.SimRuntime"
    
    static let defaultManager = DeviceManager()
    var deviceMapping = [Device]()
    
    func reload() {
        self.deviceMapping = SimulatorController.deviceList()
    }
}