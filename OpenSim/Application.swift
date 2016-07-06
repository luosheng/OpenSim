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
    
    let bundleDisplayName: String
    let bundleID: String
    let bundleShortVersion: String
    let bundleVersion: String
    let url: URL
    let iconFiles: [String]?
    
    var size: UInt64?
    static let sizeDispatchQueue = DispatchQueue(label: "com.pop-tap.size", attributes: .concurrent, target: nil)

    init?(url: Foundation.URL) {
        guard let contents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles]),
            url = contents.last, // url ".app" diretory
            appInfoPath = try? url.appendingPathComponent("Info.plist"),
            appInfoDict = NSDictionary(contentsOf: appInfoPath),
            aBundleID = appInfoDict["CFBundleIdentifier"] as? String,
            aBundleDisplayName = (appInfoDict["CFBundleDisplayName"] as? String) ?? (appInfoDict["CFBundleName"] as? String),
            aBundleShortVersion = appInfoDict["CFBundleShortVersionString"] as? String,
            aBundleVersion = appInfoDict["CFBundleInfoDictionaryVersion"] as? String else {
            return nil
        }

        self.url = url
        
        bundleDisplayName = aBundleDisplayName
        bundleID = aBundleID
        bundleShortVersion = aBundleShortVersion
        bundleVersion = aBundleVersion

        iconFiles = ((appInfoDict["CFBundleIcons"] as? NSDictionary)?["CFBundlePrimaryIcon"] as? NSDictionary)?["CFBundleIconFiles"] as? [String]
    }
    
    func calcSize(block: (UInt64) -> Void) {
        if let size = size {
            block(size)
        } else {
            Application.sizeDispatchQueue.async {
                var size: UInt64 = 0
                let filesEnumerator = FileManager.default.enumerator(at: self.url, includingPropertiesForKeys: nil, options: [], errorHandler: { (url, error) -> Bool in
                    return true
                })
                while let fileUrl = filesEnumerator?.nextObject() as? URL {
                    do {
                        let attributes = try FileManager.default.attributesOfItem(atPath: fileUrl.path!) as NSDictionary
                        size += attributes.fileSize()
                    } catch {
                        
                    }
                }
                self.size = size
                block(size)
            }
        }
    }
}
