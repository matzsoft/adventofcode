//
//         FILE: main.swift
//  DESCRIPTION: day13 - Shuttle Search
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/26/21 11:40:43
//

import Foundation

struct Bus {
    let id: Int
    let offset: Int
    let arrival: Int
    
    init( id: Substring, offset: Int, earliest: Int ) {
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


func parse( input: AOCinput ) -> ( Int, [Bus] ) {
    let earliest = Int( input.lines[0] )!
    let buses = input.lines[1].split( separator: "," ).enumerated().filter { $0.element != "x" }.map {
        Bus( id: $0.element, offset: $0.offset, earliest: earliest )
    }
    
    return ( earliest, buses )
}


func part1( input: AOCinput ) -> String {
    let ( earliest, buses ) = parse( input: input )
    let first = buses.min { $0.arrival < $1.arrival }!
    
    return "\( first.id * ( first.arrival - earliest ) )"
}


func part2( input: AOCinput ) -> String {
    let ( _, buses ) = parse( input: input )
    let cycle = buses.reduce( Cycle( start: 0, increment: 1 ) ) {
        $0.combine( id: $1.id, offset: $1.offset )
    }
    return "\( cycle.start )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
