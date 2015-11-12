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
        if let components = name.componentsSeparatedByString(".").last?.componentsSeparatedByString("-") {
            return components[1..<components.count].joinWithSeparator(".")
        }

        return name
    }
    
    init(name: String) {
        self.name = name
    }
    
}