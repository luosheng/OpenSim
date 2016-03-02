//
//  Device.swift
//  SimPholders
//
//  Created by Luo Sheng on 11/9/15.
//  Copyright © 2015 Luo Sheng. All rights reserved.
//

import Foundation

struct Device {
    
    enum State: String {
        case Shutdown = "Shutdown"
        case Unknown = "Unknown"
        case Booted = "Booted"
    }
    
    let UDID: String
    let type: String
    let name: String
    let runtime: Runtime
    let state: State
    let applications: [Application]
    
    init(UDID: String, type: String, name: String, runtime: String, state: State) {
        self.UDID = UDID
        self.type = type
        self.name = name
        self.runtime = Runtime(name: runtime)
        self.state = state
        
        let applicationPath = URLHelper.deviceURLForUDID(self.UDID).URLByAppendingPathComponent("data/Containers/Bundle/Application")
        do {
            let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(applicationPath, includingPropertiesForKeys: nil, options: [.SkipsSubdirectoryDescendants, .SkipsHiddenFiles])
            self.applications = contents.map { Application(URL: $0) }.filter { $0 != nil }.map { $0! }
        } catch {
            self.applications = []
        }
    }
    
    func fetchApplicationState(application: Application) -> ApplicationState? {
        if let applicationStateDict = NSDictionary(contentsOfURL: URLHelper.applicationStateURLForUDID(self.UDID)) as? [String: [String: AnyObject]] {
            if let (_, dict) = applicationStateDict.filter({ $0.0 == application.bundleID }).first,
                compatibilityInfoDict = dict["compatibilityInfo"] as? [String: AnyObject],
                bundlePath = compatibilityInfoDict["bundlePath"] as? String,
                sandboxPath = compatibilityInfoDict["sandboxPath"] as? String,
                bundleContainerPath = compatibilityInfoDict["bundleContainerPath"] as? String {
                    return ApplicationState(
                        bundlePath: bundlePath,
                        sandboxPath: sandboxPath,
                        bundleContainerPath: bundleContainerPath
                    )
            }
        }
        return nil
    }
    
}