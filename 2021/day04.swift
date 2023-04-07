//
//         FILE: main.swift
//  DESCRIPTION: day04 - Giant Squid
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/03/21 21:12:20
//

import Foundation
import Library

class Cell {
    let value: Int
    var isMarked: Bool
    
    init( value: Int ) {
        self.value = value
        isMarked = false
    }
}

struct Board {
    let rows: [[Cell]]
    
    init( lines: [String] ) {
        rows = lines.map { $0.split( separator: " " ).map { Cell( value: Int( $0 )! ) } }
    }
    
    func call( number: Int ) -> Int? {
        rows.forEach { $0.forEach { if $0.value == number { $0.isMarked = true } } }
        let score = rows.map { $0.filter { !$0.isMarked }.reduce( 0, { $0 + $1.value } ) }.reduce( 0, + )
        
        if rows.contains( where: { $0.allSatisfy( { $0.isMarked } ) } ) {
            return score * number
        }
        
        if rows[0].indices.contains( where: { index in rows.allSatisfy( { $0[index].isMarked } ) } ) {
            return score * number
        }
        
        return nil
    }
}

func parse( input: AOCinput ) -> ( [Int], [Board] ) {
    let numbers = input.paragraphs[0][0].split( separator: "," ).map { Int( $0 )! }
    let boards = input.paragraphs[1...].map { Board( lines: $0 ) }
    return ( numbers, boards )
}


func part1( input: AOCinput ) -> String {
    let ( numbers, boards ) = parse( input: input )
    
    for number in numbers {
        for board in boards {
            if let score = board.call( number: number ) {
                return "\(score)"
            }
        }
    }
    return "No solution"
}


func part2( input: AOCinput ) -> String {
    let ( numbers, boards ) = parse( input: input )
    var winners = Set<Array<Board>.Index>()
    
    for number in numbers {
        for index in boards.indices {
            if !winners.contains( index ) {
                if let score = boards[index].call( number: number ) {
                    winners.insert( index )
                    if winners.count == boards.count { return "\(score)" }
                }
            }
        }
    }
    return "No solution"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
