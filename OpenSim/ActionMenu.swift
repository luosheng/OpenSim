//
//  ActionMenu.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

final class ActionMenu: NSMenu {
    
    private weak var application: Application!
    
    private static let standardActions: [ApplicationActionable.Type] = [
        RevealInFinderAction.self,
        CopyToPasteboardAction.self,
        OpenInTerminalAction.self,
        LaunchAction.self,
        UninstallAction.self
    ]
    
    private static let extraActions: [ApplicationActionable.Type] = [
        OpenUserDefaultsAction.self,
        OpenInItermAction.self,
        OpenRealmAction.self
    ]
    
    private var appInfoItem: NSMenuItem {
        let item = NSMenuItem()
        item.view = AppInfoView(application: application)
        return item
    }
    
    init(device: Device, application: Application) {
        self.application = application
        
        super.init(title: "")
        
        buildMenuItems()
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildMenuItems() {
        let createAction: (ApplicationActionable.Type) -> ApplicationActionable = { $0.init(application: self.application) }
        
        self.buildMenuSection(title: UIConstants.strings.menuHeaderActions, actions: ActionMenu.standardActions.map(createAction))
        self.buildMenuSection(title: UIConstants.strings.menuHeaderExtensions, actions: ActionMenu.extraActions.map(createAction))
        self.addItem(self.buildSectionTitle(title: UIConstants.strings.menuHeaderAppInformation))
        self.addItem(appInfoItem)
    }
    
    private func buildMenuSection(title: String, actions: [ApplicationActionable]) {
        self.addItem(self.buildSectionTitle(title: title))
        
        actions.forEach { (action) in
            if let item = buildMenuItem(for: action) {
                self.addItem(item)
            }
        }
        
        self.addItem(NSMenuItem.separator())
    }
    
    private func buildSectionTitle(title: String) -> NSMenuItem {
        let titleItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        return titleItem
    }
    
    private func buildMenuItem(`for` action: ApplicationActionable) -> NSMenuItem? {
        if !action.isAvailable {
            return nil
        }
        let item = NSMenuItem(title: action.title, action: #selector(actionMenuItemClicked(_:)), keyEquivalent: "")
        item.representedObject = action
        item.image = action.icon
        item.target = self
        return item
    }
    
    @objc private func actionMenuItemClicked(_ sender: NSMenuItem) {
        (sender.representedObject as? ApplicationActionable)?.perform()
    }
    
}
