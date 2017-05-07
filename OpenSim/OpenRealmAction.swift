//
//  OpenRealmAction.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

final class OpenRealmAction: ExtraApplicationActionable {
    
    var application: Application?
    
    let appBundleIdentifier = "io.realm.Realm-Browser"
    
    let title = "Open Realm Database"
    
    init(application: Application) {
        self.application = application
    }
    
    func perform() {
        
    }
    
}
