//
//  UninstallAction.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

final class UninstallAction: ApplicationActionable {
    
    var application: Application?
    
    let title = NSLocalizedString("Uninstall…", comment: "")
    
    let icon = templatize(#imageLiteral(resourceName: "uninstall"))
    
    let isAvailable = true
    
    init(application: Application) {
        self.application = application
    }
    
    func perform() {
        guard let application = application else {
            return
        }
        let alert: NSAlert = NSAlert()
        let alertFormat = "Are you sure you want to uninstall %1$@ from %1$@?"
        alert.messageText = String(format: NSLocalizedString(alertFormat, comment: ""), application.bundleDisplayName, application.device.name)
        alert.alertStyle = .critical
        alert.addButton(withTitle: NSLocalizedString("Uninstall", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
        let response = alert.runModal()
        if response == NSApplication.ModalResponse.alertFirstButtonReturn {
            application.uninstall()
        }
    }
    
}
