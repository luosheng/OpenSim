//
//  AppMenuView.swift
//  OpenSim
//
//  Created by Luo Sheng on 16/6/25.
//  Copyright © 2016年 Luo Sheng. All rights reserved.
//

import Foundation
import Cocoa

protocol ModifyFlagsResponsive {

    var lastFlag: NSEventModifierFlags? { get set }

    func processModifyFlags(flags: NSEventModifierFlags)

}

extension ModifyFlagsResponsive {

    func extractFlag(flags: NSEventModifierFlags) -> NSEventModifierFlags? {
        let sequence: [NSEventModifierFlags] = [.control, .shift,. option]
        return sequence.first { flags.contains($0) }
    }

}

class AppMenuView: NSView, ModifyFlagsResponsive {
    
    let application: Application
    var iconView: NSImageView!
    var nameLabel: NSTextField!
    var detailedLabel: NSTextField!
    var sizeLabel: NSTextField!
    var lastFlag: NSEventModifierFlags?
    
    init(app: Application) {
        application = app
        super.init(frame: NSRect(x: 0, y: 0, width: 220, height: 50))
        
        setupViews()
        updateViews()
        addTrackingArea(NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func acceptsFirstMouse(_ event: NSEvent?) -> Bool {
        return true
    }
    
    override var allowsVibrancy: Bool {
        return true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if let highlighted = self.enclosingMenuItem?.isHighlighted {
            if highlighted {
                NSColor.controlHighlightColor().set()
            } else {
                NSColor.clear().set()
            }
            NSRectFill(bounds)
        }
    }
    
    override func mouseUp(_ event: NSEvent) {
        guard let menuItem = self.enclosingMenuItem else {
            return
        }
        menuItem.menu?.cancelTracking()
        if let action = menuItem.action,
            target = menuItem.target {
            NSApp.sendAction(action, to: target, from: menuItem)
        }
    }

    override func mouseExited(_ event: NSEvent) {
        lastFlag = nil
        setDefaultState()
    }
    
    private func setupViews() {
        iconView = NSImageView(frame: NSRect(x: 20, y: 9, width: 32, height: 32))
        if let iconFile = application.iconFiles?.last,
            bundle = Bundle(url: application.url) {
            iconView.image = bundle.image(forResource: iconFile)?.appIcon()
        } else {
            iconView.image = NSImage(named: "DefaultAppIcon")?.appIcon()
        }
        addSubview(iconView)
        
        nameLabel = createLabel()
        nameLabel.font = NSFont.systemFont(ofSize: 11)
        nameLabel.frame = NSRect(x: 62, y: 32, width: 148, height: 13)
        nameLabel.stringValue = application.bundleDisplayName
        addSubview(nameLabel)
        
        detailedLabel = createLabel()
        detailedLabel.textColor = NSColor.secondaryLabelColor()
        detailedLabel.font = NSFont.systemFont(ofSize: 10)
        detailedLabel.frame = NSRect(x: 62, y: 19, width: 148, height: 12)
        addSubview(detailedLabel)
        
        sizeLabel = createLabel()
        sizeLabel.textColor = NSColor.secondaryLabelColor()
        sizeLabel.font = NSFont.systemFont(ofSize: 10)
        sizeLabel.frame = NSRect(x: 62, y: 6, width: 148, height: 12)
        sizeLabel.stringValue = "Calculating…"
        application.calcSize { (size) in
            DispatchQueue.main.async { [weak self] in
                self?.sizeLabel.stringValue = ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
            }
        }
        addSubview(sizeLabel)
    }

    private func updateViews() {
        if let flag = lastFlag {
            if flag == .control {
                setUninstallState()
                return
            }
            setDefaultState()
        }
        setDefaultState()
    }

    private func setDefaultState() {
        detailedLabel.stringValue = application.bundleID
    }

    private func setUninstallState() {
        detailedLabel.stringValue = "Uninstall \(application.bundleDisplayName)"
    }
    
    private func createLabel() -> NSTextField {
        let label = NSTextField()
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = false
        return label
    }

    func processModifyFlags(flags: NSEventModifierFlags) {
        let flag = extractFlag(flags: flags)
        guard flag != lastFlag else {
            return
        }
        lastFlag = flag

        DispatchQueue.main.async { 
            self.updateViews()
        }
    }
    
}
