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

struct ButtonResults: Hashable {
    let lights: [Bool]
    let presses: Int
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
        let lights = Array( repeating: false, count: self.lights.count )
        var queue = [ ButtonResults( lights: lights, presses: 0 ) ]
        var seen = Set( [ lights ] )
        
        while !queue.isEmpty {
            let buttonResults = queue.removeFirst()
            
            for button in buttons {
                var lights = buttonResults.lights
                for toggle in button {
                    lights[toggle].toggle()
                }
                if lights == self.lights { return buttonResults.presses + 1 }
                if seen.insert( lights ).inserted {
                    queue.append(
                        ButtonResults( lights: lights, presses: buttonResults.presses + 1 )
                    )
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
    let something = parse( input: input )
    return ""
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
