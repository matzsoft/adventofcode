//
//         FILE: day17.swift
//  DESCRIPTION: Advent of Code 2024 Day 17: Chronospatial Computer
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/16/24 21:23:49
//

import Foundation
import Library

enum Register: Int {
    case A = 0, B = 1, C = 2
    
    init( from: Character ) {
        switch from {
        case "A":
            self = .A
        case "B":
            self = .B
        case "C":
            self = .C
        default:
            fatalError( "Unrecognized refister '\(from)'")
        }
    }
}

struct Computer {
    var ip: Int
    var registers: [Int]
    let memory: [Int]
    var output: [Int]
    
    enum Opcode: Int { case adv, bxl, bst, jnz, bxc, out, bdv, cdv }
    
    init( paragraphs: [[String]] ) {
        ip = 0
        registers = paragraphs[0].map {
            let fields = $0.split( whereSeparator: { " :".contains( $0 ) } )
            return Int( fields[2] )!
        }
        
        let fields = paragraphs[1][0]
            .split( whereSeparator: { " :,".contains( $0 ) } )
        memory = fields[1...].map { Int( $0 )! }
        output = []
    }
    
    func combo() -> Int {
        let operand = memory[ip+1]
        if ( 0 ... 3 ).contains( operand ) { return operand }
        if operand == 7 { fatalError( "Combo operand 7 is illegal" ) }
        return registers[ operand - 4 ]
    }
    
    mutating func process() -> Void {
        while ( 0 ..< memory.count ).contains( ip ) {
            switch Opcode( rawValue: memory[ip] )! {
            case .adv:
                registers[0] = registers[0] / ( 1 << combo() )
            case .bxl:
                registers[1] = registers[1] ^ memory[ip+1]
            case .bst:
                registers[1] = combo() % 8
            case .jnz:
                if registers[0] != 0 { ip = memory[ip+1] - 2 }
            case .bxc:
                registers[1] = registers[1] ^ registers[2]
            case .out:
                output.append( combo() % 8 )
            case .bdv:
                registers[1] = registers[0] / ( 1 << combo() )
            case .cdv:
                registers[2] = registers[0] / ( 1 << combo() )
            }
            ip += 2
        }
    }
    
    mutating func fast() -> Void {
        var A = registers[0]
        var B = registers[1]
        var C = registers[2]
        
        repeat {
            B = ( A % 8 ) ^ 3
            C = A >> B
            B ^= 5
            A = A >> 3
            B = B ^ C
            output.append( B % 8 )
        } while A != 0
    }
    
//    var buildOverride: Int {
//        var A = 0
//        
//        for index in memory.indices.reversed() {
//            let candidates = ( 0 ... 7 ).filter {
//                let newA = ( A << 3 ) | $0
//                let b1 = $0 ^ 3
//                let b2 = b1 ^ 5
//                let C = newA >> b1
//                let outValue = ( b2 ^ C ) & 7
//                return outValue == memory[index]
//            }
//            guard candidates.count == 1 else { fatalError( "Confusion reigns" ) }
//            A = ( A << 3 ) | candidates[0]
//        }
//        
//        return A
//    }

    var buildOverride: [Int] {
        var As = [ 0 ]
        
        for index in memory.indices.reversed() {
            var newAs = [Int]()
            for A in As {
                let candidates = ( 0 ... 7 ).filter {
                    let newA = ( A << 3 ) | $0
                    let b1 = $0 ^ 3
                    let b2 = b1 ^ 5
                    let C = newA >> b1
                    let outValue = ( b2 ^ C ) & 7
                    return outValue == memory[index]
                }
                newAs.append( contentsOf: candidates.map { ( A << 3 ) | $0 } )
            }
            guard newAs.count > 0 else { fatalError( "Confusion reigns" ) }
            As = newAs
        }
        
        return As
    }
}


func parse( input: AOCinput ) -> Any? {
    return nil
}


func part1( input: AOCinput ) -> String {
    var computer = Computer( paragraphs: input.paragraphs )
    computer.process()
    return computer.output.map { String($0) }.joined( separator: "," )
}


func part1Fast( input: AOCinput ) -> String {
    var computer = Computer( paragraphs: input.paragraphs )
    computer.fast()
    return computer.output.map { String($0) }.joined( separator: "," )
}


func part2( input: AOCinput ) -> String {
    let original = Computer( paragraphs: input.paragraphs )
    let overrides = original.buildOverride
    
    return "\(overrides[0])"
}


//func part2( input: AOCinput ) -> String {
//    let original = Computer( paragraphs: input.paragraphs )
//    
//    for override in 0 ..< Int.max {
//        var computer = original
//        
//        computer.registers[0] = override
//        computer.process()
//        if computer.output == original.memory { return String( override ) }
////        if override % 50000000 == 0 { print( override ) }
//    }
//    return "No Solution Found"
//}


try print( projectInfo() )
try runTests( part1: part1 )
//try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part1: part1Fast, label: "fast" )
try solve( part2: part2 )
