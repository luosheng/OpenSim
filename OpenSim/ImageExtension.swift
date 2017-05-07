//
//  ImageExtension.swift
//  OpenSim
//
//  Created by Luo Sheng on 6/22/16.
//  Copyright © 2016 Luo Sheng. All rights reserved.
//

import Foundation
import Cocoa

struct IconImageConstants {
    static let size = NSSize(width: 32, height: 32)
    static let cornerRadius: CGFloat = 5
}

func templatize(_ image: NSImage) -> NSImage {
    image.isTemplate = true
    return image
}

extension NSImage {
    
    func appIcon() -> NSImage? {
        guard self.isValid else {
            return nil
        }
        let newImage = NSImage(size: IconImageConstants.size)
        newImage.lockFocus()
        self.size = IconImageConstants.size
        NSGraphicsContext.current()?.imageInterpolation = .high
        
        NSGraphicsContext.saveGraphicsState()
        let path = NSBezierPath(roundedRect: NSRect(origin: NSPoint.zero, size: size), xRadius: IconImageConstants.cornerRadius, yRadius: IconImageConstants.cornerRadius)
        path.addClip()
        self.draw(at: NSPoint.zero, from: NSRect(origin: NSPoint.zero, size: size), operation: .copy, fraction: 1.0)
        NSGraphicsContext.restoreGraphicsState()
        
        newImage.unlockFocus()
        return newImage
    }
}
