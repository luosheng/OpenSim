//
//  ExtraApplicationActionable.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

protocol ExtraApplicationActionable: ApplicationActionable {
    
    var appBundleIdentifier: String { get }
    
}

extension ExtraApplicationActionable {
    
    var appPath: String? {
        return NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: appBundleIdentifier)
    }
    
    var icon: NSImage? {
        return appPath.flatMap { (path) -> NSImage? in
            let image = NSWorkspace.shared.icon(forFile: path)
            image.size = NSSize(width: 16, height: 16)
            return image
        }
    }
    
    var isAvailable: Bool {
        return appPath != nil
    }
    
}
