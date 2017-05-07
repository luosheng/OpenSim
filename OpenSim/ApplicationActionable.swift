//
//  ApplicationActionable.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

protocol ApplicationActionable {
    
    var title: String { get }
    
    var icon: NSImage { get }
    
    var isAvailable: Bool { get }
    
    func perform(with application: Application)
    
}
