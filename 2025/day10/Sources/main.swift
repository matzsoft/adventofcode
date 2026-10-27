//
//         FILE: day10.swift
//  DESCRIPTION: Advent of Code 2025 Day 10: Factory
//        NOTES: Part 2 made possible by the observations brilliantly
//               described by reddit user tenthmascot at:
//               https://www.reddit.com/r/adventofcode/comments/1pk87hl/2025_day_10_part_2_bifurcate_your_way_to_victory/
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2025 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/09/25 21:19:48
//

import Foundation
import Library

struct Path: Hashable {
    let path: Set<Int>
    let presses: Int
    let joltages: [Int]
    
    init( count: Int ) {
        self.path = []
        self.presses = 0
        self.joltages = Array( repeating: 0 , count: count )
    }

    init( path: Set<Int>, presses: Int, joltages: [Int] ) {
        self.path = path
        self.presses = presses
        self.joltages = joltages
    }
    
    func press( affected: [Int], index: Int ) -> Path {
        var joltages = self.joltages
        
        for index in affected {
            joltages[index] += 1
        }
        
        return Path( path: path.union( [ index ] ), presses: presses + 1, joltages: joltages )
    }
}


struct Machine {
    let lightsCount: Int
    let lights: Int
    let joltages: [Int]
    let buttons: [[Int]]
    
    init( line: String ) {
        let fields = line.split( separator: " " )
        
        lightsCount = fields[0].count - 2
        lights = fields[0].dropFirst().dropLast().reduce( 0 ) {
            ( $0 << 1 ) | ( $1 == "#" ? 1 : 0 )
        }
        joltages = fields.last!
            .split( whereSeparator: { "{},".contains( $0 ) } )
            .map { Int( String( $0 ) )! }
        
        let buttons = fields.dropFirst().dropLast()
        self.buttons = buttons.map {
            $0.split( whereSeparator: { "(),".contains($0) } ).map { Int( String( $0 ) )! }
        }
    }
    
    func configureLights( to desired: Int, first: Bool = true ) -> [Path] {
        var queue = [ Path( count: lightsCount ) ]
        var seen = Set<Set<Int>>()
        var results: [Path] = []
        
        while !queue.isEmpty {
            let path = queue.removeFirst()
            
            if path.joltages.reduce( 0, { $0 << 1 | $1 & 1 } ) == desired {
                if first { return [path] }
                results.append( path )
            }

            for ( index, button ) in buttons.enumerated() {
                if !path.path.contains( index ) {
                    let newPath = path.press( affected: button, index: index )
                    
                    if seen.insert( newPath.path ).inserted {
                        queue.append( newPath )
                    }
                }
            }
        }

        return results
    }
    
    func allPaths() -> [[Path]] {
        let all = 1 << lightsCount
        
        return ( 0 ..< all ).reduce( into: [[Path]]() ) { paths, desired in
            paths.append( configureLights( to: desired, first: false ) )
        }
    }
    
    func configureJoltage( to desired: [Int] ) -> Int {
        var cache = [ Array( repeating: 0, count: joltages.count ) : 0 ]

        let allPaths = allPaths()
        
        func configure( to desired: [Int] ) -> Int {
            if let cached = cache[desired] { return cached }
            let desiredLights = desired.reduce( 0 ) { $0 << 1 | $1 & 1 }
            let paths = allPaths[desiredLights]
            
            let nextLevel = paths.reduce( into: [Int]() ) { nextLevel, path in
                if zip( desired, path.joltages ).allSatisfy( { $0.0 >= $0.1 } ) {
                    let newDesired = zip( desired, path.joltages ).map {
                        ( $0.0 - $0.1 ) / 2
                    }
                    let result = configure( to: newDesired )
                    nextLevel.append( path.path.count + 2 * result )
                }
            }
            
            let result = nextLevel.min() ?? Int( Int32.max )
            cache[desired] = result
            return result
        }

        let result = configure( to: desired )
        return result
    }

}


func part1( input: AOCinput ) -> String {
    let machines = input.lines.map { Machine( line: $0 ) }
    let presses = machines
        .flatMap { $0.configureLights( to: $0.lights ) }
        .map { $0.presses }
        .reduce( 0, + )

    return "\(presses)"
}


func part2( input: AOCinput ) -> String {
    let machines = input.lines.map { Machine( line: $0 ) }
    return "\(machines.map { $0.configureJoltage( to: $0.joltages ) }.reduce( 0, + ))"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
