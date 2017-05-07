//
//  RevealInFinderAction.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

final class RevealInFinderAction: ApplicationActionable {
    
    let title = NSLocalizedString("Reveal Sandbox in Finder", comment: "")
    
    let icon = templatize(#imageLiteral(resourceName: "reveal"))
    
    let isAvailable: Bool = true
    
    func perform(with application: Application) {
        if let url = application.sandboxUrl {
            NSWorkspace.shared().open(url)
        }
    }
    
}
