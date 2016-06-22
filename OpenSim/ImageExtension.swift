//
//  ImageExtension.swift
//  OpenSim
//
//  Created by Luo Sheng on 6/22/16.
//  Copyright © 2016 Luo Sheng. All rights reserved.
//

import Foundation
import Cocoa

extension NSImage {
    func resize(size: NSSize) -> NSImage? {
        guard self.isValid else {
            return nil
        }
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        self.size = size
        NSGraphicsContext.current()?.imageInterpolation = .high
        self.draw(at: NSPoint.zero, from: NSRect(origin: NSPoint.zero, size: size), operation: .copy, fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }
}
