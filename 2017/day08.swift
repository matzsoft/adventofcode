//
//         FILE: main.swift
//  DESCRIPTION: day08 - I Heard You Like Registers
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/18/21 00:24:23
//

import Foundation


func parse( input: AOCinput ) -> ( Int, Int ) {
    var registers: [ Substring : Int ] = [:]
    var biggest = 0
    
    for line in input.lines {
        let words = line.split(separator: " ")
        let targetRegister = words[0]
        let operation = words[1]
        let modifier = Int( words[2] )!
        let testRegister = words[4]
        let condition = words[5]
        let rhs = Int( words[6] )!
        
        func success() -> Bool {
            switch condition {
            case "==":
                return ( registers[testRegister] ?? 0 ) == rhs
            case "!=":
                return ( registers[testRegister] ?? 0 ) != rhs
            case "<":
                return ( registers[testRegister] ?? 0 ) <  rhs
            case ">":
                return ( registers[testRegister] ?? 0 ) >  rhs
            case "<=":
                return ( registers[testRegister] ?? 0 ) <= rhs
            case ">=":
                return ( registers[testRegister] ?? 0 ) >= rhs
            default:
                print( "Bad condition:", condition )
                exit(1)
            }
        }
        
        if success() {
            switch operation {
            case "inc":
                registers[targetRegister] = ( registers[targetRegister] ?? 0 ) + modifier
                biggest = max( biggest, registers[targetRegister]! )
            case "dec":
                registers[targetRegister] = ( registers[targetRegister] ?? 0 ) - modifier
                biggest = max( biggest, registers[targetRegister]! )
            default:
                print( "Bad operation:", operation )
                exit(1)
            }
        }
    }
    
    return ( registers.max( by: { $0.value < $1.value } )!.value, biggest )
}


func part1( input: AOCinput ) -> String {
    return "\(parse( input: input ).0)"
}


func part2( input: AOCinput ) -> String {
    return "\(parse( input: input ).1)"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
