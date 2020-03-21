//
//  SimulatorResetMenuItem.swift
//  OpenSim
//
//  Created by Craig Peebles on 14/10/19.
//  Copyright © 2019 Luo Sheng. All rights reserved.
//

import Cocoa

class SimulatorResetMenuItem: NSMenuItem {

    var device: Device!

    init(device:Device) {
        self.device = device

        let title = "\(UIConstants.strings.menuResetSimulatorButton) \(device.name)"

        super.init(title: title, action: #selector(self.resetSimulator(_:)), keyEquivalent: "")

        target = self
    }

    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func resetSimulator(_ sender: AnyObject) {
        let alert: NSAlert = NSAlert()
        alert.messageText = String(format: UIConstants.strings.actionFactoryResetAlertMessage, device.name)
        alert.alertStyle = .critical
        alert.addButton(withTitle: UIConstants.strings.actionFactoryResetAlertConfirmButton)
        alert.addButton(withTitle: UIConstants.strings.actionFactoryResetAlertCancelButton)
        let response = alert.runModal()
        if response == NSApplication.ModalResponse.alertFirstButtonReturn {
            SimulatorController.factoryReset(device)
        }
    }
}
