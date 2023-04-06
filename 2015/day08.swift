//
//         FILE: main.swift
//  DESCRIPTION: day08 - Matchsticks
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/05/21 17:33:55
//

import Foundation
import Library

func decode( line: String ) throws -> String {
    enum State { case initial, normal, backslash, backslashX, backslashXn, final }
    
    var state = State.initial
    var value = 0
    let decoded = try! line.compactMap { character -> Character? in
        switch state {
        case .initial:
            guard character == "\"" else  { throw RuntimeError( "Missing initial quote." ) }
            state = .normal
            return nil
        case .normal:
            switch character {
            case "\\":
                state = .backslash
                return nil
            case "\"":
                state = .final
                return nil
            default:
                return character
            }
        case .backslash:
            switch character {
            case "\\", "\"":
                state = .normal
                return character
            case "x":
                state = .backslashX
                return nil
            default:
                throw RuntimeError( "Illegal character '\(character)' after backslash." )
            }
        case .backslashX:
            if character.isHexDigit {
                state = .backslashXn
                value = Int( String( character ), radix: 16 )!
                return nil
            }
            throw RuntimeError( "Backslash x followed by non hex digit." )
        case .backslashXn:
            if character.isHexDigit {
                state = .normal
                value = ( value << 4 ) + Int( String( character ), radix: 16 )!
                return Character( UnicodeScalar( value )! )
            }
            throw RuntimeError( "Backslash x followed by non hex digit." )
        case .final:
            throw RuntimeError( "Invalid internal quote." )
        }
    }
    if state != .final { throw RuntimeError( "Missing final quote." ) }
    
    return String( decoded )
}


func encode( line: String ) -> String {
    return "\"" + line.map { character -> String in
        switch character {
        case "\"":
            return "\\\""
        case "\\":
            return "\\\\"
        default:
            return String( character )
        }
    }.joined() + "\""
}


func part1( input: AOCinput ) -> String {
    return "\( input.lines.reduce( 0 ) { try! $0 + $1.count - decode( line: $1 ).count } )"
}


func part2( input: AOCinput ) -> String {
    return "\( input.lines.reduce( 0 ) { $0 + encode( line: $1 ).count - $1.count } )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
