//
//  Helper.swift
//  OpenSim
//
//  Created by Bradley Van Dyk on 3/4/16.
//  Copyright © 2016 Luo Sheng. All rights reserved.
//

import Foundation

func shell(_ launchPath: String, arguments: [String]) -> String
{
    let task = Task()
    task.launchPath = launchPath
    task.arguments = arguments
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: String.Encoding.utf8)!
    
    return output
}
