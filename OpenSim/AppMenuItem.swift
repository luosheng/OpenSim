//
//  AppMenuItem.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

class AppMenuItem: NSMenuItem {
    
    private weak var application: Application!
    
    init(application: Application) {
        self.application = application
        let title = "  \(application.bundleDisplayName)"
        super.init(title: title, action: nil, keyEquivalent: "")
        
        // Reverse the array to get the higher quality images first
        for iconFile in application.iconFiles.reversed() {
            if let bundle = Bundle(url: application.url) {
                self.image = bundle.image(forResource: iconFile)?.appIcon()
                if self.image != nil {
                    return
                }
            }
        }
        
        // Default image
        self.image = #imageLiteral(resourceName: "DefaultAppIcon").appIcon()
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
