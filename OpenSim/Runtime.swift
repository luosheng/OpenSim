//
//  Runtime.swift
//  OpenSim
//
//  Created by Luo Sheng on 11/12/15.
//  Copyright © 2015 Luo Sheng. All rights reserved.
//

import Foundation

struct Runtime: CustomStringConvertible {
    
    let name: String
    
    var description: String {
        // current version is format "iOS major.minir"
        // old versions of iOS are com.Apple.CoreSimulator.SimRuntime.iOS-major-minor
        
        // current version, parse out iOS
        if name.hasPrefix("iOS ") {
            let index = name.startIndex.advancedBy(4)
            return name.substringFromIndex(index)
        }
        
        // older version parsing
        if let components = name.componentsSeparatedByString(".").last?.componentsSeparatedByString("-") {
            return components[1..<components.count].joinWithSeparator(".")
        }

        return name
    }
    
    init(name: String) {
        self.name = name
    }
    
}