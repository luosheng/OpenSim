//
//  Helper.swift
//  OpenSim
//
//  Created by Bradley Van Dyk on 3/4/16.
//  Copyright © 2016 Luo Sheng. All rights reserved.
//

import Foundation

func shell(launchPath: String, arguments: [String]) -> String
{
    let task = NSTask()
    task.launchPath = launchPath
    task.arguments = arguments
    
    let pipe = NSPipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: NSUTF8StringEncoding)!
    
    return output
}