//
//         FILE: main.swift
//  DESCRIPTION: day18 - Like a Rogue
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/08/21 17:35:22
//

import Foundation

enum Tile: Character, CaseIterable {
    case safe = ".", trap = "^"
}

class Row {
    static let traps = Set( [ "^^.", ".^^", "^..", "..^" ] )
    let row: [Character]
    
    init( row: String ) {
        self.row = Array( row )
    }
    
    func getDeterminant( index: Int ) -> Character {
        var value: [Character] = []
        
        value.append( index == 0 ? Tile.safe.rawValue : row[ index - 1 ] )
        value.append( row[index] )
        value.append( index == row.count - 1 ? Tile.safe.rawValue : row[ index + 1 ] )
        
        return Row.traps.contains( String( value ) ) ? Tile.trap.rawValue : Tile.safe.rawValue
    }
    
    var nextRow: Row {
        return Row( row: String( (0 ..< row.count).map { getDeterminant( index: $0 ) } ) )
    }

    var countSafes: Int {
        return row.filter { $0 == Tile.safe.rawValue }.count
    }
}


func countSafes( row: Row, rowCount: Int ) -> Int {
    var count = row.countSafes
    var next = row
    
    for _ in 2 ... rowCount {
        next = next.nextRow
        count += next.countSafes
    }
    
    return count
}


func part1( input: AOCinput ) -> String {
    return "\(countSafes( row: Row( row: input.line ), rowCount: 40 ))"
}


func part2( input: AOCinput ) -> String {
    return "\(countSafes( row: Row( row: input.line ), rowCount: 400000 ))"
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
