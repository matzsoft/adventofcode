//
//  main.swift
//  day13
//
//  Created by Mark Johnson on 12/12/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

struct Bus {
    let id: Int
    let offset: Int
    let arrival: Int
    
    init( id: Substring, offset: Int ) {
        self.id = Int( id )!
        self.offset = offset
        arrival = ( earliest + self.id - 1 ) / self.id * self.id
    }
}


struct Cycle {
    let start: Int
    let increment: Int
    
    func combine( id: Int, offset: Int ) -> Cycle {
        for current in stride( from: start, to: Int.max, by: increment ) {
            if ( current + offset ) % id == 0 {
                return Cycle( start: current, increment: increment * id )
            }
        }
        
        return self
    }
}


let inputFile = "/Users/markj/Development/adventofcode/2020/input/day13.txt"
let lines = try String( contentsOfFile: inputFile ).split( separator: "\n" )
let earliest = Int( lines[0] )!
let buses = lines[1].split( separator: "," ).enumerated().filter { $0.element != "x" }.map {
    Bus( id: $0.element, offset: $0.offset )
}
let first = buses.min { $0.arrival < $1.arrival }!
let part2 = buses.reduce( Cycle( start: 0, increment: 1 ) ) { $0.combine( id: $1.id, offset: $1.offset ) }

print( "Part 1: \(first.id * ( first.arrival - earliest ))" )
print( "Part 2: \(part2.start)" )
