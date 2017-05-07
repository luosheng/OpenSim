//
//  Device.swift
//  SimPholders
//
//  Created by Luo Sheng on 11/9/15.
//  Copyright © 2015 Luo Sheng. All rights reserved.
//

import Foundation

final class Device {

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
        
        let applicationPath = URLHelper.deviceURLForUDID(self.UDID).appendingPathComponent("data/Containers/Bundle/Application")
        let contents = try? FileManager.default.contentsOfDirectory(at: applicationPath, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles])
        let applications = contents?
            .filter({ (url) -> Bool in
                var isDirectoryObj: AnyObject?
                try? (url as NSURL).getResourceValue(&isDirectoryObj, forKey: URLResourceKey.isDirectoryKey)
                guard let isDirectory = isDirectoryObj as? Bool else {
                    return false
                }
                return isDirectory
            })
            .map { Application(url: $0) }
            .filter { $0 != nil }
            .map { $0! }
        self.applications = applications ?? []
    }

    var fullName:String {
        get {
            return "\(self.name) (\(self.runtime))"
        }
    }

    func containerURLForApplication(_ application: Application) -> URL? {
        let URL = URLHelper.containersURLForUDID(UDID)
        let directories = try? FileManager.default.contentsOfDirectory(at: URL, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)
        return directories?.filter({ (dir) -> Bool in
            if let contents = NSDictionary(contentsOf: dir.appendingPathComponent(".com.apple.mobile_container_manager.metadata.plist")),
                let identifier = contents["MCMMetadataIdentifier"] as? String, identifier == application.bundleID {
                return true
            }
            return false
        }).first
    }
    
}
