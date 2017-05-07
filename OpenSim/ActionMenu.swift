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
    
    private var revealInFinderMenuItem: NSMenuItem {
        let item = NSMenuItem(title: "Reveal Sandbox in Finder", action: #selector(revealInFinder(_:)), keyEquivalent: "")
        item.target = self
        return item
    }
    
    private var copyPathMenuItem: NSMenuItem {
        let item = NSMenuItem(title: "Copy Sandbox Path to Pasteboard", action: #selector(copyToPasteboard(_:)), keyEquivalent: "")
        item.target = self
        return item
    }
    
    private var openInTerminalMenuItem: NSMenuItem {
        let item = NSMenuItem(title: "Open Sandbox in Terminal", action: #selector(openInTerminal(_:)), keyEquivalent: "")
        item.target = self
        return item
    }
    
    private var uninstallMenuItem: NSMenuItem {
        let item = NSMenuItem(title: "Uninstall…", action: #selector(uninstall(_:)), keyEquivalent: "")
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
        
        self.addItem(revealInFinderMenuItem)
        self.addItem(copyPathMenuItem)
        self.addItem(openInTerminalMenuItem)
        self.addItem(uninstallMenuItem)
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
