//
//  utils.swift
//  Functions used by multiple other files
//
//  Created by Mark Johnson on 3/30/23.
//  Copyright © 2023 matzsoft. All rights reserved.
//

import Foundation

func determinePackage( package: String ) -> String? {
    guard let url = URL( string: package ) else { return nil }
    var package = url.deletingPathExtension().lastPathComponent

    if package.hasPrefix( "day" ) { package = String( package.dropFirst( 3 ) ) }
    if package.hasPrefix( "-" ) { return nil }
    if package.hasSuffix( "-" ) { return nil }

    let splits = package.split( separator: "-" )
    if splits.isEmpty { return nil }
    
    guard let value = Int( splits[0] ) else { return nil }
    guard value < 26 else { return nil }
    
    let base = [ String( format: "day%02d", value ) ]
    let suffix = splits.dropFirst().map { String( $0 ) }
    return ( base + suffix ).joined( separator: "-" )
}


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


extension URL {
    func relativePath( from base: URL ) -> String? {
        // Ensure that both URLs represent files:
        guard self.isFileURL && base.isFileURL else { return nil }

        // Remove/replace "." and "..", make paths absolute:
        let destComponents = self.standardized.pathComponents
        let baseComponents = base.standardized.pathComponents

        // Find number of common path components:
        let smallest = min( destComponents.count, baseComponents.count )
        let common = ( 0 ..< smallest ).firstIndex { destComponents[$0] != baseComponents[$0] } ?? smallest

        // Build relative path:
        let prefix = Array( repeating: "..", count: baseComponents.count - common )
        return ( prefix + destComponents[common...] ).joined( separator: "/" )
    }
}

