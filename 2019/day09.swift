//
//         FILE: main.swift
//  DESCRIPTION: day09 - Sensor Boost
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/01/21 15:56:15
//

import Foundation


func parse( input: AOCinput ) -> Intcode {
    let initialMemory = input.line.split( separator: "," ).map { Int( $0 )! }
    return Intcode( name: "BOOST", memory: initialMemory )
}


func part1( input: AOCinput ) -> String {
    let computer = parse( input: input )
    
    computer.inputs = [ 1 ]
    while let output = try! computer.execute() {
        return "\(output)"
    }
    return "Failure"
}


func part2( input: AOCinput ) -> String {
    let computer = parse( input: input )
    
    computer.inputs = [ 2 ]
    while let output = try! computer.execute() {
        return "\(output)"
    }
    return "Failure"
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
