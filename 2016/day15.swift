//
//         FILE: main.swift
//  DESCRIPTION: day15 - Timing is Everything
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/04/21 17:05:57
//

import Foundation

class Disc {
    let number: Int
    let positions: Int
    let initial: Int
    let start: Int
    
    init( number: Int, positions: Int, initial: Int ) {
        self.number = number
        self.positions = positions
        self.initial = initial
        start = ( positions * number - initial - number ) % positions
    }
    
    convenience init( line: String ) {
        let words = line.split( whereSeparator: { " #.".contains($0) } )
        
        self.init( number: Int( words[1] )!, positions: Int( words[3] )!, initial: Int( words[11] )! )
    }
    
    func combine( with next: Disc ) -> Disc {
        var newStart = start
        
        while newStart % next.positions != next.start {
            newStart += positions
        }
        
        let newPositions = positions * next.positions
        let newInitial = ( newPositions * number - number - newStart ) % newPositions
        
        return Disc( number: number, positions: newPositions, initial: newInitial )
    }
}


func parse( input: AOCinput ) -> [Disc] {
    return input.lines.map { Disc( line: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let disks = parse( input: input )
    let composite = disks[2...].reduce( into: disks[0].combine( with: disks[1] ) ) {
        $0 = $0.combine( with: $1 )
    }

    return "\(composite.start)"
}


func part2( input: AOCinput ) -> String {
    let disks = parse( input: input )
    let newDisk = Disc( number: disks.last!.number + 1, positions: 11, initial: 0 )
    let composite = disks[2...].reduce( into: disks[0].combine( with: disks[1] ) ) {
        $0 = $0.combine( with: $1 )
    }.combine( with: newDisk )

    return "\(composite.start)"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
