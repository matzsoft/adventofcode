//
//         FILE: main.swift
//  DESCRIPTION: day14 - Docking Data
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/26/21 12:39:20
//

import Foundation

struct Docker {
    enum Opcode: String { case mask, mem }
    
    struct Mask {
        let zeroes:  Int            // 0 where there is a 0, 1 everywhere else
        let ones:    Int            // 1 where there is a 1, 0 everywhere else
        let xmask:   Int            // 0 where there is an X, 1 everywhere else
        let xvalues: [Int]

        init( input: String, version: Int ) {
            let xcount = input.reduce( 0 ) { $0 + ( $1 == "X" ? 1 : 0 ) }
            
            zeroes = input.reduce( 0 ) { ( $0 << 1 ) | ( $1 == "0" ? 0 : 1 ) }
            ones = input.reduce( 0 ) { ( $0 << 1 ) | ( $1 == "1" ? 1 : 0 ) }
            xmask = input.reduce( 0 ) { ( $0 << 1 ) | ( $1 == "X" ? 0 : 1 ) }
            if version == 1 {
                xvalues = []
            } else {
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
        
        init( input: String, version: Int ) {
            let fields = input.components( separatedBy: " = " )
            
            switch fields[0] {
            case "mask":
                opcode = .mask
                mask = Mask( input: fields[1], version: version )
                address = 0
                operand = 0
            default:
                let string = fields[0]
                
                opcode = .mem
                mask = Mask( input: "", version: version )
                address = Int( string[string.index( string.startIndex, offsetBy: 4 )...].dropLast() )!
                operand = Int( fields[1] )!
            }
        }
    }
    
    let program: [Instruction]
    var mask: Mask
    var memory: [ Int : Int ]
    
    init( lines: [String], version: Int ) {
        program = lines.map { Instruction( input: $0, version: version ) }
        mask = Mask( input: "", version: version )
        memory = [:]
    }
    
    mutating func reset() -> Void {
        mask = Mask( input: "", version: 2 )
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
        
        return memory.values.reduce( 0, + )
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
        
        return memory.values.reduce( 0, + )
    }
}


func parse( input: AOCinput, version: Int = 1 ) -> Docker {
    return Docker( lines: input.lines, version: version )
}


func part1( input: AOCinput ) -> String {
    var docker = parse( input: input )
    return "\( docker.run1() )"
}


func part2( input: AOCinput ) -> String {
    var docker = parse( input: input, version: 2 )
    return "\( docker.run2() )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
