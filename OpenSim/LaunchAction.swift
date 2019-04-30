//
//  LaunchAction.swift
//  OpenSim
//
//  Created by Arthur da Paz on 30/04/19.
//  Copyright © 2019 Luo Sheng. All rights reserved.
//

import Cocoa

final class LaunchAction: ApplicationActionable {
    var application: Application?
    
    let title = UIConstants.strings.actionLaunch
    
    let icon = templatize(#imageLiteral(resourceName: "launch"))
    
    let isAvailable = true
    
    init(application: Application) {
        self.application = application
    }
    
    func perform() {
        guard let application = application else {
            return
        }
        application.launch()
    }
}
