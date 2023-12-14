//
//         FILE: day14.swift
//  DESCRIPTION: Advent of Code 2023 Day 14: Parabolic Reflector Dish
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/13/23 21:02:55
//

import Foundation
import Library

enum Space: Character { case empty = ".", rounded = "O", cube = "#" }

struct Platform: Hashable {
    let spaces: [[Space]]
    
    init( spaces: [[Space]] ) {
        self.spaces = spaces
    }
    
    init( lines: [String] ) {
        spaces = lines.map { $0.map { Space( rawValue: $0 )! } }
    }
    
    var weight: Int {
        spaces.enumerated()
            .map {
                let ( index, row ) = $0
                let rounded = row.filter { $0 == .rounded }.count
                return ( spaces.count - index ) * rounded
            }
            .reduce( 0, + )
    }
    
    func tiltNorth() -> Platform {
        var tilted = self.spaces
        
        for ( y, row ) in tilted.enumerated() {
            if y > 0 {
                for x in row.indices.filter( { row[$0] == .rounded } ) {
                    for yPrime in ( 0 ..< y ).reversed() {
                        guard tilted[yPrime][x] == .empty else { break }
                        tilted[yPrime][x] = .rounded
                        tilted[yPrime+1][x] = .empty
                    }
                }
            }
        }
        
        return Platform( spaces: tilted )
    }
    
    func tiltWest() -> Platform {
        var tilted = self.spaces
        
        for x in tilted[0].indices {
            if x > 0 {
                for y in tilted.indices.filter( { tilted[$0][x] == .rounded } ) {
                    for xPrime in ( 0 ..< x ).reversed() {
                        guard tilted[y][xPrime] == .empty else { break }
                        tilted[y][xPrime] = .rounded
                        tilted[y][xPrime+1] = .empty
                    }
                }
            }
        }
        
        return Platform( spaces: tilted )
    }
    
    func tiltSouth() -> Platform {
        var tilted = self.spaces
        
        for ( y, row ) in tilted.enumerated().reversed() {
            if y < tilted.count - 1 {
                for x in row.indices.filter( { row[$0] == .rounded } ) {
                    for yPrime in ( y + 1 ..< tilted.count ) {
                        guard tilted[yPrime][x] == .empty else { break }
                        tilted[yPrime][x] = .rounded
                        tilted[yPrime-1][x] = .empty
                    }
                }
            }
        }
        
        return Platform( spaces: tilted )
    }
    
    func tiltEast() -> Platform {
        var tilted = self.spaces
        
        for x in tilted[0].indices.reversed() {
            if x < tilted[0].count - 1 {
                for y in tilted.indices.filter( { tilted[$0][x] == .rounded } ) {
                    for xPrime in ( x + 1 ..< tilted.count ) {
                        guard tilted[y][xPrime] == .empty else { break }
                        tilted[y][xPrime] = .rounded
                        tilted[y][xPrime-1] = .empty
                    }
                }
            }
        }
        
        return Platform( spaces: tilted )
    }
    
    func cycle() -> Platform {
        tiltNorth().tiltWest().tiltSouth().tiltEast()
    }
}


func parse( input: AOCinput ) -> Platform {
    return Platform( lines: input.lines )
}

func part1( input: AOCinput ) -> String {
    let platform = parse( input: input ).tiltNorth()
    
    let weights = platform.spaces.enumerated().map {
        let ( index, row ) = $0
        let rounded = row.filter { $0 == .rounded }.count
        return ( platform.spaces.count - index ) * rounded
    }
    return "\( platform.weight )"
}


func part2( input: AOCinput ) -> String {
    let target = 1_000_000_000
    let platform = parse( input: input )
    var seen = [ platform : 0 ]
    var sequence = [ platform ]
    
    for step in 1 ... Int.max {
        let next = sequence.last!.cycle()
        if let cycleStart = seen[next] {
            let cycleLength = sequence.count - cycleStart
            let offset = cycleStart + ( target - cycleStart ) % cycleLength
            return "\( sequence[offset].weight )"
        }
        seen[next] = step
        sequence.append( next )
    }
    
    return "Should never get here"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
