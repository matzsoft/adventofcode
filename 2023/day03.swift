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

struct Number {
    let value: Int
    let rect: Rect2D
    
    init( characters: [Character], x: Int, y: Int ) {
        let first = Point2D( x: x - characters.count, y: y )
        let last = Point2D( x: x - 1, y: y )
        
        self.value = Int( String( characters ) )!
        self.rect = Rect2D( min: first, max: last ).pad( by: 1 )
    }
}

struct Symbol {
    let value: Character
    let rect: Rect2D
    
    init( value: Character, x: Int, y: Int ) {
        self.value = value
        self.rect = Rect2D( min: Point2D( x: x, y: y ), max: Point2D( x: x, y: y ) )
    }
}

struct Gear {
    let ratio: Int
    
    init?( adjacent: [Number] ) {
        guard adjacent.count == 2 else { return nil }
        ratio = adjacent[0].value * adjacent[1].value
    }
}


func parse( input: AOCinput ) -> ( [Number], [Symbol] ) {
    enum States { case initial, accumulating }

    let characters = input.lines.map { Array( $0 ) }
    var numbers = [Number]()
    var symbols = [Symbol]()
    
    characters.indices.forEach { y in
        var state = States.initial
        var number = [Character]()
        
        characters[y].indices.forEach { x in
            let character = characters[y][x]
            switch state {
            case .initial:
                switch true {
                case character.isNumber:
                    number.append( character )
                    state = .accumulating
                case character == ".":
                    break
                default:
                    symbols.append( Symbol( value: character, x: x, y: y ) )
                }
            case .accumulating:
                switch true {
                case character.isNumber:
                    number.append( character )
                case character == ".":
                    numbers.append( Number( characters: number, x: x, y: y ) )
                    number = []
                    state = .initial
                default:
                    numbers.append( Number( characters: number, x: x, y: y ) )
                    symbols.append( Symbol( value: character, x: x, y: y ) )
                    number = []
                    state = .initial
                }
            }
        }
        if state == .accumulating {
            numbers.append( Number(characters: number, x: characters[y].count, y: y ) )
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
    let gears = symbols.compactMap { symbol -> Gear? in
        guard symbol.value == "*" else { return nil }
        return Gear( adjacent: numbers.filter { $0.rect.intersection( with: symbol.rect ) != nil } )
    }
    return "\( gears.reduce( 0, { $0 + $1.ratio } ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
