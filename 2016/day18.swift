//
//  main.swift
//  day18
//
//  Created by Mark Johnson on 1/4/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let inputRows = 40
let input = "^^.^..^.....^..^..^^...^^.^....^^^.^.^^....^.^^^...^^^^.^^^^.^..^^^^.^^.^.^.^.^.^^...^^..^^^..^.^^^^"
let tests = [
    ( in: "..^^.", rows: 3, safe: 6 ),
    ( in: ".^^.^.^^^^", rows: 10, safe: 38 ),
]


extension String {
    subscript( offset: Int ) -> Character {
        return self[ self.index( self.startIndex, offsetBy: offset ) ]
    }
}

enum Tile: Character, CaseIterable {
    case safe = ".", trap = "^"
}

class Row {
    static let traps = Set( [ "^^.", ".^^", "^..", "..^" ] )
    let row: String
    
    init( row: String ) {
        self.row = row
    }
    
    func getDeterminant( index: Int ) -> Character {
        var value: [Character] = []
        
        if index == 0 {
            value.append( Tile.safe.rawValue )
        } else {
            value.append( row[ index - 1 ] )
        }
        
        value.append( row[index] )
        
        if index == row.count - 1 {
            value.append( Tile.safe.rawValue )
        } else {
            value.append( row[ index + 1 ] )
        }
        
        return Row.traps.contains( String( value ) ) ? Tile.trap.rawValue : Tile.safe.rawValue
    }
    
    func nextRow() -> Row {
        let next = String( (0 ..< row.count).map { getDeterminant(index: $0) } )
        
        return Row( row: next )
    }
    
    func countSafes() -> Int {
        return row.filter { $0 == Tile.safe.rawValue }.count
    }
}


func countSafes( row: Row, rowCount: Int ) -> Int {
    var count = row.countSafes()
    var next = row
    
    for _ in 2 ... rowCount {
        next = next.nextRow()
        count += next.countSafes()
    }
    
    return count
}

for test in tests {
    let result = countSafes( row: Row(row: test.in), rowCount: test.rows )
    
    if result != test.safe {
        print( "Test '\(test.in)' failed" )
        exit(1)
    }
}

print( "Part1:", countSafes( row: Row(row: input), rowCount: inputRows ) )
print( "Part2:", countSafes( row: Row(row: input), rowCount: 400000 ) )
