//
//         FILE: main.swift
//  DESCRIPTION: day22 - Slam Shuffle
//        NOTES: Requires https://github.com/attaswift/BigInt
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/17/21 15:10:08
//

import Foundation
import Library
import BigInt

struct Command {
    enum Command { case reverse, cut, dealBy }
    
    let type: Command
    let count: Int
    
    init( line: String ) throws {
        let words = line.split( separator: " " )
        
        switch true {
        case line.hasPrefix( "deal into" ):
            type = .reverse
            count = 0
        case line.hasPrefix( "cut" ):
            type = .cut
            count = Int( words[1] )!
        case line.hasPrefix( "deal with" ):
            type = .dealBy
            count = Int( words[3] )!
        default:
            throw RuntimeError( "Invalid command '\(line)'" )
        }
    }
}


func compose( commands: [Command], cardCount: Int ) -> ( Int, Int ) {
    let ( a, b ) = commands.reduce( ( BigInt( 1 ), BigInt( 0 ) ), { lcd, command -> ( BigInt, BigInt ) in
        let ( a, b ) = lcd
        var c: BigInt
        var d: BigInt

        switch command.type {
        case .reverse:
            c = -1
            d = BigInt( cardCount - 1 )
        case .cut:
            c = 1
            d = BigInt( cardCount - command.count )
        case .dealBy:
            c = BigInt( command.count )
            d = 0
        }
        return ( a * c % BigInt( cardCount ), ( b * c + d ) % BigInt( cardCount ) )
    })
    
    return ( Int( a ), Int( b ) )
}


func powerMod( x: Int, n: Int, m: Int ) -> Int {
    guard n > 0 else { return 1 }
    
    var x = BigInt( x )
    var n = n
    let m = BigInt( m )
    var y = BigInt( 1 )
    
    while n > 1 {
        if n & 1 == 1 {
            y = x * y % m
        }
        x = x * x % m
        n = n / 2                   // This is the same as ( n - 1 ) / 2 when n is odd
    }
    
    return Int( x * y % m )
}


func invert( lcd: ( Int, Int), x: Int, m: Int ) -> Int {
    let a = lcd.0
    let b = BigInt( lcd.1 )
    let x = BigInt( x )
    let bigM = BigInt( m )
    
    return Int( ( x - b + bigM ) * BigInt( powerMod( x: a, n: m - 2, m: m ) ) % bigM )
}


func powerCompose( lcd: ( Int, Int ), power: Int, cardCount: Int ) -> ( Int, Int ) {
    let a = lcd.0
    let b = BigInt( lcd.1 )
    let newA = Int( powerMod( x: a, n: power, m: cardCount ) )
    let modinv = BigInt( powerMod( x: cardCount + 1 - a, n: cardCount - 2, m: cardCount ) )
    let newB = ( b * BigInt( 1 - newA ) * modinv ) % BigInt( cardCount )
    
    return ( newA, Int( newB ) )
}


func parse( input: AOCinput ) -> [Command] {
    return input.lines.map { try! Command( line: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let commands = parse( input: input )
    let cardCount = 10007
    let final = 2019
    let ( a, b ) = compose( commands: commands, cardCount: cardCount )
    let result = ( a * final + b ) % cardCount
    let inverted = invert( lcd: ( a, b ), x: result, m: cardCount )

    if inverted != final {
        print( "Inverse got wrong result:", inverted )
    }
    return "\(result)"
}


func part2( input: AOCinput ) -> String {
    let commands = parse( input: input )
    let cardCount = 119315717514047
    let repititions = 101741582076661
    let final = 2020
    let ( a, b ) = compose( commands: commands, cardCount: cardCount )
    let ( c, d ) = powerCompose( lcd: ( a, b ), power: repititions, cardCount: cardCount )
    let result = invert( lcd: ( c, d ), x: final, m: cardCount )
    let inverted = ( BigInt( c ) * BigInt( result ) + BigInt( d ) ) % BigInt( cardCount )

    if inverted != final {
        print( "Inverse got wrong result:", inverted )
    }
    return "\(result)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
