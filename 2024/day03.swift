//
//         FILE: day03.swift
//  DESCRIPTION: Advent of Code 2024 Day 3: Mull It Over
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/02/24 21:20:56
//

import Foundation
import Library


func scan( line: String, conditionals: Bool ) -> [Int] {
    var state = 0
    var left = ""
    var right = ""
    var enabled = true
    var result: [Int] = []
    
    for character in line {
        if character == "m" { state = 1; continue }
        if character == "d" && conditionals { state = 9; continue }
        
        switch state {
        case 0:
            break
        case 1:
            left = ""
            right = ""
            if character == "u" { state = 2 } else { state = 0 }
        case 2:
            if character == "l" { state = 3 } else { state = 0 }
        case 3:
            if character == "(" { state = 4 } else { state = 0 }
        case 4:
            if character.isNumber {
                left.append( String( character ) )
                state = 5
            } else {
                state = 0
            }
        case 5:
            if character.isNumber {
                left.append( String( character ) )
            } else if character == "," {
                state = 6
            } else {
                state = 0
            }
        case 6:
            if character.isNumber {
                right.append( String( character ) )
                state = 7
            } else {
                state = 0
            }
        case 7:
            if character.isNumber {
                right.append( String( character ) )
            } else if character == ")" {
                if enabled {
                    result.append( Int( left )! * Int( right )! )
                }
                state = 0
            } else {
                state = 0
            }

        case 9:
            if character == "o" { state = 10 } else { state = 0 }
       case 10:
            switch character {
            case "(":
                state = 11
            case "n":
                state = 12
            default:
                state = 0
            }
        case 11:
            if character == ")" { enabled = true }
            state = 0
        case 12:
            if character == "'" { state = 13 } else { state = 0 }
        case 13:
            if character == "t" { state = 14 } else { state = 0 }
        case 14:
            if character == "(" { state = 15 } else { state = 0 }
        case 15:
            if character == ")" { enabled = false }
            state = 0
        default:
            fatalError( "Error in FSA" )
        }
    }
    
    return result
}


func part1( input: AOCinput ) -> String {
    let pairs = scan( line: input.lines.joined(), conditionals: false )
    return "\( pairs.reduce( 0, + ) )"
}


func part2( input: AOCinput ) -> String {
    let pairs = scan( line: input.lines.joined(), conditionals: true )
    return "\( pairs.reduce( 0, + ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
