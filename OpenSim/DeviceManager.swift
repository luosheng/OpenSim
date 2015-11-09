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
    var deviceMapping = [String: [Device]]()
    
    init() {
        reload()
    }
    
    func reload() {
        guard let devicesPlist = NSDictionary(contentsOfURL: URLHelper.deviceSetURL)?[DeviceManager.devicesKey] as? [String: AnyObject] else {
            return
        }
        let filteredDevice = devicesPlist.filter { (key, _) -> Bool in key.hasPrefix(DeviceManager.deviceRuntimePrefix) }
        var mapping = [String: [Device]]()
        filteredDevice.forEach { (key, value) -> () in
            if let deviceList = value as? [String: String] {
                let devices = deviceList.map { (_, UDID) -> Device? in
                    let URL = URLHelper.deviceURLForUDID(UDID).URLByAppendingPathComponent(URLHelper.deviceFileName)
                    guard let devicePlist = NSDictionary(contentsOfURL: URL),
                        UDID = devicePlist["UDID"] as? String,
                        type = devicePlist["deviceType"] as? String,
                        name = devicePlist["name"] as? String,
                        runtime = devicePlist["runtime"] as? String,
                        stateValue = devicePlist["state"] as? Int,
                        state = Device.State(rawValue: stateValue) else {
                            return nil
                    }
                    return Device(
                        UDID: UDID,
                        type: type,
                        name: name,
                        runtime: runtime,
                        state: state
                    )
                }
                mapping[key] = devices.filter { $0?.applications.count > 0 }.map { $0! }
            }
        }
        deviceMapping = mapping
    }
    
}