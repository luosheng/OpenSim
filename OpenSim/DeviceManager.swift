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
        // extract json from xcrun simctl list -j devices
        // to get a list of devices
        
        var jsonString = shell("/usr/bin/xcrun", arguments: ["simctl", "list", "-j", "devices"]);
        jsonString = jsonString.stringByReplacingOccurrencesOfString("\n", withString: "")
        jsonString = jsonString.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
        let data: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        // array of devices to return
        var mapping = [String: [Device]]()
        
        do {
            if let json = try NSJSONSerialization.JSONObjectWithData(data, options:[]) as? [String: AnyObject] {
                if let osVersions = json["devices"] as? [String:AnyObject] {
                    
                    // parse out only the iOS os
                    // then parse through the devices for that OS
                    let filtered = osVersions.filter { $0.0.containsString("iOS") }
                    
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
                        
                        let sortedDevices = iPhones.reverse() + iPads.reverse() + otherDevices
                        mapping[os.0] = sortedDevices.filter { $0.applications.count > 0 }.map { $0 }
                    }
                }
            }
        }
        catch let parseError {
            print(parseError)
        }
        
        deviceMapping.removeAll()
        
        // sort so it appears
        // in similar order that Xcode dispalys simulators
        
        // old iOS
        // oldest iPads
        // newest iPads
        // oldest iPhones
        // newer iPhones
        for str in mapping.keys.sort() {
            if let map = mapping[str] {
                for dev:Device in map.reverse() {
                    deviceMapping.append(dev)
                }
            }
        }
    }
}