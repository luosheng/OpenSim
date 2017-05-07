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
    
    weak var device: Device!
    
    let bundleDisplayName: String
    let bundleID: String
    let bundleShortVersion: String
    let bundleVersion: String
    let url: URL
    let iconFiles: [String]?
    
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
            let url = contents.last // url ".app" diretory
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

        iconFiles = ((appInfoDict["CFBundleIcons"] as? NSDictionary)?["CFBundlePrimaryIcon"] as? NSDictionary)?["CFBundleIconFiles"] as? [String]
    }
    
    func calcSize(block: @escaping (UInt64) -> Void) {
        if let size = size {
            block(size)
        } else {
            Application.sizeDispatchQueue.async {
                var size: UInt64 = 0
                let filesEnumerator = FileManager.default.enumerator(at: self.url, includingPropertiesForKeys: nil, options: [], errorHandler: { (url, error) -> Bool in
                    return true
                })
                while let fileUrl = filesEnumerator?.nextObject() as? URL {
                    let attributes = try? FileManager.default.attributesOfItem(atPath: fileUrl.path) as NSDictionary
                    size += attributes?.fileSize() ?? 0
                }
                self.size = size
                block(size)
            }
        }
    }
    
    func uninstall() {
        SimulatorController.uninstall(DeviceApplicationPair(device: device, application: self))
    }
}
