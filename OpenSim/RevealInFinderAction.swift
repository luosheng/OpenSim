//
//  RevealInFinderAction.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

final class RevealInFinderAction: ApplicationActionable {
    
    var application: Application?
    
    let title = UIConstants.strings.actionRevealInFinder
    
    let icon = templatize(#imageLiteral(resourceName: "reveal"))
    
    let isAvailable: Bool = true
    
    init(application: Application) {
        self.application = application
    }
    
    func perform() {
        if let url = application?.sandboxUrl {
            NSWorkspace.shared.open(url)
        }
    }
    
}
