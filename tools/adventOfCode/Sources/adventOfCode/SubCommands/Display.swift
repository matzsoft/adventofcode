//         FILE: Display.swift
//  DESCRIPTION: adventOfCode - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2026 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 11/6/26 1:49 PM

import Foundation
import AppKit
import ArgumentParser
import MATZMiscSwiftLibrary

extension AdventOfCode {
    struct Display: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Display results.json showing the results of the solutions in a year directory."
        )
        
        func run() async throws -> Void {
            let fileManager = FileManager.default
            let resultsURL = URL( fileURLWithPath: "result.json" )
            
            guard fileManager.fileExists( atPath: resultsURL.path() ) else {
                throw RuntimeError( "\(resultsURL.path) does not exist." )
            }
            
            let json = try Data( contentsOf: resultsURL )
            let results = try JSONDecoder().decode( [Result].self, from: json )
            let year = URL( fileURLWithPath: fileManager.currentDirectoryPath ).lastPathComponent
            let displayResults = SolutionDisplayResults( year: year, results: results )
            
            await MainActor.run {
                // Step 2: Set up the AppKit environment
                let app = NSApplication.shared
                
                // Required for CLI tools to behave as an app with a UI
                app.setActivationPolicy( .regular )
                
                // Step 3: Instantiate and link the delegate
                let delegate = AppDelegate( data: displayResults )
                app.delegate = delegate
                
                // Step 4: Start the application run loop
                // This blocks the command line tool from exiting until NSApp.terminate() is called
                app.run()
            }
        }
    }
}


struct SolutionDisplayResults {
    let year: String
    let results: [Result]
}
