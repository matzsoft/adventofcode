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
import Library


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


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
