//
//  DirectoryWatcher.swift
//  Markdown
//
//  Created by Luo Sheng on 15/10/31.
//  Copyright © 2015年 Pop Tap. All rights reserved.
//

import Foundation

public class DirectoryWatcher {
    
    enum Error: ErrorProtocol {
        case cannotOpenPath
        case cannotCreateSource
    }
    
    public typealias CompletionCallback = () -> ()
    
    var watchedURL: URL
    let eventMask: DispatchSource.FileSystemEvent
    public var completionCallback: CompletionCallback?
    private let queue = DispatchQueue(label: "com.pop-tap.directory-watcher", attributes: DispatchQueueAttributes.serial)
    private var source: DispatchSource?
    private var directoryChanging = false
    private var oldDirectoryInfo = [FileInfo?]()
    
    init(URL: Foundation.URL, eventMask: DispatchSource.FileSystemEvent = .write) {
        watchedURL = URL
        self.eventMask = eventMask
    }
    
    deinit {
        self.stop()
    }

    public func start() throws {
        guard source == nil else {
            return
        }
        
        guard let path = watchedURL.path else {
            return
        }
        
        let fd = open((path as NSString).fileSystemRepresentation, O_EVTONLY)
        guard fd >= 0 else {
            throw Error.cannotOpenPath
        }
        
        let cleanUp: () -> () = {
            close(fd)
        }
        
        guard let src = DispatchSource.fileSystemObject(fileDescriptor: fd, eventMask: eventMask, queue: queue) /*Migrator FIXME: Use DispatchSourceFileSystemObject to avoid the cast*/ as? DispatchSource else {
            cleanUp()
            throw Error.cannotCreateSource
        }
        source = src
        
        src.setEventHandler {
            self.waitForDirectoryToFinishChanging()
        }
        
        src.setCancelHandler(handler: cleanUp)
        
        src.resume()
    }
    
    public func stop() {
        guard let src = source else {
            return
        }
        
        src.cancel()
    }
    
    private func waitForDirectoryToFinishChanging() {
        if (!directoryChanging) {
            directoryChanging = true
            
            oldDirectoryInfo = self.directoryInfo()
//            print(oldDirectoryInfo)
            
            let timer = Timer(timeInterval: 0.5, target: self, selector: #selector(checkDirectoryInfo(_:)), userInfo: nil, repeats: true)
            RunLoop.main().add(timer, forMode: RunLoopMode.commonModes)
        }
    }
    
    private func directoryInfo() -> [FileInfo?] {
        do {
            let contents = try FileManager.default().contentsOfDirectory(at: watchedURL, includingPropertiesForKeys: FileInfo.prefetchedProperties, options: .skipsSubdirectoryDescendants)
            return contents.map { FileInfo(URL: $0) }
        } catch {
            return []
        }
    }
    
    @objc private func checkDirectoryInfo(_ timer: Timer) {
        let directoryInfo = self.directoryInfo()
        directoryChanging = directoryInfo != oldDirectoryInfo
        if directoryChanging {
            oldDirectoryInfo = directoryInfo
        } else {
            timer.invalidate()
            if let completion = completionCallback {
                completion()
            }
        }
    }
}
