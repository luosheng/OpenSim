//
//  UninstallAction.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

final class UninstallAction: ApplicationActionable {
    
    let title = NSLocalizedString("Uninstall…", comment: "")
    
    let icon = templatize(#imageLiteral(resourceName: "uninstall"))
    
    let isAvailable = true
    
    func perform(with application: Application) {
        let alert: NSAlert = NSAlert()
        let alertFormat = "Are you sure you want to uninstall %1$@ from %1$@?"
        alert.messageText = String(format: NSLocalizedString(alertFormat, comment: ""), application.bundleDisplayName, application.device.name)
        alert.alertStyle = .critical
        alert.addButton(withTitle: NSLocalizedString("Uninstall", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
        let response = alert.runModal()
        if response == NSAlertFirstButtonReturn {
            application.uninstall()
        }
    }
    
}
