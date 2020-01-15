//
//  Runtime.swift
//  OpenSim
//
//  Created by Luo Sheng on 11/12/15.
//  Copyright © 2015 Luo Sheng. All rights reserved.
//

import Foundation

struct Runtime: Decodable {
    public let name: String
    public let devices: [Device]
}

extension Runtime: CustomStringConvertible {
    var description: String {
        // current version is format "iOS major.minir"
        // old versions of iOS are com.Apple.CoreSimulator.SimRuntime.iOS-major-minor
        
        let characterSet = CharacterSet(charactersIn: " -.")
        let components = name.components(separatedBy: characterSet)
        
        guard components.count > 2 else {
            return name
        }
        
        return "\(components[components.count - 3]) \(components[components.count - 2]).\(components[components.count - 1])"
    }
    
    var platform: String {
        return String(description.split(separator: " ").first ?? "")
    }
    
    var version: Float? {
        let versionString = String(description.split(separator: " ").last ?? "")
        return Float(versionString)
    }
}
