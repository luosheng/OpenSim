// 
// Created for OpenSim in 2020
// Using Swift 5.2
// Created by Gene Crucean on 4/20/20
// 

import Cocoa

final class OpenUserDefaultsAction: ApplicationActionable {
    
    var application: Application?
    
    let title = UIConstants.strings.actionOpenUserDefaults
    
    let icon = templatize(#imageLiteral(resourceName: "userDefaults"))
    
    var isAvailable: Bool {
        return Bundle.main.bundleIdentifier != nil
    }
    
    var userDefaultsPath: String?
    
    init(application: Application) {
        self.application = application
        
        guard let bundleId = Bundle.main.bundleIdentifier else { return }
        
        // There is probably a better way of doing this. I need to do a bit of research.
        if let pathUrl = application.sandboxUrl?.appendingPathComponent("Library").appendingPathComponent("Preferences"), let enumerator = FileManager.default.enumerator(at: pathUrl, includingPropertiesForKeys: nil) {
            while let fileUrl = enumerator.nextObject() as? URL {
                if fileUrl.lastPathComponent == "\(application.bundleID).plist" {
                    userDefaultsPath = fileUrl.path
                }
            }
        }
    }
    
    func perform() {
        if let userDefaultsPath = userDefaultsPath {
            NSWorkspace.shared.openFile(userDefaultsPath, withApplication: nil)
        }
    }
}
