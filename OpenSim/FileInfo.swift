//
//  FileInfo.swift
//  Markdown
//
//  Created by Luo Sheng on 15/11/1.
//  Copyright © 2015年 Pop Tap. All rights reserved.
//

import Foundation

struct FileInfo {
    
    static let prefetchedProperties = [
        NSURLNameKey,
        NSURLIsDirectoryKey,
        NSURLCreationDateKey,
        NSURLContentModificationDateKey,
        NSURLFileSizeKey,
    ]
    
    private enum Error: ErrorType {
        case InvalidProperty
    }
    
    let name: String
    let isDirectory: Bool
    let creationDate: NSDate
    let modificationDate: NSDate
    let fileSize: Int
    
    init?(URL: NSURL) {
        do {
            var nameObj: AnyObject?
            try URL.getResourceValue(&nameObj, forKey: NSURLNameKey)
            
            var isDirectoryObj: AnyObject?
            try URL.getResourceValue(&isDirectoryObj, forKey: NSURLIsDirectoryKey)
            
            var creationDateObj: AnyObject?
            try URL.getResourceValue(&creationDateObj, forKey: NSURLCreationDateKey)
            
            var modificationDateObj: AnyObject?
            try URL.getResourceValue(&modificationDateObj, forKey: NSURLContentModificationDateKey)
            
            var fileSizeObj: AnyObject?
            try URL.getResourceValue(&fileSizeObj, forKey: NSURLFileSizeKey)
            
            guard let name = nameObj as? String,
                isDirectory = isDirectoryObj as? Bool,
                creationDate = creationDateObj as? NSDate,
                modificationDate = modificationDateObj as? NSDate,
                fileSize = isDirectory ? 0 : fileSizeObj as? Int else {
                    throw Error.InvalidProperty
            }
            self.name = name
            self.isDirectory = isDirectory
            self.creationDate = creationDate
            self.modificationDate = modificationDate
            self.fileSize = fileSize
        } catch {
            return nil
        }
    }
    
}

extension FileInfo: Equatable {}

func ==(lhs: FileInfo, rhs: FileInfo) -> Bool {
    return lhs.name == rhs.name &&
        lhs.isDirectory == rhs.isDirectory &&
        lhs.creationDate == rhs.creationDate &&
        lhs.modificationDate == rhs.modificationDate &&
        lhs.fileSize == rhs.fileSize
}

func ==(lhs: FileInfo?, rhs: FileInfo?) -> Bool {
    switch (lhs, rhs) {
    case (.Some(let lhs), .Some(let rhs)):
        return lhs == rhs
    case (nil, nil):
        // When two optionals are both nil, we consider them not equal
        return false
    default:
        return false
    }
}

func !=(lhs: FileInfo?, rhs: FileInfo?) -> Bool {
    return !(lhs == rhs)
}

func ==(lhs: [FileInfo?], rhs: [FileInfo?]) -> Bool {
    return lhs.elementsEqual(rhs) { $0 == $1 }
}

func !=(lhs: [FileInfo?], rhs: [FileInfo?]) -> Bool {
    return !(lhs == rhs)
}
