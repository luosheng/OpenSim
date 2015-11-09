//
//  DeviceApplicationPar.swift
//  SimPholders
//
//  Created by Luo Sheng on 15/11/9.
//  Copyright © 2015年 Luo Sheng. All rights reserved.
//

import Foundation

final class DeviceApplicationPair {
    
    let device: Device
    let application: Application
    
    init(device: Device, application: Application) {
        self.device = device
        self.application = application
    }
    
}