//
//  Application.swift
//  SimPholders
//
//  Created by Luo Sheng on 11/9/15.
//  Copyright © 2015 Luo Sheng. All rights reserved.
//

import Foundation
import Cocoa

final class Application {
    
    var device: Device!
    
    let bundleDisplayName: String
    let bundleID: String
    let bundleShortVersion: String
    let bundleVersion: String
    let url: URL
    var iconFiles: [String] = []

    var size: UInt64?
    static let sizeDispatchQueue = DispatchQueue(label: "com.pop-tap.size", attributes: .concurrent, target: nil)
    
    var sandboxUrl: URL? {
        guard let url = device.containerURLForApplication(self),
            FileManager.default.fileExists(atPath: url.path)
            else {
                return nil
        }
        return url
    }

    init?(device: Device, url: Foundation.URL) {
        self.device = device
        guard let contents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles]),
            let url = contents.filter({ $0.absoluteString.hasSuffix(".app/") }).first // url ".app" diretory
            else {
                return nil
        }
        
        let appInfoPath = url.appendingPathComponent("Info.plist")
        
        guard let appInfoDict = NSDictionary(contentsOf: appInfoPath),
            let aBundleID = appInfoDict["CFBundleIdentifier"] as? String,
            let aBundleDisplayName = (appInfoDict["CFBundleDisplayName"] as? String) ?? (appInfoDict["CFBundleName"] as? String),
            let aBundleShortVersion = appInfoDict["CFBundleShortVersionString"] as? String,
            let aBundleVersion = appInfoDict["CFBundleVersion"] as? String else {
                return nil
        }

        self.url = url
        
        bundleDisplayName = aBundleDisplayName
        bundleID = aBundleID
        bundleShortVersion = aBundleShortVersion
        bundleVersion = aBundleVersion
        
        iconFiles = []
        
        // iPhone icons
        if let bundleIcons = appInfoDict["CFBundleIcons"] as? NSDictionary {
            if let bundlePrimaryIcon = bundleIcons["CFBundlePrimaryIcon"] as? NSDictionary {
                if let bundleIconFiles = bundlePrimaryIcon["CFBundleIconFiles"] as? [String] {
                    for iconFile in bundleIconFiles {
                        iconFiles.append(iconFile)
                        iconFiles.append(iconFile.appending("@2x"))
                    }
                }
            }
        }
        
        // iPad icons
        if let bundleIcons = appInfoDict["CFBundleIcons~ipad"] as? NSDictionary {
            if let bundlePrimaryIcon = bundleIcons["CFBundlePrimaryIcon"] as? NSDictionary {
                if let bundleIconFiles = bundlePrimaryIcon["CFBundleIconFiles"] as? [String] {
                    for iconFile in bundleIconFiles {
                        iconFiles.append(iconFile.appending("~ipad"))
                        iconFiles.append(iconFile.appending("@2x~ipad"))
                    }
                }
            }
        }
    }
    
    func calcSize(block: @escaping (UInt64) -> Void) {
        if let size = size {
            block(size)
        } else {
            Application.sizeDispatchQueue.async {
                let duResult = shell("/usr/bin/du", arguments: ["-sk", self.url.path])
                let stringBytes = String(duResult.split(separator: "\t").first ?? "")
                var bytes: UInt64 = 0
                if let kbytes = UInt64(stringBytes) {
                    bytes = kbytes * 1000
                    self.size = bytes;
                }
                block(bytes)
            }
        }
    }
    
    func launch() {
        if device.state != .booted {
            SimulatorController.boot(self)
        }
        SimulatorController.run(self)
        SimulatorController.launch(self)
    }
    
    func uninstall() {
        if device.state != .booted {
            SimulatorController.boot(self)
        }
        SimulatorController.uninstall(self)
    }
}
