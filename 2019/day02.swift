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
    var ip = 0
    var memory = initialMemory

    memory[1] = noun
    memory[2] = verb
    
    while true {
        switch memory[ip] {
        case 1:
            memory[memory[ip+3]] = memory[memory[ip+1]] + memory[memory[ip+2]]
        case 2:
            memory[memory[ip+3]] = memory[memory[ip+1]] * memory[memory[ip+2]]
        case 99:
            return memory[0]
        default:
            throw RuntimeError( "Invalid opcode \(memory[ip]) at \(ip)" )
        }
        ip += 4
    }
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


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
