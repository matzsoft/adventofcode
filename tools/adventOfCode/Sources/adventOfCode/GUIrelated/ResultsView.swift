//         FILE: ResultsView.swift
//  DESCRIPTION: mng - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2026 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 7/15/26 2:08 PM

import Foundation
import Library
import AppKit
import SwiftUI

struct SolutionItem: Identifiable {
    struct Part {
        let value: String
        let color: Color
        
        init( value: String? ) {
            if value == nil {
                self.value = ""
                self.color = Color.white
            } else {
                let value = value!
                let milliseconds = decodeElapsed( formatted: value )
                
                self.value = value
                
                if milliseconds < 1000 {
                    self.color = Color.green.opacity( 0.3 )
                } else if milliseconds < 10000 {
                    self.color = Color.yellow.opacity( 0.4 )
                } else {
                    self.color = Color.red.opacity( 0.3 )
                }
            }
        }
    }
    
    let id =    UUID()
    let name:   String
    let part1:  Part
    let part2:  Part
    let tests1: String
    let tests2: String
    
    init( result: Result ) {
        func test( status: Result.Test ) -> String {
            switch status {
            case .none:
                return "⚠️"
            case .good:
                return "✅"
            case .bad:
                return "❌"
            }
        }
        self.name   = result.name
        self.part1  = Part( value: result.part1 )
        self.part2  = Part( value: result.part2 )
        self.tests1 = test( status: result.tests1 )
        self.tests2 = test( status: result.tests2 )
    }
}

class WindowHolder {
    weak var window: NSWindow?
}

struct ResultsView: View {
    let data: SolutionDisplayResults // Pass your analyzed data here
    let windowHolder: WindowHolder
    
    @SwiftUI.State private var solutions: [SolutionItem] = []
    @SwiftUI.State private var sortOrder = [ KeyPathComparator( \SolutionItem.name ) ]

    init( data: SolutionDisplayResults, windowHolder: WindowHolder ) {
        self.data = data
        self.windowHolder = windowHolder
        _solutions = SwiftUI.State( initialValue: data.results.map { SolutionItem( result: $0 ) } )
    }

    var body: some View {
        VStack( spacing: 20 ) {
            Grid( alignment: .leading, horizontalSpacing: 0, verticalSpacing: 0 ) {
                GridRow {
                    cell( "Solution Name" )
                    cell( "Part 1" )
                    cell( "Part 2" )
                    cell( "Part 1 Tests" )
                    cell( "Part 2 Tests" )
                }
                .fontWeight( .semibold )

                Divider()
                    .gridCellUnsizedAxes( .horizontal )

                ForEach( Array( solutions.enumerated() ), id: \.element.id ) { index, solution in
                    GridRow {
                        cell( solution.name )
                        cell( solution.part1.value )
                            .background( solution.part1.color )
                        cell( solution.part2.value )
                            .background( solution.part2.color )
                        cell( solution.tests1, alignment: .center )
                        cell( solution.tests2, alignment: .center )
                    }
                    .background( rowBackground( for: index ) )
                }
            }
            .fixedSize()
            HStack {
                Spacer()
                Button( "Close" ) {
                    if let window = windowHolder.window {
                        captureWindowAndTerminate( window: window )
                    } else {
                        NSApp.terminate( nil )
                    }
                }
                .keyboardShortcut( .defaultAction )
            }
        }
        .padding( 20 )
        .fixedSize()
    }

    private func cell( _ text: String, alignment: Alignment = .leading ) -> some View {
        Text( text )
            .fixedSize( horizontal: true, vertical: false )
            .padding( .horizontal, 12 )
            .padding( .vertical, 4 )
            .frame( maxWidth: .infinity, alignment: alignment )
    }

    private func rowBackground( for index: Int ) -> Color {
        let colors = NSColor.alternatingContentBackgroundColors
        return Color( nsColor: colors[ index % colors.count ] )
    }

    @MainActor
    private func captureWindowAndTerminate( window: NSWindow ) {
        let currentDirectory = FileManager.default.currentDirectoryPath
        let outputURL = URL( fileURLWithPath: currentDirectory ).appendingPathComponent( "status.png" )
        
        // 1. Target the window's core frame layer
        guard let windowGraphicsFrameView = window.contentView?.superview else {
            NSApp.terminate( nil )
            return
        }
        
        let frameBounds = windowGraphicsFrameView.bounds
        
        // 2. Generate a local bitmap container matching the full window context frame
        guard let bitmapRep = windowGraphicsFrameView.bitmapImageRepForCachingDisplay( in: frameBounds ) else {
            NSApp.terminate( nil )
            return
        }
        
        // 3. Directly cache the visual presentation data locally without querying the window server
        windowGraphicsFrameView.cacheDisplay( in: frameBounds, to: bitmapRep )
        
        // 4. Convert to PNG data and save
        if let pngData = bitmapRep.representation( using: .png, properties: [:] ) {
            do {
                try pngData.write( to: outputURL )
                print( "Window captured successfully to: \(outputURL.path)" )
            } catch {
                print( "Failed to write image to disk: \(error.localizedDescription)" )
            }
        }
        
        // 5. Terminate the app instantly
        NSApp.terminate( nil )
    }
}
