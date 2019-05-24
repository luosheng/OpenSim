//
//  SimulatorMenuItem.swift
//  OpenSim
//
//  Created by Benoit Jadinon on 16/05/2019.
//  Copyright © 2019 Luo Sheng. All rights reserved.
//

import Cocoa

class SimulatorMenuItem: NSMenuItem {

    var runtime: Runtime!
    var device: Device!
    
    init(runtime: Runtime, device:Device) {
        self.runtime = runtime
        self.device = device
        
        let title = "\(UIConstants.strings.menuLaunchSimulatorButton) \(device.name) (\(runtime))"
        
        super.init(title: title, action: #selector(self.openSimulator(_:)), keyEquivalent: "")
        
        target = self

        // Default image
        //self.image = #imageLiteral(resourceName: "DefaultAppIcon").appIcon()
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func openSimulator(_ sender: AnyObject) {
        self.device.launch()
    }
}
