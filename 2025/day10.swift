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
    let lights: [Bool]
    let joltages: [Int]
    let presses: Int
    
    init( count: Int ) {
        lights = Array( repeating: false, count: count )
        joltages = Array( repeating: 0 , count: count )
        presses = 0
    }
    
    init( lights: [Bool], joltages: [Int], presses: Int ) {
        self.lights = lights
        self.joltages = joltages
        self.presses = presses
    }
    
    func press( affected: [Int] ) -> Results {
        var lights = self.lights
        var joltages = self.joltages
        
        for index in affected {
            lights[index].toggle()
            joltages[index] += 1
        }
        
        return Results( lights: lights, joltages: joltages, presses: presses + 1 )
    }
}


struct Machine {
    let lights: [Bool]
    let joltages: [Int]
    let buttons: [[Int]]
    
    init( line: String ) {
        let fields = line.split( separator: " " )
        
        lights = fields[0].dropFirst().dropLast().map { $0 == "#" }
        joltages = fields.last!
            .split( whereSeparator: { "{},".contains($0) } )
            .map { Int( String( $0 ) )! }
        let blarb = fields.dropFirst().dropLast()
        buttons = blarb.map {
            $0.split( whereSeparator: { "(),".contains($0) } ).map { Int( String( $0 ) )! }
        }
    }
    
    func configureLights() -> Int {
        var queue = [ Results( count: lights.count ) ]
        var seen = Set( [ queue[0].lights ] )
        
        while !queue.isEmpty {
            let buttonResults = queue.removeFirst()
            
            for button in buttons {
                let nextResult = buttonResults.press( affected: button )

                if nextResult.lights == self.lights { return nextResult.presses }
                if seen.insert( nextResult.lights ).inserted {
                    queue.append( nextResult )
                }
            }
        }
        fatalError( "No solution found" )
    }
    
    func isAcceptable( joltages: [Int] ) -> Bool {
        self.joltages.indices.allSatisfy { joltages[$0] <= self.joltages[$0] }
    }
    
    func configureJoltage() -> Int {
        var queue = [ Results( count: lights.count ) ]
        var seen = Set( [ queue[0].joltages ] )
        
        while !queue.isEmpty {
            let buttonResults = queue.removeFirst()
            
            for button in buttons {
                let nextResult = buttonResults.press( affected: button )

                if nextResult.joltages == self.joltages { return nextResult.presses }
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
    return "\(machines.map { $0.configureLights() }.reduce( 0, + ))"
}


func part2( input: AOCinput ) -> String {
    let machines = parse( input: input )
    return "\(machines.map { $0.configureJoltage() }.reduce( 0, + ))"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
