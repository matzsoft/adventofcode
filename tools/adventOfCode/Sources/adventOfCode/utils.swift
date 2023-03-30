//
//  utils.swift
//  Functions used by multiple other files
//
//  Created by Mark Johnson on 3/30/23.
//  Copyright © 2023 matzsoft. All rights reserved.
//

import Foundation

struct FileHandlerOutputStream: TextOutputStream {
    private let fileHandle: FileHandle
    let encoding: String.Encoding

    init( _ fileHandle: FileHandle, encoding: String.Encoding = .utf8) {
        self.fileHandle = fileHandle
        self.encoding = encoding
    }

    mutating func write(_ string: String) {
        if let data = string.data( using: encoding) {
            fileHandle.write( data )
        }
    }
}


func getString( prompt: String, preferred: String? ) -> String {
    let defaultPrompt = preferred == nil ? ": " : " [\(preferred!)]: "
    
    while true {
        print( "\(prompt)\(defaultPrompt)", terminator: "" )
        
        let answer = readLine( strippingNewline: true )
        
        if answer != nil && answer! != "" { return answer! }
        if preferred != nil { return preferred! }
    }
}


func shell( stdout: FileHandle? = nil, _ args: String... ) -> Int32 {
    let task = Process()
    
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    if let stdout = stdout {
        task.standardOutput = stdout
    }
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}


func askYN( prompt: String, expected: Bool ) -> Bool {
    let defaultPrompt = expected ? " [Y/n]? " : " [y/N]? "
    
    while true {
        print( "\(prompt)\(defaultPrompt)", terminator: "" )
        
        let answer = readLine( strippingNewline: true )
        
        guard let value = answer else { return expected }
        if value.isEmpty { return expected }
        if value.first!.lowercased() == "y" { return true }
        if value.first!.lowercased() == "n" { return false }
    }
}
