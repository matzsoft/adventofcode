//
//         FILE: day02.swift
//  DESCRIPTION: Advent of Code 2023 Day 2: Cube Conundrum
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/01/23 21:00:29
//

import Foundation
import Library

let colors = [ "red", "green", "blue" ]
let target = [ 12, 13, 14 ]

struct Game {
    let id: Int
    let reveals: [Int]

    init( line: String ) {
        let sections = line.split { ":;".contains( $0 ) }
        
        id = Int( sections[0].dropFirst( 5 ) )!
        reveals = sections[1...].reduce( into: [ 0, 0, 0 ] ) { reveals, section in
            let words = section.split { ", ".contains( $0 ) }
            
            stride( from: 0, to: words.count, by: 2 ).forEach { index in
                let color = colors.firstIndex( of: String( words[index+1] ) )!
                reveals[color] = max( reveals[color], Int( words[index] )! )
            }
        }
    }
    
    func isPossible( target: [Int] ) -> Bool {
        reveals.indices.first { reveals[$0] > target[$0] } == nil
    }
    
    var power: Int {
        reveals.reduce( 1, * )
    }
}


func parse( input: AOCinput ) -> [Game] {
    return input.lines.map { Game( line: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let games = parse( input: input ).filter { $0.isPossible( target: target ) }
    return "\( games.reduce( 0, { $0 + $1.id } ) )"
}


func part2( input: AOCinput ) -> String {
    let powers = parse( input: input ).map { $0.power }
    return "\( powers.reduce( 0, + ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
