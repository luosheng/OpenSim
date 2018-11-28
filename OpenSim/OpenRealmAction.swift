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
    
    let appBundleIdentifier = "io.realm.realmbrowser"
    
    let title = UIConstants.strings.extensionOpenRealmDatabase
    
    var isAvailable: Bool {
        return appPath != nil && realmPath != nil
    }
    
    var realmPath: String?
    
    init(application: Application) {
        self.application = application
        
        if let sandboxUrl = application.sandboxUrl,
            let enumerator = FileManager.default.enumerator(at: sandboxUrl, includingPropertiesForKeys: nil) {
            while let fileUrl = enumerator.nextObject() as? URL {
                if fileUrl.pathExtension.lowercased() == "realm" {
                    realmPath = fileUrl.path
                }
            }
        }
    }
    
    func perform() {
        if let realmPath = realmPath {
            NSWorkspace.shared.openFile(realmPath, withApplication: "Realm Browser")
        }
    }
    
}
