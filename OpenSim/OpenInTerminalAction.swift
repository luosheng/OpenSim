//
//  OpenInTerminalAction.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

final class OpenInTerminalAction: ApplicationActionable {
    
    let title: String = NSLocalizedString("Open Sandbox in Terminal", comment: "")
    
    let icon: NSImage = templatize(#imageLiteral(resourceName: "terminal"))
    
    let isAvailable: Bool = true
    
    func perform(with application: Application) {
        if let url = application.sandboxUrl {
            NSWorkspace.shared().openFile(url.path, withApplication: "Terminal")
        }
    }
    
}
