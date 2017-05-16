//
//  LaunchAtLoginHelper.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Foundation

func getLoginItems() -> LSSharedFileList? {
    let allocator = CFAllocatorGetDefault().takeRetainedValue()
    let kLoginItems = kLSSharedFileListSessionLoginItems.takeUnretainedValue()
    guard let loginItems = LSSharedFileListCreate(allocator, kLoginItems, nil) else {
        return nil
    }
    return loginItems.takeRetainedValue()
}

func existingItem(itemUrl: URL) -> LSSharedFileListItem? {
    guard let loginItems = getLoginItems() else {
        return nil
    }
    
    var seed: UInt32 = 0
    if let currentItems = LSSharedFileListCopySnapshot(loginItems, &seed).takeRetainedValue() as? [LSSharedFileListItem] {
        for item in currentItems {
            let resolutionFlags = UInt32(kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes)
            if let cfurl = LSSharedFileListItemCopyResolvedURL(item, resolutionFlags, nil) {
                let url = cfurl.takeRetainedValue() as URL
                if itemUrl == url {
                    return item
                }
            }
            
        }
    }
    return nil
}

func setLaunchAtLogin(itemUrl: URL, enabled: Bool) {
    guard let loginItems = getLoginItems() else {
        return
    }
    if let item = existingItem(itemUrl: itemUrl) {
        if (!enabled) {
            LSSharedFileListItemRemove(loginItems, item)
        }
    } else {
        if (enabled) {
            LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst.takeUnretainedValue(), nil, nil, itemUrl as CFURL, nil, nil)
        }
    }
}
