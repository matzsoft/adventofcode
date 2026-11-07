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
                    self.color = Color.green
                } else if milliseconds < 10000 {
                    self.color = Color.yellow
                } else {
                    self.color = Color.red
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

struct ResultsView: View {
    let data: SolutionDisplayResults // Pass your analyzed data here
    
    @SwiftUI.State private var solutions: [SolutionItem] = []
    @SwiftUI.State private var sortOrder = [ KeyPathComparator( \SolutionItem.name ) ]

    init( data: SolutionDisplayResults ) {
        self.data = data
        _solutions = SwiftUI.State( initialValue: data.results.map { SolutionItem( result: $0 ) } )
    }

    var body: some View {
        VStack( spacing: 20 ) {
            Table( solutions, sortOrder: $sortOrder ) {
                TableColumn( "Solution Name", value: \.name ) { Text( $0.name ) }
                    .width( min: 100, ideal: 100, max: 150 ) // Ideal size increased slightly for readability
                
                TableColumn( "Part 1" ) { Text( $0.part1.value ).background( $0.part1.color.opacity( 0.3 ) ) }
                    .width( 80 )
                
                TableColumn( "Part 2" ) { Text( $0.part2.value ).background( $0.part2.color.opacity( 0.3 ) ) }
                    .width( 80 )
                
                TableColumn( "Part 1 Tests" ) { Text( $0.tests1 ) }
                    .width( 80 )
                
                TableColumn( "Part 2 Tests" ) { Text( $0.tests2 ) }
                    .width( 80 )
            }
            HStack {
                Spacer()
                Button( "Close" ) { NSApp.terminate( nil ) }
                .keyboardShortcut( .defaultAction )
            }
        }
        .padding()
        .frame(
            minWidth: 600,
            idealWidth: 600,
            maxWidth: 800,
            minHeight: 300,
            idealHeight: 400,
        )
    }
}
