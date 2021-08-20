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

enum Tile: Character { case safe = ".", trap = "^" }

// I used to represent the traps as:
//    static let traps = [ "^^.", ".^^", "^..", "..^" ]
// But notice that this simplifies to "The one on the left is not equal to the one on the right".
// This simplification cut my run times in half.
// Also I tried to exploit the cyclic nature of the algorithm,
// but the cycle length is greater than the part2 row count.
//

struct Row {
    let row: [Tile]
    
    init( row: String ) {
        self.row = row.map { Tile( rawValue: $0 )! }
    }
    
    init( row: [Tile] ) {
        self.row = row
    }
    
    func getDeterminant( index: Int ) -> Tile {
        let left = index == 0 ? Tile.safe : row[ index - 1 ]
        let right = index == row.count - 1 ? Tile.safe : row[ index + 1 ]
        
        return left != right ? Tile.trap : Tile.safe
    }
    
    var nextRow: Row {
        return Row( row: ( 0 ..< row.count ).map { getDeterminant( index: $0 ) } )
    }

    var countSafes: Int {
        return row.filter { $0 == Tile.safe }.count
    }
}


func countSafes( row: Row, rowCount: Int ) -> Int {
    var safeCount = 0
    var next = row
    
    for _ in 0 ..< rowCount {
        safeCount += next.countSafes
        next = next.nextRow
    }
    
    return safeCount
}


func part1( input: AOCinput ) -> String {
    return "\( countSafes( row: Row( row: input.line ), rowCount: Int( input.extras[0] )! ) )"
}


func part2( input: AOCinput ) -> String {
    return "\( countSafes( row: Row( row: input.line ), rowCount: Int( input.extras[1] )! ) )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
