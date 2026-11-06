//         FILE: ResultsView.swift
//  DESCRIPTION: mng - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2026 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 7/15/26 2:08 PM

import Foundation
import AppKit
import SwiftUI

struct SolutionItem: Identifiable {
    let id =    UUID()
    let name:   String
    let part1:  String
    let part2:  String
    let tests1: Bool
    let tests2: Bool
    
    init( result: Result ) {
        self.name   = result.name
        self.part1  = result.part1 ?? ""
        self.part2  = result.part2 ?? ""
        self.tests1 = result.tests1
        self.tests2 = result.tests2
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
        Table( solutions, sortOrder: $sortOrder ) {
            TableColumn( "Solution Name", value: \.name ) { Text( $0.name ) }
            .width( min: 100, ideal: 100, max: 150 ) // Ideal size increased slightly for readability
            
            TableColumn( "Part 1" ) { Text( $0.part1 ) }
            .width( 80 )
            
            TableColumn( "Part 2" ) { Text( $0.part2 ) }
            .width( 80 )

            TableColumn( "Part 1 Tests" ) { Text( $0.tests1 ? "✅" : "❌" ) }
            .width( 80 )
            
            TableColumn( "Part 2 Tests" ) { Text( $0.tests2 ? "✅" : "❌" ) }
            .width( 80 )
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
