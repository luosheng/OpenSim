//
//  ActionMenu.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

final class ActionMenu: NSMenu {
    
    weak var device: Device?
    weak var application: Application?
    
    var revealInFinderMenuItem: NSMenuItem {
        let item = NSMenuItem(title: "Reveal Sandbox in Finder", action: #selector(revealInFinder(_:)), keyEquivalent: "")
        item.target = self
        return item
    }
    
    var copyPathMenuItem: NSMenuItem {
        let item = NSMenuItem(title: "Copy Sandbox Path to Pasteboard", action: #selector(copyToPasteboard(_:)), keyEquivalent: "")
        item.target = self
        return item
    }
    
    private var sandboxUrl: URL? {
        guard let application = application,
            let url = device?.containerURLForApplication(application),
            FileManager.default.fileExists(atPath: url.path)
            else {
                return nil
        }
        return url
    }
    
    init(device: Device, application: Application) {
        self.device = device
        self.application = application
        super.init(title: "")
        
        self.addItem(revealInFinderMenuItem)
        self.addItem(copyPathMenuItem)
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func revealInFinder(_ sender: AnyObject) {
        if let url = sandboxUrl {
            NSWorkspace.shared().open(url)
        }
    }
    
    @objc private func copyToPasteboard(_ sender: AnyObject) {
        if let url = sandboxUrl {
            NSPasteboard.general().setString(url.path, forType: NSPasteboardTypeString)
        }
    }
}
