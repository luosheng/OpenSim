//
//  OpenInTerminalAction.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

final class OpenInTerminalAction: ApplicationActionable {
    
    var application: Application?
    
    let title = NSLocalizedString("Open Sandbox in Terminal", comment: "")
    
    let icon = templatize(#imageLiteral(resourceName: "terminal"))
    
    let isAvailable = true
    
    init(application: Application) {
        self.application = application
    }
    
    func perform() {
        if let url = application?.sandboxUrl {
            NSWorkspace.shared.openFile(url.path, withApplication: "Terminal")
        }
    }
    
}
