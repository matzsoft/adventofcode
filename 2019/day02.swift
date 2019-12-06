//
//  main.swift
//  day02
//
//  Created by Mark Johnson on 12/1/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let inputFile = "/Users/markj/Development/adventofcode/2019/input/day02.txt"
let input = try String( contentsOfFile: inputFile ).dropLast( 1 )
let initialMemory = input.split( separator: "," ).map { Int($0)! }

func grind( noun: Int, verb: Int ) -> Int {
    var pc = 0
    var memory = initialMemory

    memory[1] = noun
    memory[2] = verb
    
    while true {
        switch memory[pc] {
        case 1:
            memory[memory[pc+3]] = memory[memory[pc+1]] + memory[memory[pc+2]]
        case 2:
            memory[memory[pc+3]] = memory[memory[pc+1]] * memory[memory[pc+2]]
        case 99:
            return memory[0]
        default:
            print("Invalid opcode \(memory[pc]) at \(pc)")
            exit(1)
        }
        pc += 4
    }
}

print( "Part 1: \(grind( noun: 12, verb: 2 ))" )

for noun in 0 ... 99 {
    for verb in 0 ... 99 {
        let result = grind( noun: noun, verb: verb )
        
        if result == 19690720 {
            print( "Part 2: \(100 * noun + verb)" )
            exit(0)
        }
    }
}

print( "Gross failure" )
