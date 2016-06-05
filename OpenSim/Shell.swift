//
//  Shell.swift
//  OpenSim
//
//  Created by Hamdullah Shah on 05/06/2016.
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