//
//  Application.swift
//  SimPholders
//
//  Created by Luo Sheng on 11/9/15.
//  Copyright © 2015 Luo Sheng. All rights reserved.
//

import Foundation
import AppKit

struct Application {
    
    let bundleDisplayName: String
    let bundleID: String
    let bundleShortVersion: String
    let bundleVersion: String
    let URL: NSURL
    let deviceUDID: String
    var iconImage: NSImage? = nil

  
    init?(URL: NSURL, deviceID: String) {
        self.URL = URL
        let contents = try! NSFileManager.defaultManager().contentsOfDirectoryAtURL(URL, includingPropertiesForKeys: nil, options: [.SkipsSubdirectoryDescendants, .SkipsHiddenFiles])
        guard let appInfoPath = contents.last?.URLByAppendingPathComponent("Info.plist"),
            appInfoDict = NSDictionary(contentsOfURL: appInfoPath),
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
        deviceUDID = deviceID
        iconImage = appIcon()
    }
  
  
    private func appIcon() -> NSImage? {
        var bundlePath = shell("/usr/bin/xcrun", arguments: ["simctl", "get_app_container", "\(deviceUDID)", "\(bundleID)"]);
        bundlePath = bundlePath.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if bundlePath.characters.count > 0 {
          //Get all files
          let listofFiles = try! NSFileManager.defaultManager().contentsOfDirectoryAtPath(bundlePath).filter{$0.containsString("AppIcon")}
          if listofFiles.count > 0 {
            let imagePath = "\(bundlePath)/\(listofFiles[0])"
            return NSImage(contentsOfFile: imagePath) ?? NSBundle.mainBundle().imageForResource("DefaultAppIcon")
          }
        }
        return NSBundle.mainBundle().imageForResource("DefaultAppIcon")
    }
  
  
}