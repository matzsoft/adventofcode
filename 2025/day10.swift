//
//         FILE: day10.swift
//  DESCRIPTION: Advent of Code 2025 Day 10: Factory
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2025 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/09/25 21:19:48
//

import Foundation
import Library

struct Results: Hashable {
    let joltages: [Int]
    let presses: Int
    
    init( count: Int ) {
        joltages = Array( repeating: 0 , count: count )
        presses = 0
    }
    
    init( joltages: [Int], presses: Int ) {
        self.joltages = joltages
        self.presses = presses
    }
    
    func press( affected: [Int] ) -> Results {
        var joltages = self.joltages
        
        for index in affected {
            joltages[index] += 1
        }
        
        return Results( joltages: joltages, presses: presses + 1 )
    }
}


struct Path: Hashable {
    let path: Set<Int>
    let results: Results
    
    init( path: Set<Int>, results: Results ) {
        self.path = path
        self.results = results
    }
    
    func advance( button: Int, result: Results ) -> Path {
        Path( path: path.union( [ button ] ), results: result )
    }
}


struct Machine {
    let lights: [Int]
    let joltages: [Int]
    let buttons: [[Int]]
    
    init( line: String ) {
        let fields = line.split( separator: " " )
        
        lights = fields[0].dropFirst().dropLast().map { $0 == "#" ? 1 : 0 }
        joltages = fields.last!
            .split( whereSeparator: { "{},".contains( $0 ) } )
            .map { Int( String( $0 ) )! }
        
        let buttons = fields.dropFirst().dropLast()
        self.buttons = buttons.map {
            $0.split( whereSeparator: { "(),".contains($0) } ).map { Int( String( $0 ) )! }
        }
    }
    
    func configureLights( to desired: [Int], first: Bool = true ) -> [Path] {
        var queue = [ Path( path: [], results: Results( count: lights.count ) ) ]
        var seen = Set<Set<Int>>()
        var results: [Path] = []
        
        while !queue.isEmpty {
            let path = queue.removeFirst()
            
            for ( index, button ) in buttons.enumerated() {
                if !path.path.contains( index ) {
                    let nextResult = path.results.press( affected: button )
                    let newPath = path.advance( button: index, result: nextResult )
                    
                    if seen.insert( newPath.path ).inserted {
                        queue.append( newPath )
                        if nextResult.joltages.map( { $0 & 1 } ) == desired {
                            if first { return [newPath] }
                            results.append( newPath )
                        }
                    }
                }
            }
        }

        return results
    }
    
    func isAcceptable( joltages: [Int] ) -> Bool {
        self.joltages.indices.allSatisfy { joltages[$0] <= self.joltages[$0] }
    }
    
    func configureJoltage( to desired: [Int] ) -> Int {
        let desiredLights = joltages.map { $0 & 1 }
        let results = configureLights( to: desiredLights, first: false )
        let reducedJoltages = joltages.indices.map {
            joltages[$0] - results[0].results.joltages[$0]
        }

        var queue = [ Results( count: lights.count ) ]
        var seen = Set( [ queue[0].joltages ] )
        
        while !queue.isEmpty {
            let buttonResults = queue.removeFirst()
            
            for button in buttons {
                let nextResult = buttonResults.press( affected: button )

                if nextResult.joltages == desired { return nextResult.presses }
                if seen.insert( nextResult.joltages ).inserted && isAcceptable( joltages: joltages ) {
                    queue.append( nextResult )
                }
            }
        }
        fatalError( "No solution found" )
    }
}


func parse( input: AOCinput ) -> [Machine] {
    return input.lines.map { Machine( line: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let machines = parse( input: input )
    let presses = machines
        .flatMap { $0.configureLights( to: $0.lights ) }
        .map { $0.results.presses }
        .reduce( 0, + )

    return "\(presses)"
}


func part2( input: AOCinput ) -> String {
    let machines = parse( input: input )
    return "\(machines.map { $0.configureJoltage( to: $0.joltages ) }.reduce( 0, + ))"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
