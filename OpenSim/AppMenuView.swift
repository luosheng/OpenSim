//
//  AppMenuView.swift
//  OpenSim
//
//  Created by Luo Sheng on 16/6/25.
//  Copyright © 2016年 Luo Sheng. All rights reserved.
//

import Foundation
import Cocoa

class AppMenuView: NSView {
    
    let application: Application
    let iconView: NSImageView
    
    init(app: Application) {
        application = app
        iconView = NSImageView(frame: NSRect(x: 20, y: 9, width: 32, height: 32))
        super.init(frame: NSRect(x: 0, y: 0, width: 220, height: 50))
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(iconView)
        if let iconFile = application.iconFiles?.last,
            bundle = Bundle(url: application.url) {
            iconView.image = bundle.image(forResource: iconFile)?.appIcon()
        } else {
            iconView.image = NSImage(named: "DefaultAppIcon")?.appIcon()
        }
    }
    
}
