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
import Library

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
    
    func turn( monkeys: [Monkey] ) -> Void {
        inspectionCount += items.count
        for item in items {
            let worry = operation( item ) / 3
            monkeys[ test( worry ) ? ifTrue : ifFalse ].items.append( worry )
        }
        items = []
    }
}


struct Worry {
    let value: Int
    let modulus: Int
    
    internal init( value: Int, modulus: Int ) {
        self.value = value
        self.modulus = modulus
    }

    static func *( left: Worry, right: Worry ) -> Worry {
        Worry( value: ( left.value * right.value ) % left.modulus, modulus: left.modulus )
    }
    
    static func +( left: Worry, right: Worry ) -> Worry {
        Worry( value: ( left.value + right.value ) % left.modulus, modulus: left.modulus )
    }
    
    static func /( left: Worry, right: Int ) -> Worry {
        Worry(value: ( left.value / right ) % left.modulus, modulus: left.modulus )
    }
    
    func isMultiple( of: Int ) -> Bool {
        value.isMultiple( of: of )
    }
}


class Simian {
    var items: [Worry]
    var inspectionCount = 0
    let operation: (Worry) -> Worry
    let test: (Worry) -> Bool
    let ifTrue: Int
    let ifFalse: Int
    let bigN: Int
    
    init( lines: [String], bigN: Int ) {
        let items = lines[1].split( whereSeparator: { " ,".contains( $0 ) } )
        self.items = items.dropFirst( 2 ).map { Worry( value: Int( $0 )!, modulus: bigN ) }

        let operation = lines[2].split( separator: " " )
        if let factor = Int( operation[5] ) {
            let worry = Worry( value: factor, modulus: bigN )
            if operation[4] == "*" {
                self.operation = { $0 * worry }
            } else {
                self.operation = { $0 + worry }
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
        self.bigN = bigN
    }
    
    func turn( monkeys: [Simian], reduction: Bool = true ) -> Void {
        inspectionCount += items.count
        for item in items {
            let worry = reduction ? operation( item ) / 3 : operation( item )
            monkeys[ test( worry ) ? ifTrue : ifFalse ].items.append( worry )
        }
        items = []
    }
}


func extractor( input: AOCinput ) -> Int {
    let divisors = input.paragraphs.map { Int( $0[3].split( separator: " " )[3] )! }
    return Set( divisors ).sorted().reduce( 1, * )
}


func part1( input: AOCinput ) -> String {
    let bigN = extractor( input: input )
    let monkeys = input.paragraphs.map { Monkey( lines: $0/*, bigN: bigN*/ ) }

    for _ in 1 ... 20 {
        monkeys.forEach { $0.turn( monkeys: monkeys ) }
    }
    
    let counts = Array( monkeys.map { $0.inspectionCount }.sorted().reversed() )
    
    return "\( counts[0] * counts[1] )"
}


func part2( input: AOCinput ) -> String {
    let bigN = extractor( input: input )
    let monkeys = input.paragraphs.map { Simian( lines: $0, bigN: bigN ) }

    for _ in 1 ... 10000 {
        monkeys.forEach { $0.turn( monkeys: monkeys, reduction: false ) }
    }

    let counts = Array( monkeys.map { $0.inspectionCount }.sorted().reversed() )

    return "\( counts[0] * counts[1] )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
