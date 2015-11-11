//
//  DirectoryWatcher.swift
//  Markdown
//
//  Created by Luo Sheng on 15/10/31.
//  Copyright © 2015年 Pop Tap. All rights reserved.
//

import Foundation

public class DirectoryWatcher {
    
    enum Error: ErrorType {
        case CannotOpenPath
        case CannotCreateSource
    }
    
    public typealias CompletionCallback = () -> ()
    
    var watchedURL: NSURL
    public var completionCallback: CompletionCallback?
    private let queue = dispatch_queue_create("com.pop-tap.directory-watcher", DISPATCH_QUEUE_SERIAL)
    private var source: dispatch_source_t?
    private var directoryChanging = false
    private var oldDirectoryInfo = [FileInfo?]()
    
    init(URL: NSURL) {
        watchedURL = URL
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
            throw Error.CannotOpenPath
        }
        
        let cleanUp: () -> () = {
            close(fd)
        }
        
        guard let src = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, UInt(fd), DISPATCH_VNODE_WRITE, queue) else {
            cleanUp()
            throw Error.CannotCreateSource
        }
        source = src
        
        dispatch_source_set_event_handler(src) {
            self.waitForDirectoryToFinishChanging()
        }
        
        dispatch_source_set_cancel_handler(src, cleanUp)
        
        dispatch_resume(src)
    }
    
    public func stop() {
        guard let src = source else {
            return
        }
        
        dispatch_source_cancel(src)
    }
    
    private func waitForDirectoryToFinishChanging() {
        if (!directoryChanging) {
            directoryChanging = true
            
            oldDirectoryInfo = self.directoryInfo()
            print(oldDirectoryInfo)
            
            let timer = NSTimer(timeInterval: 0.5, target: self, selector: "checkDirectoryInfo:", userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        }
    }
    
    private func directoryInfo() -> [FileInfo?] {
        do {
            let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(watchedURL, includingPropertiesForKeys: FileInfo.prefetchedProperties, options: .SkipsSubdirectoryDescendants)
            return contents.map { FileInfo(URL: $0) }
        } catch {
            return []
        }
    }
    
    @objc private func checkDirectoryInfo(timer: NSTimer) {
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