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
    
    enum Availability: String {
        case available = "(available)"
        case unavailable = "(unavailable, runtime profile not found)"
    }

    let UDID: String
    let type: String
    let name: String
    let state: State
    let availability: Availability
    var applications: [Application]?

    init(udid: String, type: String, name: String, state: String, availability: String) {
        self.UDID = udid
        self.type = type
        self.name = name
        self.state = State(rawValue: state) ?? .Unknown
        self.availability = Availability(rawValue: availability.trimmingCharacters(in: .whitespacesAndNewlines)) ?? .unavailable
        
        let applicationPath = URLHelper.deviceURLForUDID(self.UDID).appendingPathComponent("data/Containers/Bundle/Application")
        let contents = try? FileManager.default.contentsOfDirectory(at: applicationPath, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles])
        defer {
            self.applications = contents?
                .filter({ (url) -> Bool in
                    var isDirectoryObj: AnyObject?
                    try? (url as NSURL).getResourceValue(&isDirectoryObj, forKey: URLResourceKey.isDirectoryKey)
                    guard let isDirectory = isDirectoryObj as? Bool else {
                        return false
                    }
                    return isDirectory
                })
                .map { Application(device: self, url: $0) }
                .filter { $0 != nil }
                .map { $0! }
        }
    }

    var fullName:String {
        get {
            return "\(self.name)"
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
