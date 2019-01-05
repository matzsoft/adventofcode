//
//  main.swift
//  day15
//
//  Created by Mark Johnson on 1/2/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let test1 = """
Disc #1 has 5 positions; at time=0, it is at position 4.
Disc #2 has 2 positions; at time=0, it is at position 1.
"""
let input = """
Disc #1 has 13 positions; at time=0, it is at position 10.
Disc #2 has 17 positions; at time=0, it is at position 15.
Disc #3 has 19 positions; at time=0, it is at position 17.
Disc #4 has 7 positions; at time=0, it is at position 1.
Disc #5 has 5 positions; at time=0, it is at position 0.
Disc #6 has 3 positions; at time=0, it is at position 1.
"""

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
    
    convenience init( line: Substring ) {
        let words = line.split( whereSeparator: { " #.".contains($0) } )
        
        self.init(number: Int( words[1] )!, positions: Int( words[3] )!, initial: Int( words[11] )!)
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

func parse( input: String ) -> [Disc] {
    let lines = input.split(separator: "\n")
    var result: [Disc] = []
    
    for line in lines {
        result.append( Disc(line: line) )
    }
    
    return result
}


let disks = parse(input: input)
var composite = disks[0].combine(with: disks[1])

if disks.count > 2 {
    for disk in disks[2...] {
        composite = composite.combine(with: disk)
    }
}

print( "Part1:", composite.start )

let newDisk = Disc(number: disks.last!.number + 1, positions: 11, initial: 0)

composite = composite.combine(with: newDisk)
print( "Part2:", composite.start )
