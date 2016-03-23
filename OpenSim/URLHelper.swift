//
//  DeviceHelper.swift
//  SimPholders
//
//  Created by Luo Sheng on 11/9/15.
//  Copyright © 2015 Luo Sheng. All rights reserved.
//

import Foundation

struct URLHelper {
    
    static let devicesPathComponent = "Developer/CoreSimulator/Devices/"
    static let applicationStatesComponent = "data/Library/FrontBoard/applicationState.plist"
    static let containersComponent = "data/Containers/Data/Application"
    
    static let deviceSetFileName = "device_set.plist"
    static let deviceFileName = "device.plist"
    
    static var deviceURL: NSURL {
        get {
            guard let libraryPath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true).first else {
                return NSURL()
            }
            return NSURL(fileURLWithPath: libraryPath).URLByAppendingPathComponent(devicesPathComponent)
        }
    }
    
    static var deviceSetURL: NSURL {
        return self.deviceURL.URLByAppendingPathComponent(deviceSetFileName)
    }
    
    static func deviceURLForUDID(UDID: String) -> NSURL {
        return deviceURL.URLByAppendingPathComponent(UDID)
    }
    
    static func applicationStateURLForUDID(UDID: String) -> NSURL {
        return deviceURLForUDID(UDID).URLByAppendingPathComponent(applicationStatesComponent)
    }
    
    static func containersURLForUDID(UDID: String) -> NSURL {
        return deviceURLForUDID(UDID).URLByAppendingPathComponent(containersComponent, isDirectory: true)
    }
    
}