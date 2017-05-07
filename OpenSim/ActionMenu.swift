//
//  ActionMenu.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

final class ActionMenu: NSMenu {
    
    private weak var device: Device!
    private weak var application: Application!
    
    private var titleItem: NSMenuItem {
        let item = NSMenuItem(title: "Actions", action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item
    }
    
    private let templatize: (NSImage) -> (NSImage) = {
        $0.isTemplate = true
        return $0
    }
    
    private var revealInFinderItem: NSMenuItem? {
        let item = NSMenuItem(title: "Reveal Sandbox in Finder", action: #selector(revealInFinder(_:)), keyEquivalent: "")
        let image = templatize(#imageLiteral(resourceName: "reveal"))
        image.isTemplate = true
        item.image = image
        item.target = self
        return item
    }
    
    private var copyPathItem: NSMenuItem? {
        let item = NSMenuItem(title: "Copy Sandbox Path to Pasteboard", action: #selector(copyToPasteboard(_:)), keyEquivalent: "")
        item.image = templatize(#imageLiteral(resourceName: "share"))
        item.target = self
        return item
    }
    
    private var openInTerminalItem: NSMenuItem? {
        let item = NSMenuItem(title: "Open Sandbox in Terminal", action: #selector(openInTerminal(_:)), keyEquivalent: "")
        item.image = templatize(#imageLiteral(resourceName: "terminal"))
        item.target = self
        return item
    }
    
    private var uninstallItem: NSMenuItem? {
        let item = NSMenuItem(title: "Uninstall…", action: #selector(uninstall(_:)), keyEquivalent: "")
        item.image = templatize(#imageLiteral(resourceName: "uninstall"))
        item.target = self
        return item
    }
    
    private var sandboxUrl: URL? {
        guard let url = device.containerURLForApplication(application),
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
        
        let items = [
            titleItem,
            revealInFinderItem,
            copyPathItem,
            openInTerminalItem,
            uninstallItem
        ]
        items.forEach { (item) in
            if let item = item {
                self.addItem(item)
            }
        }
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
    
    @objc private func openInTerminal(_ sender: AnyObject) {
        if let url = sandboxUrl {
            NSWorkspace.shared().openFile(url.path, withApplication: "Terminal")
        }
    }
    
    @objc private func uninstall(_ sender: AnyObject) {
        SimulatorController.uninstall(DeviceApplicationPair(device: device, application: application))
    }
}
