//
//  SimulatorShutdownMenuItem.swift
//  OpenSim
//
//  Created by Craig Peebles on 14/10/19.
//  Copyright © 2019 Luo Sheng. All rights reserved.
//

import Cocoa

class SimulatorShutdownMenuItem: NSMenuItem {

    var device: Device!

    init(device:Device) {
        self.device = device

        let title = "\(UIConstants.strings.menuShutdownSimulatorButton) \(device.name)"

        super.init(title: title, action: #selector(self.shutdownSimulator(_:)), keyEquivalent: "")

        target = self
    }

    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func shutdownSimulator(_ sender: AnyObject) {
        device.shutDown()
    }
}

