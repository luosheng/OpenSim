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
        URLResourceKey.nameKey,
        URLResourceKey.isDirectoryKey,
        URLResourceKey.creationDateKey,
        URLResourceKey.contentModificationDateKey,
        URLResourceKey.fileSizeKey,
    ].map { $0.rawValue }
    
    private enum Error: ErrorProtocol {
        case invalidProperty
    }
    
    let name: String
    let isDirectory: Bool
    let creationDate: Date
    let modificationDate: Date
    let fileSize: Int
    
    init?(URL: Foundation.URL) {
        do {
            var nameObj: AnyObject?
            try (URL as NSURL).getResourceValue(&nameObj, forKey: URLResourceKey.nameKey)
            
            var isDirectoryObj: AnyObject?
            try (URL as NSURL).getResourceValue(&isDirectoryObj, forKey: URLResourceKey.isDirectoryKey)
            
            var creationDateObj: AnyObject?
            try (URL as NSURL).getResourceValue(&creationDateObj, forKey: URLResourceKey.creationDateKey)
            
            var modificationDateObj: AnyObject?
            try (URL as NSURL).getResourceValue(&modificationDateObj, forKey: URLResourceKey.contentModificationDateKey)
            
            var fileSizeObj: AnyObject?
            try (URL as NSURL).getResourceValue(&fileSizeObj, forKey: URLResourceKey.fileSizeKey)
            
            guard let name = nameObj as? String,
                isDirectory = isDirectoryObj as? Bool,
                creationDate = creationDateObj as? Date,
                modificationDate = modificationDateObj as? Date,
                fileSize = isDirectory ? 0 : fileSizeObj as? Int else {
                    throw Error.invalidProperty
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
    case (.some(let lhs), .some(let rhs)):
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
