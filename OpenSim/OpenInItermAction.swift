//
//  OpenInItermAction.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

class OpenInItermAction: ExtraApplicationActionable {
    
    let appBundleIdentifier = "com.googlecode.iterm2"
    
    let title = NSLocalizedString("Open Sandbox in iTerm", comment: "")
    
    func perform(with application: Application) {
        if let url = application.sandboxUrl {
            NSWorkspace.shared().openFile(url.path, withApplication: "iTerm")
        }
    }
    
}
