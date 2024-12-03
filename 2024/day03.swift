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


func scan( line: String, conditionals: Bool ) -> [ ( Int, Int ) ] {
    var state = 0
    var left = ""
    var right = ""
    var enabled = true
    var result: [ ( Int, Int ) ] = []
    
    for character in line {
        switch state {
        case 0:
            switch character {
            case "m":
                state = 1
            case "d":
                if conditionals { state = 9 } else { state = 0 }
            default:
                state = 0
            }
        case 1:
            left = ""
            right = ""
            switch character {
            case "u":
                state = 2
            case "m":
                state = 1
            case "d":
                if conditionals { state = 9 } else { state = 0 }
            default:
                state = 0
            }
        case 2:
            switch character {
            case "l":
                state = 3
            case "m":
                state = 1
            case "d":
                if conditionals { state = 9 } else { state = 0 }
            default:
                state = 0
            }
        case 3:
            switch character {
            case "(":
                state = 4
            case "m":
                state = 1
            case "d":
                if conditionals { state = 9 } else { state = 0 }
            default:
                state = 0
            }
        case 4:
            switch character {
            case let c where c.isNumber:
                left.append( String( character ) )
                state = 5
            case "m":
                state = 1
            case "d":
                if conditionals { state = 9 } else { state = 0 }
            default:
                state = 0
            }
        case 5:
            switch character {
            case let c where c.isNumber:
                left.append( String( character ) )
            case ",":
                state = 6
            case "m":
                state = 1
            case "d":
                if conditionals { state = 9 } else { state = 0 }
            default:
                state = 0
            }
        case 6:
            switch character {
            case let c where c.isNumber:
                right.append( String( character ) )
                state = 7
            case "m":
                state = 1
            case "d":
                if conditionals { state = 9 } else { state = 0 }
            default:
                state = 0
            }
        case 7:
            switch character {
            case let c where c.isNumber:
                right.append( String( character ) )
            case ")":
                if enabled {
                    result.append( ( Int( left )!, Int( right )! ) )
                }
                state = 0
            case "m":
                state = 1
            case "d":
                if conditionals { state = 9 } else { state = 0 }
            default:
                state = 0
            }

        case 9:
            switch character {
            case "o":
                state = 10
            case "m":
                state = 1
            case "d":
                if conditionals { state = 9 } else { state = 0 }
            default:
                state = 0
            }
       case 10:
            switch character {
            case "(":
                state = 11
            case "n":
                state = 12
            case "m":
                state = 1
            case "d":
                if conditionals { state = 9 } else { state = 0 }
            default:
                state = 0
            }
        case 11:
            switch character {
            case ")":
                enabled = true
                state = 0
            case "m":
                state = 1
            case "d":
                if conditionals { state = 9 } else { state = 0 }
            default:
                state = 0
            }
        case 12:
            switch character {
            case "'":
                state = 13
            case "m":
                state = 1
            case "d":
                if conditionals { state = 9 } else { state = 0 }
            default:
                state = 0
            }
        case 13:
            switch character {
            case "t":
                state = 14
            case "m":
                state = 1
            case "d":
                if conditionals { state = 9 } else { state = 0 }
            default:
                state = 0
            }
        case 14:
            switch character {
            case "(":
                state = 15
            case "m":
                state = 1
            case "d":
                if conditionals { state = 9 } else { state = 0 }
            default:
                state = 0
            }
        case 15:
            switch character {
            case ")":
                enabled = false
                state = 0
            case "m":
                state = 1
            case "d":
                if conditionals { state = 9 } else { state = 0 }
            default:
                state = 0
            }
        default:
            fatalError( "Error in FSA" )
        }
    }
    
    return result
}


func parse( input: AOCinput ) -> [ ( Int, Int ) ] {
    input.lines.flatMap { scan( line: $0, conditionals: false ) }
}


func part1( input: AOCinput ) -> String {
    let pairs = input.lines.flatMap { scan( line: $0, conditionals: false ) }
    return "\( pairs.reduce( 0, { $0 + $1.0 * $1.1 } ) )"
}


func part2( input: AOCinput ) -> String {
    let pairs = input.lines.flatMap { scan( line: $0, conditionals: true ) }
    return "\( pairs.reduce( 0, { $0 + $1.0 * $1.1 } ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
