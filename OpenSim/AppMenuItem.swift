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
        
        if let iconFile = application.iconFiles?.last,
            let bundle = Bundle(url: application.url) {
            self.image = bundle.image(forResource: iconFile)?.appIcon()
        } else {
            self.image = #imageLiteral(resourceName: "DefaultAppIcon").appIcon()
        }
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
