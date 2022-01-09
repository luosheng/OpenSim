//
//  MenuManager.swift
//  OpenSim
//
//  Created by Luo Sheng on 16/3/24.
//  Copyright © 2016年 Luo Sheng. All rights reserved.
//

import Foundation
import Cocoa

protocol MenuManagerDelegate {
    func shouldQuitApp()
}

@objc final class MenuManager: NSObject, NSMenuDelegate {
    
    let statusItem: NSStatusItem
    var focusedMode: Bool = true
    
    var watcher: DirectoryWatcher!
    
    var subWatchers: [DirectoryWatcher?]?
    
    var block: dispatch_cancelable_block_t?
    
    var delegate: MenuManagerDelegate?

    var menuObserver: CFRunLoopObserver?
    
    override init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.image = NSImage(named: "menubar")
        statusItem.image!.isTemplate = true
        
        super.init()
        
        buildMenu()
    }
    
    deinit {
        stop()
    }
    
    func start() {
        buildWatcher()
        buildSubWatchers()
    }
    
    func stop() {
        watcher.stop()
        subWatchers?.forEach { $0?.stop() }
    }
    
    private func buildMenu() {
        let menu = NSMenu()

        menu.addItem(NSMenuItem.separator())

        let refreshMenuItem = menu.addItem(withTitle: UIConstants.strings.menuRefreshButton, action: #selector(self.refreshItemClicked(_:)), keyEquivalent: "r")
        refreshMenuItem.target = self

        let focusedModeMenuItem = menu.addItem(withTitle: UIConstants.strings.menuFocusedModeButton, action: #selector(self.toggleFocusedMode), keyEquivalent: "")
        focusedModeMenuItem.target = self
        focusedModeMenuItem.state = self.focusedMode ? .on : .off

        let launchAtLoginMenuItem = menu.addItem(withTitle: UIConstants.strings.menuLaunchAtLoginButton, action: #selector(self.launchItemClicked(_:)), keyEquivalent: "")
        launchAtLoginMenuItem.target = self
        if existingItem(itemUrl: Bundle.main.bundleURL) != nil {
            launchAtLoginMenuItem.state = .on
        } else {
            launchAtLoginMenuItem.state = .off
        }
        
        DeviceManager.defaultManager.reload { (runtimes) in
            
            var sortedList = [Runtime]()
            Dictionary(grouping: runtimes, by: { (runtime: Runtime) in
                return runtime.platform
            }).values.map({ (runtimeList: [Runtime]) -> [Runtime] in
                return runtimeList.sorted { $0.version ?? 0.0 > $1.version ?? 0.0 }
            }).forEach({ (list) in
                sortedList.append(contentsOf: list)
            })
            sortedList.forEach { (runtime) in
                var devices = runtime.devices
                if self.focusedMode {
                    devices = devices.filter { $0.state == .booted || $0.applications?.count ?? 0 > 0 }
                }
                if devices.count == 0 {
                    return
                }
                menu.addItem(NSMenuItem.separator())
                let titleItem = NSMenuItem(title: "\(runtime)", action: nil, keyEquivalent: "")
                titleItem.isEnabled = false
                menu.addItem(titleItem)

                devices.forEach({ (device) in
                    let deviceMenuItem = menu.addItem(withTitle: device.name, action: nil, keyEquivalent: "")
                    deviceMenuItem.onStateImage = NSImage(named: "active")
                    deviceMenuItem.offStateImage = NSImage(named: "inactive")
                    deviceMenuItem.state = device.state == .booted ? .on : .off

                    let submenu = NSMenu()
                    submenu.delegate = self

                    // Launch Simulator
                    let simulatorItem = SimulatorMenuItem(runtime:runtime, device:device)
                    submenu.addItem(simulatorItem)
                    submenu.addItem(NSMenuItem.separator())
                    
                    // Sort applications by name
                    let sortApplications = device.applications?.sorted(by: { (app1, app2) -> Bool in
                        app1.bundleDisplayName.lowercased() < app2.bundleDisplayName.lowercased()
                    })
                    
                    sortApplications?.forEach { app in
                        let appMenuItem = AppMenuItem(application: app)
                        appMenuItem.submenu = ActionMenu(device: device, application: app)
                        submenu.addItem(appMenuItem)
                    }
                    deviceMenuItem.submenu = submenu

                    // Simulator Shutdown/Reset
                    submenu.addItem(NSMenuItem.separator())
                    if device.state == .booted {
                        submenu.addItem(SimulatorShutdownMenuItem(device: device))
                    }
                    if device.applications?.count ?? 0 > 0 {
                        submenu.addItem(SimulatorResetMenuItem(device: device))
                    }
                    submenu.addItem(SimulatorEraseMenuItem(device: device))
                })

            }

            menu.addItem(NSMenuItem.separator())

            let eraseAllSimulators = menu.addItem(withTitle: UIConstants.strings.menuShutDownAllSimulators, action: #selector(self.factoryResetAllSimulators), keyEquivalent: "")
            eraseAllSimulators.target = self

            let eraseAllShutdownSimulators = menu.addItem(withTitle: UIConstants.strings.menuShutDownAllBootedSimulators, action: #selector(self.factoryResetAllShutdownSimulators), keyEquivalent: "")
            eraseAllShutdownSimulators.target = self

            menu.addItem(NSMenuItem.separator())
            
            let quitMenu = menu.addItem(withTitle: UIConstants.strings.menuQuitButton, action: #selector(self.quitItemClicked(_:)), keyEquivalent: "q")
            quitMenu.target = self
            
            if let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                menu.addItem(NSMenuItem.separator())
                menu.addItem(withTitle: "\(UIConstants.strings.menuVersionLabel) \(versionNumber)", action: nil, keyEquivalent: "")
            }

            self.statusItem.menu = menu
        }
    }

    private func buildWatcher() {
        watcher = DirectoryWatcher(in: URLHelper.deviceURL)
        watcher.completionCallback = { [weak self] in
            self?.reloadWhenReady(delay: 5)
            self?.buildSubWatchers()
        }
        try? watcher.start()
    }
    
    private func buildSubWatchers() {
        subWatchers?.forEach { $0?.stop() }
        let deviceDirectories = try? FileManager.default.contentsOfDirectory(at: URLHelper.deviceURL as URL, includingPropertiesForKeys: FileInfo.prefetchedProperties, options: .skipsSubdirectoryDescendants)
        subWatchers = deviceDirectories?.map(createSubWatcherForURL)
    }
    
    private func createSubWatcherForURL(_ URL: Foundation.URL) -> DirectoryWatcher? {
        guard let info = FileInfo(URL: URL), info.isDirectory else {
            return nil
        }
        let watcher = DirectoryWatcher(in: URL)
        watcher.completionCallback = { [weak self] in
            self?.reloadWhenReady()
        }
        try? watcher.start()
        return watcher
    }

    @objc private func toggleFocusedMode() {
        focusedMode = !focusedMode
        reloadWhenReady(delay: 0)
    }
    
    private func reloadWhenReady(delay: TimeInterval = 1) {
        dispatch_cancel_block_t(self.block)
        self.block = dispatch_block_t(delay) { [weak self] in
            self?.watcher.stop()
            self?.buildMenu()
            ((try? self?.watcher.start()) as ()??)
        }
    }
    
    @objc func quitItemClicked(_ sender: AnyObject) {
        delegate?.shouldQuitApp()
    }

    @objc func refreshItemClicked(_ sender: AnyObject) {
        reloadWhenReady()
    }
    
    @objc func launchItemClicked(_ sender: NSMenuItem) {
        let wasOn = sender.state == .on
        sender.state = (wasOn ? .off : .on)
        setLaunchAtLogin(itemUrl: Bundle.main.bundleURL, enabled: !wasOn)
    }
    
    private func resetAllSimulators() {
        DeviceManager.defaultManager.reload { (runtimes) in
            runtimes.forEach({ (runtime) in
                let devices = runtime.devices.filter { $0.applications?.count ?? 0 > 0 }
                self.resetSimulators(devices)
            })
        }
    }
    
    private func resetShutdownSimulators() {
        DeviceManager.defaultManager.reload { (runtimes) in
            runtimes.forEach({ (runtime) in
                var devices = runtime.devices.filter { $0.applications?.count ?? 0 > 0 }
                devices = devices.filter { $0.state == .shutdown }
                self.resetSimulators(devices)
            })
        }
    }
    
    private func resetSimulators(_ devices: [Device]) {
        devices.forEach { (device) in
            if device.state == .booted {
                device.shutDown()
            }
            device.factoryReset()
        }
    }

    @objc func factoryResetAllSimulators() {
        let alert: NSAlert = NSAlert()
        alert.messageText = String(format: UIConstants.strings.actionFactoryResetAllSimulatorsMessage)
        alert.alertStyle = .critical
        alert.addButton(withTitle: UIConstants.strings.actionFactoryResetAlertConfirmButton)
        alert.addButton(withTitle: UIConstants.strings.actionFactoryResetAlertCancelButton)
        let response = alert.runModal()
        if response == NSApplication.ModalResponse.alertFirstButtonReturn {
            resetAllSimulators()
        }
    }

    @objc func factoryResetAllShutdownSimulators() {
        let alert: NSAlert = NSAlert()
        alert.messageText = String(format: UIConstants.strings.actionFactoryResetAllShutdownSimulatorsMessage)
        alert.alertStyle = .critical
        alert.addButton(withTitle: UIConstants.strings.actionFactoryResetAlertConfirmButton)
        alert.addButton(withTitle: UIConstants.strings.actionFactoryResetAlertCancelButton)
        let response = alert.runModal()
        if response == NSApplication.ModalResponse.alertFirstButtonReturn {
            resetShutdownSimulators()
        }
    }
    
}
