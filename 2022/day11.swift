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

let primes = Primes( to: 10000 )

struct PFInt {
    let factors: [ Int : Int ]
    
    init( factors: [ Int : Int ] ) {
        self.factors = factors
    }
    
    init( _ value: Int ) {
        factors = Dictionary( uniqueKeysWithValues: primes.primeFactors( of: value ) )
    }
    
    init?( _ value: String.SubSequence ) {
        guard let value = Int( value ) else { return nil }
        self.init( value )
    }
    
    var toInt: Int {
        factors.keys.reduce( 1, * )
    }
    
    static func *( left: PFInt, right: PFInt ) -> PFInt {
        var factors = left.factors
        for factor in right.factors {
            factors[ factor.key, default: 0 ] += factor.value
        }
        return PFInt( factors: factors )
    }
    
    static func +( left: PFInt, right: PFInt ) -> PFInt {
        return PFInt( left.toInt + right.toInt )
//        guard let quotient = left / right else { fatalError( "Trying to add a non-factor" ) }
//        guard right.factors.count == 1 else { fatalError( "Unable to add non primes" ) }
//        return quotient
    }
    
    static func /( left: PFInt, right: PFInt ) -> PFInt? {
        var factors = left.factors
        for factor in right.factors {
            if factors[ factor.key, default: 0 ] < factor.value { return nil }
            factors[ factor.key, default: factor.value ] -= factor.value
        }
        return PFInt( factors: factors )
    }
    
    func doubled() -> PFInt {
        var factors = factors
        
        factors[ 2, default: 0 ] += 1
        return PFInt( factors: factors )
    }
    
    func squared() -> PFInt {
        PFInt( factors: factors.mapValues { $0 * 2 } )
    }
    
    func isMultiple( of: Int ) -> Bool {
        factors[of] != nil
    }
    
    func knockBack() -> PFInt {
        PFInt( factors: factors.mapValues { _ in 1 } )
    }
}

class Simian {
    var items: [PFInt]
    var inspectionCount = 0
    let operation: (PFInt) -> PFInt
    let test: (PFInt) -> Bool
    let ifTrue: Int
    let ifFalse: Int
    
    init( lines: [String] ) {
        let items = lines[1].split( whereSeparator: { " ,".contains( $0 ) } )
        self.items = items.dropFirst( 2 ).map { PFInt( $0 )! }

        let operation = lines[2].split( separator: " " )
        if let factor = PFInt( operation[5] ) {
            if operation[4] == "*" {
                self.operation = { $0 * factor }
            } else {
                self.operation = { $0 + factor }
            }
        } else {
            if operation[4] == "*" {
                self.operation = { $0.squared() }
            } else {
                self.operation = { $0.doubled() }
            }
        }

        let divisor = Int( lines[3].split( separator: " " )[3] )!
        guard primes.primes.contains( divisor ) else { fatalError( "\(divisor) is not prime") }
        self.test = { $0.isMultiple( of: divisor ) }
        
        ifTrue = Int( lines[4].split( separator: " " )[5] )!
        ifFalse = Int( lines[5].split( separator: " " )[5] )!
    }
    
    func turn( monkeys: [Simian] ) -> Void {
        inspectionCount += items.count
        for item in items {
            let worry = operation( item )
            monkeys[ test( worry ) ? ifTrue : ifFalse ].items.append( worry )
        }
        items = []
    }
}

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


func part1( input: AOCinput ) -> String {
    let monkeys = input.paragraphs.map { Monkey( lines: $0 ) }
    
    for _ in 1 ... 20 {
        monkeys.forEach { $0.turn( monkeys: monkeys ) }
    }
    
    let counts = Array( monkeys.map { $0.inspectionCount }.sorted().reversed() )
    
    return "\( counts[0] * counts[1] )"
}


func part2( input: AOCinput ) -> String {
    let monkeys = input.paragraphs.map { Simian( lines: $0 ) }

    for _ in 1 ... 10000 {
        monkeys.forEach { $0.turn( monkeys: monkeys ) }
    }

    let counts = Array( monkeys.map { $0.inspectionCount }.sorted().reversed() )

    return "\( counts[0] * counts[1] )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
