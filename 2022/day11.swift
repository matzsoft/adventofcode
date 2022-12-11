//
//         FILE: main.swift
//  DESCRIPTION: day11 - Monkey in the Middle
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/10/22 21:00:12
//

import Foundation

class Monkey {
    var items: [Int]
    var inspectionCount = 0
    let operation: (Int) -> Int
    let test: (Int) -> Bool
    let ifTrue: Int
    let ifFalse: Int
    
    init( lines: [String] ) {
        let items = lines[1].split( whereSeparator: { " ,".contains( $0 ) } )
        self.items = items.dropFirst( 2 ).map { Int( $0 )! }

        let operation = lines[2].split( separator: " " )
        if let factor = Int( operation[5] ) {
            if operation[4] == "*" {
                self.operation = { $0 * factor }
            } else {
                self.operation = { $0 + factor }
            }
        } else {
            if operation[4] == "*" {
                self.operation = { $0 * $0 }
            } else {
                self.operation = { $0 + $0 }
            }
        }

        let divisor = Int( lines[3].split( separator: " " )[3] )!
        self.test = { $0.isMultiple( of: divisor ) }
        
        ifTrue = Int( lines[4].split( separator: " " )[5] )!
        ifFalse = Int( lines[5].split( separator: " " )[5] )!
    }
    
    func turn( monkeys: [Monkey], reduction: Int ) -> Void {
        inspectionCount += items.count
        for item in items {
            let worry = operation( item ) / reduction
            monkeys[ test( worry ) ? ifTrue : ifFalse ].items.append( worry )
        }
        items = []
    }
}


func parse( input: AOCinput ) -> [Monkey] {
    return input.paragraphs.map { Monkey( lines: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let monkeys = parse( input: input )
    
    for _ in 1 ... 20 {
        monkeys.forEach { $0.turn( monkeys: monkeys, reduction: 3 ) }
    }
    
    let counts = Array( monkeys.map { $0.inspectionCount }.sorted().reversed() )
    
    return "\( counts[0] * counts[1] )"
}


func part2( input: AOCinput ) -> String {
    let monkeys = parse( input: input )
    
    for _ in 1 ... 10000 {
        monkeys.forEach { $0.turn( monkeys: monkeys, reduction: 1 ) }
    }
    
    let counts = Array( monkeys.map { $0.inspectionCount }.sorted().reversed() )
    
    return "\( counts[0] * counts[1] )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
