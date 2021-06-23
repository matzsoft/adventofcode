//
//         FILE: main.swift
//  DESCRIPTION: day02 - 1202 Program Alarm
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/31/21 14:58:04
//

import Foundation

func grind( initialMemory: [Int], noun: Int, verb: Int ) throws -> Int {
    let computer = Intcode( name: "Ship", memory: initialMemory )

    computer.memory[1] = noun
    computer.memory[2] = verb
    _ = try! computer.execute()
    return computer.memory[0]
}


func parse( input: AOCinput ) -> [Int] {
    return input.line.split( separator: "," ).map { Int( $0 )! }
}


func part1( input: AOCinput ) -> String {
    let initialMemory = parse( input: input )
    return "\(try! grind( initialMemory: initialMemory, noun: 12, verb: 2 ))"
}


func part2( input: AOCinput ) -> String {
    let initialMemory = parse( input: input )
    
    for noun in 0 ... 99 {
        for verb in 0 ... 99 {
            let result = try! grind( initialMemory: initialMemory, noun: noun, verb: verb )
            
            if result == 19690720 {
                return "\(100 * noun + verb)"
            }
        }
    }

    return "Gross failure"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
