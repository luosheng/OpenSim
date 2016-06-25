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
    var iconView: NSImageView!
    var nameLabel: NSTextField!
    
    init(app: Application) {
        application = app
        super.init(frame: NSRect(x: 0, y: 0, width: 220, height: 50))
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        iconView = NSImageView(frame: NSRect(x: 20, y: 9, width: 32, height: 32))
        if let iconFile = application.iconFiles?.last,
            bundle = Bundle(url: application.url) {
            iconView.image = bundle.image(forResource: iconFile)?.appIcon()
        } else {
            iconView.image = NSImage(named: "DefaultAppIcon")?.appIcon()
        }
        addSubview(iconView)
        
        nameLabel = createLabel()
        nameLabel.font = NSFont.systemFont(ofSize: 11)
        nameLabel.frame = NSRect(x: 62, y: 32, width: 148, height: 12)
        nameLabel.stringValue = application.bundleDisplayName
        addSubview(nameLabel)
    }
    
    private func createLabel() -> NSTextField {
        let label = NSTextField()
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = false
        return label
    }
    
}
