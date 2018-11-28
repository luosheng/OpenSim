//
//  CopyToPasteboard.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

final class CopyToPasteboardAction: ApplicationActionable {
    
    var application: Application?
    
    let title = UIConstants.strings.actionCopyPathPasteboard
    
    let icon = templatize(#imageLiteral(resourceName: "share"))
    
    let isAvailable: Bool = true
    
    init(application: Application) {
        self.application = application
    }
    
    func perform() {
        if let url = application?.sandboxUrl {
            let pasteboard = NSPasteboard.general
            pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
            pasteboard.setString(url.path, forType: NSPasteboard.PasteboardType.string)
        }
    }
    
}
