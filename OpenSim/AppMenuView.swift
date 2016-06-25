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
    
    init(app: Application) {
        application = app
        super.init(frame: NSRect(x: 0, y: 0, width: 220, height: 50))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
