//
//  ActionMenu.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

final class ActionMenu: NSMenu {
    
    weak var device: Device?
    weak var application: Application?
    
    init(device: Device, application: Application) {
        self.device = device
        self.application = application
        super.init(title: "")
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
