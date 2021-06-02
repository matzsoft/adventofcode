//
//         FILE: main.swift
//  DESCRIPTION: day05 - Sunny with a Chance of Asteroids
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/31/21 23:36:26
//

import Foundation


func parse( input: AOCinput ) -> Intcode {
    return Intcode( name: "TEST", memory: input.line.split( separator: "," ).map { Int($0)! } )
}


func part1( input: AOCinput ) -> String {
    let computer = parse( input: input )
    var lastOutput = Int.max
    
    computer.inputs = [ 1 ]
    while let output = try! computer.execute() {
        lastOutput = output
    }

    return "\(lastOutput)"
}


func part2( input: AOCinput ) -> String {
    let computer = parse( input: input )
    
    computer.inputs = [ 5 ]
    while let output = try! computer.execute() {
        return "\(output)"
    }

    return "Failure"
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
