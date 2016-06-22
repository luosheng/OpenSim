//
//  Application.swift
//  SimPholders
//
//  Created by Luo Sheng on 11/9/15.
//  Copyright © 2015 Luo Sheng. All rights reserved.
//

import Foundation

struct Application {
    
    let bundleDisplayName: String
    let bundleID: String
    let bundleShortVersion: String
    let bundleVersion: String
    let URL: Foundation.URL
    
    init?(URL: Foundation.URL) {
        self.URL = URL
        let contents = try! FileManager.default().contentsOfDirectory(at: URL, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles])
        guard let appInfoPath = try! contents.last?.appendingPathComponent("Info.plist"),
            appInfoDict = NSDictionary(contentsOf: appInfoPath),
            aBundleID = appInfoDict["CFBundleIdentifier"] as? String,
            aBundleDisplayName = (appInfoDict["CFBundleDisplayName"] as? String) ?? (appInfoDict["CFBundleName"] as? String),
            aBundleShortVersion = appInfoDict["CFBundleShortVersionString"] as? String,
            aBundleVersion = appInfoDict["CFBundleInfoDictionaryVersion"] as? String else {
                return nil
        }
        
        bundleDisplayName = aBundleDisplayName
        bundleID = aBundleID
        bundleShortVersion = aBundleShortVersion
        bundleVersion = aBundleVersion
    }
    
}
