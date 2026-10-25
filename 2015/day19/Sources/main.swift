//
//         FILE: main.swift
//  DESCRIPTION: day19 - Medicine for Rudolph
//        NOTES: No general solution yet, probably needs a context free parser.
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/09/21 20:51:06
//

import Foundation
import Library

func part1( input: AOCinput ) -> String {
    let elements = input.paragraphs[0].reduce( into: [ String : [String] ]() ) { dict, line in
        let words = line.components( separatedBy: " => " )
        dict[ words[0], default: [] ].append( words[1] )
    }
    let molecule = input.paragraphs[1][0]
    let molecules = elements.keys.reduce( into: Set<String>() ) { molecules, element in
        var fragments = molecule.components( separatedBy: element )
        
        while fragments.count > 1 {
            for replacement in elements[ element, default: [] ] {
                let new = "\(fragments[0])\(replacement)\(fragments[1])" +
                    ( fragments.count < 3 ? "" : element + fragments[2...].joined( separator: element ) )
                
                molecules.insert( new )
            }
            
            let restore = "\(fragments[0])\(element)\(fragments[1])"
            fragments.removeFirst( 2 )
            fragments.insert( restore, at: 0 )
        }
    }
    
    return "\( molecules.count )"
}

// Reverses everything in order to do the replacements from the right end of the molecule.
// Works on the problem data but not the test data.
func part2( input: AOCinput ) -> String {
    let blanch = input.paragraphs[0].map { String( $0.reversed() ) }.map { line -> ( String, String ) in
        let words = line.components( separatedBy: " >= " )
        return ( words[0], words[1] )
    }
    let reverse = Dictionary( uniqueKeysWithValues: blanch )
    var molecule = String( input.paragraphs[1][0].reversed() )
    let re = blanch.map { $0.0 }.joined( separator: "|" )
    var count = 0

    while true {
        guard let range = molecule.range( of: re, options: .regularExpression ) else { break }
        let match = String( molecule[range] )
        molecule.replaceSubrange( range, with: reverse[match]! )
        count += 1
    }

    if molecule == "e" { return "\( count )" }

    return ""
}

// Implementation of askalski's interesting analysis of the input in the subreddit.
// Again works on the puzzle input, but not the test data.
func partZoo( input: AOCinput ) -> String {
    let molecule = input.paragraphs[1][0]
    var elements = [String]()
    var last = Character( "x" )
    enum State { case initial, final }
    var state = State.initial
    
    for character in molecule {
        switch state {
        case .initial:
            last = character
            state = .final
        case .final:
            if character.isUppercase {
                elements.append( String( last ) )
                last = character
            } else {
                elements.append( String( [ last, character ] ) )
                state = .initial
            }
        }
    }
    if state == .final { elements.append( String( last ) ) }
    
    let histogram = elements.reduce( into: [ String : Int ]() ) { dict, element in
        dict[ element, default: 0 ] += 1
    }
    
//    for pair in histogram.sorted( by: { $0.key < $1.key } ){
//        print("\(pair.key): \(pair.value)")
//    }
    let reductions = ( histogram["Ar"] ?? 0 ) + ( histogram["Rn"] ?? 0 ) + 2 * ( histogram["Y"] ?? 0 )
    return "\( elements.count - reductions - 1 )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try runTests( part2: partZoo, label: "askalski" )
try solve( part1: part1 )
try solve( part2: part2 )
try solve( part2: partZoo, label: "askalski" )
