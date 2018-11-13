//
//  Simulator.swift
//  OpenSim
//
//  Created by Fernando Bunn on 13/11/18.
//  Copyright © 2018 Luo Sheng. All rights reserved.
//

import Foundation

struct Simulator: Decodable {
    private let rawData: [String: [Device]]
    public let runtimes: [Runtime]
    
    enum CodingKeys: String, CodingKey {
        case rawData = "devices"
        case runtimes
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        rawData = try values.decode([String: [Device]].self, forKey: .rawData)
        
        var runtimeList: [Runtime] = []
        for (key, devices) in rawData {
            runtimeList.append(Runtime(name: key, devices: devices))
        }
        runtimes = runtimeList
    }
}
