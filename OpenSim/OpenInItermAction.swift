//
//  OpenInItermAction.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

class OpenInItermAction: ApplicationActionable {
    
    private let iTermPath = NSWorkspace.shared().absolutePathForApplication(withBundleIdentifier: "com.googlecode.iterm2")
    
    let title = NSLocalizedString("Open Sandbox in iTerm", comment: "")
    
    var icon: NSImage? {
        guard let path = iTermPath else {
            return nil
        }
        
        let image = NSWorkspace.shared().icon(forFile: path)
        image.size = NSSize(width: 16, height: 16)
        return image
    }
    
    var isAvailable: Bool {
        return iTermPath != nil
    }
    
    func perform(with application: Application) {
        if let url = application.sandboxUrl {
            NSWorkspace.shared().openFile(url.path, withApplication: "iTerm")
        }
    }
    
}
