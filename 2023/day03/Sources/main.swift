//
//         FILE: day03.swift
//  DESCRIPTION: Advent of Code 2023 Day 3: Gear Ratios
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/02/23 21:00:02
//

import Foundation
import Library

extension Array {
    func findIndices( where predicate: (Element) -> Bool ) -> [Int] {
        indices.filter { predicate( self[$0] ) }
    }
    
    func ranges( where predicate: (Element) -> Bool ) -> [Range<Int>] {
        let indices = findIndices( where: predicate )
        if indices.isEmpty { return [] }
        
        var firstIndex = indices[0]
        var lastIndex = indices[0]
        let ranges = indices[1...].reduce( into: [Range<Int>]() ) { ranges, index in
            if index > lastIndex + 1 {
                ranges.append( firstIndex ..< lastIndex + 1 )
                firstIndex = index
            }
            lastIndex = index
        }
        return ranges + [ firstIndex ..< lastIndex + 1 ]
    }
}

struct Number {
    let value: Int
    let rect: Rect2D
    
    init( characters: [Character], range: Range<Int>, y: Int ) {
        let first = Point2D( x: range.lowerBound, y: y )
        let last = Point2D( x: range.upperBound - 1, y: y )
        
        self.value = Int( String( characters[range] ) )!
        self.rect = Rect2D( min: first, max: last ).pad( by: 1 )
    }
}

struct Symbol {
    let value: Character
    let rect: Rect2D
    
    init( characters: [Character], x: Int, y: Int ) {
        self.value = characters[x]
        self.rect = Rect2D( min: Point2D( x: x, y: y ), max: Point2D( x: x, y: y ) )
    }
}

func gearRatio( symbol: Symbol, numbers: [Number] ) -> Int? {
    guard symbol.value == "*" else { return nil }
    let adjacent = numbers.filter { $0.rect.intersection( with: symbol.rect ) != nil }
    guard adjacent.count == 2 else { return nil }
    return adjacent[0].value * adjacent[1].value
}


func parse( input: AOCinput ) -> ( [Number], [Symbol] ) {
    let symbols = input.lines.indices.reduce( into: [Symbol]() ) { symbols, y in
        let characters = Array( input.lines[y] )
        characters.findIndices ( where: { !$0.isNumber && $0 != "." } ).forEach { x in
            symbols.append( Symbol( characters: characters, x: x, y: y ) )
        }
    }
    let numbers = input.lines.indices.reduce( into: [Number]() ) { numbers, y in
        let characters = Array( input.lines[y] )
        characters.ranges( where: { $0.isNumber } ).forEach { range in
            numbers.append( Number( characters: characters, range: range, y: y ) )
        }
    }
    
    return ( numbers, symbols )
}


func part1( input: AOCinput ) -> String {
    let ( numbers, symbols ) = parse( input: input )
    let parts = numbers.filter { number in
        symbols.contains { $0.rect.intersection( with: number.rect ) != nil }
    }
    
    return "\( parts.reduce( 0, { $0 + $1.value } ) )"
}


func part2( input: AOCinput ) -> String {
    let ( numbers, symbols ) = parse( input: input )
    
    return "\( symbols.compactMap { gearRatio( symbol: $0, numbers: numbers ) }.reduce( 0, + ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
