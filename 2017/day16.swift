//
//         FILE: main.swift
//  DESCRIPTION: day16 - Permutation Promenade
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/22/21 16:15:18
//

import Foundation

class Choreography {
    let ASCIIa = "a".unicodeScalars.first!.value
    let ASCIIp = "p".unicodeScalars.first!.value
    
    enum DanceMove {
        case spin( Int )
        case exchange( Int, Int )
        case partner( Character, Character )
    }

    var dancers: [Character]
    let moves: [DanceMove]
    var toString: String { String( dancers ) }
    
    init( input: String ) throws {
        dancers = ( ASCIIa ... ASCIIp ).map { Character( UnicodeScalar( $0 )! ) }
        moves = try input.split(separator: ",").map { ( move ) in
            guard let type = move.first else {
                throw RuntimeError( "Empty dance move." )
            }
            
            let index = move.index( move.startIndex, offsetBy: 1 )
            
            switch type {
            case "s":
                return DanceMove.spin( Int( move[index...] )! )
            case "x":
                let words = move[index...].split(separator: "/")
                
                return DanceMove.exchange( Int( words[0] )!, Int( words[1] )! )
            case "p":
                let words = move[index...].split(separator: "/")
                let first = Character( String( words[0] ) )
                let last = Character( String( words[1] ) )
                
                return DanceMove.partner( first, last )
            default:
                throw RuntimeError( "Bad move type: \(type)" )
            }
        }
    }
    
    func oneRound() -> Void {
        for move in moves {
            switch move {
            case let .spin( count ):
                let split = dancers.count - count
                
                dancers = Array( dancers[split...] ) + Array( dancers[..<split] )
            case let .exchange( first, last ):
                ( dancers[first], dancers[last] ) = ( dancers[last], dancers[first] )
            case let .partner( firstName, lastName ):
                let first = dancers.firstIndex( of: firstName )!
                let last = dancers.firstIndex( of: lastName )!
                
                ( dancers[first], dancers[last] ) = ( dancers[last], dancers[first] )
            }
        }
    }
}


func parse( input: AOCinput ) -> Choreography {
    return try! Choreography( input: input.line )
}


func part1( input: AOCinput ) -> String {
    let choreography = parse( input: input )
    
    choreography.oneRound()
    return "\(choreography.toString)"
}


func part2( input: AOCinput ) -> String {
    let limit = 1000000000
    let choreography = parse( input: input )
    var seen = [ choreography.toString : 0 ]
    
    for count in 1 ... limit {
        choreography.oneRound()
        if let previous = seen[choreography.toString] {
            let cycle = count - previous
            let remaining = limit - count
            let final = remaining - remaining / cycle * cycle
            
            for _ in 0 ..< final {
                choreography.oneRound()
            }
            return "\(choreography.toString)"
        }
        seen[choreography.toString] = count
    }
    
    return "\(choreography.toString)"
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
