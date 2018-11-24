//
//  OpenInItermAction.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

class OpenInItermAction: ExtraApplicationActionable {
    
    var application: Application?
    
    let appBundleIdentifier = "com.googlecode.iterm2"
    
    let title = UIConstants.strings.extensionOpenInIterm
    
    required init(application: Application) {
        self.application = application
    }
    
    func perform() {
        if let url = application?.sandboxUrl {
            NSWorkspace.shared.openFile(url.path, withApplication: "iTerm")
        }
    }
    
}
