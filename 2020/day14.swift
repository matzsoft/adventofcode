//
//  main.swift
//  day14
//
//  Created by Mark Johnson on 12/13/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

struct Docker {
    enum Opcode: String {
        case mask, mem
    }
    
    struct Mask {
        let zeroes:  Int            // 0 where there is a 0, 1 everywhere else
        let ones:    Int            // 1 where there is a 1, 0 everywhere else
        let xmask:   Int            // 0 where there is an X, 1 everywhere else
        let xvalues: [Int]

        init( input: String ) {
            let xcount = input.reduce( 0 ) { $0 + ( $1 == "X" ? 1 : 0 ) }
            
            zeroes = input.reduce( 0 ) { ( $0 << 1 ) | ( $1 == "0" ? 0 : 1 ) }
            ones = input.reduce( 0 ) { ( $0 << 1 ) | ( $1 == "1" ? 1 : 0 ) }
            xmask = input.reduce( 0 ) { ( $0 << 1 ) | ( $1 == "X" ? 0 : 1 ) }
            xvalues = ( 0 ..< ( 1 << xcount ) ).map {
                var value = $0
                return input.reduce( 0 ) {
                    guard $1 == "X" else { return $0 << 1 }
                    let bit = value & 1
                    value = value >> 1
                    return ( $0 << 1 ) | bit
                }
            }
        }
        
        func valueApply( value: Int ) -> Int {
            return ( value & zeroes ) | ones
        }
        
        func addressApply( value: Int ) -> [Int] {
            return xvalues.map { value & xmask | $0 | ones }
        }
    }
    
    struct Instruction {
        let opcode: Opcode
        let mask: Mask
        let address: Int
        let operand: Int
        
        init( input: Substring ) {
            let fields = input.components( separatedBy: " = " )
            
            switch fields[0] {
            case "mask":
                opcode = .mask
                mask = Mask( input: fields[1] )
                address = 0
                operand = 0
            default:
                let string = fields[0]
                
                opcode = .mem
                mask = Mask( input: "" )
                address = Int( string[string.index( string.startIndex, offsetBy: 4 )...].dropLast() )!
                operand = Int( fields[1] )!
            }
        }
    }
    
    let program: [Instruction]
    var mask: Mask
    var memory: [ Int : Int ]
    
    init( input: String ) {
        program = input.split( separator: "\n" ).map { Instruction( input: $0 ) }
        mask = Mask( input: "" )
        memory = [:]
    }
    
    mutating func reset() -> Void {
        mask = Mask( input: "" )
        memory = [:]
    }
    
    mutating func run1() -> Int {
        reset()
        for instruction in program {
            switch instruction.opcode {
            case .mask:
                mask = instruction.mask
            case .mem:
                memory[instruction.address] = mask.valueApply( value: instruction.operand )
            }
        }
        
        return memory.values.reduce( 0 ) { $0 + $1 }
    }
    
    mutating func run2() -> Int {
        reset()
        for instruction in program {
            switch instruction.opcode {
            case .mask:
                mask = instruction.mask
            case .mem:
                mask.addressApply( value: instruction.address ).forEach { memory[$0] = instruction.operand }
            }
        }
        
        return memory.values.reduce( 0 ) { $0 + $1 }
    }
}


let inputFile = "/Users/markj/Development/adventofcode/2020/input/day14.txt"
var docker = try Docker( input: String( contentsOfFile: inputFile ) )

print( "Part 1: \(docker.run1())" )
print( "Part 2: \(docker.run2())" )
