//
//  main.swift
//  day22
//
//  Created by Mark Johnson on 12/21/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation
import BigInt

guard CommandLine.arguments.count > 1 else {
    print( "No input file specified" )
    exit( 1 )
}

let input = try String( contentsOfFile: CommandLine.arguments[1] )
let lines = input.split(separator: "\n" )


enum Command {
    case reverse, cut, dealBy
}

func parse( line: Substring ) -> ( Command, Int ) {
    let words = line.split( separator: " " )
    
    switch true {
    case line.hasPrefix( "deal into" ):
        return ( .reverse, 0 )
    case line.hasPrefix( "cut" ):
        return ( .cut, Int( words[1] )! )
    case line.hasPrefix( "deal with" ):
        return ( .dealBy, Int( words[3] )! )
    default:
        print( "Invalid command '\(line)'" )
        exit(1)
    }
}

func compose( lines: [Substring], cardCount: Int ) -> ( Int, Int ) {
    let ( a, b ) = lines.reduce( ( BigInt( 1 ), BigInt( 0 ) ), { lcd, line -> ( BigInt, BigInt ) in
        let ( command, amount ) = parse( line: line )
        let ( a, b ) = lcd
        var c: BigInt
        var d: BigInt

        switch command {
        case .reverse:
            c = -1
            d = BigInt( cardCount - 1 )
        case .cut:
            c = 1
            d = BigInt( cardCount - amount )
        case .dealBy:
            c = BigInt( amount )
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

func forward( start: Int, cardCount: Int, commands: [Substring] ) -> Int {
    var position = start

    for line in commands {
        let ( command, amount ) = parse( line: line )
        
        switch command {
        case .reverse:
            position = cardCount - position - 1
        case .cut:
            position = ( position + cardCount - amount ) % cardCount
        case .dealBy:
            position = position * amount % cardCount
        }
    }
    
    return position
}


do {
    let cardCount = 10007
    let final = 2019
    let ( a, b ) = compose( lines: lines, cardCount: cardCount )
    let result = ( a * final + b ) % cardCount
    let inverted = invert( lcd: ( a, b ), x: result, m: cardCount )

    print( "Part1:", result )
    
    if inverted != final {
        print( "Inverse got wrong result:", inverted )
    }
}

do {
    let cardCount = 119315717514047
    let repititions = 101741582076661
    let final = 2020
    let ( a, b ) = compose( lines: lines, cardCount: cardCount )
    let ( c, d ) = powerCompose( lcd: ( a, b ), power: repititions, cardCount: cardCount )
    let result = invert( lcd: ( c, d ), x: final, m: cardCount )
    let inverted = ( BigInt( c ) * BigInt( result ) + BigInt( d ) ) % BigInt( cardCount )

    print( "Part2:", result )
    
    if inverted != final {
        print( "Inverse got wrong result:", inverted )
    }
}



// MARK: - Obsolete functions
func compiler( lines: [Substring], cardCount: Int, forward: Bool = true ) -> [ ( _ position: Int ) -> Int ] {
    let buffer = forward ? lines : lines.reversed()
    
    return buffer.map { line in
        let ( command, amount ) = parse( line: line )

        switch command {
        case .reverse:
            return { ( _ position: Int ) -> Int in cardCount - position - 1 }
        case .cut:
            if forward {
                return { ( _ position: Int ) -> Int in ( position + cardCount - amount ) % cardCount }
            }
            return { ( _ position: Int ) -> Int in ( position + cardCount + amount ) % cardCount }
        case .dealBy:
            if forward {
                return { ( _ position: Int ) -> Int in position * amount % cardCount }
            }
            
            guard let multiplier = ( 0 ..< amount ).first( where: {
                ( 1 + cardCount * $0 ) % amount == 0
            } )  else {
                print( "Unexpectedly can't find multiplier" )
                exit(1)
            }
            return { ( _ position: Int ) -> Int in
                return ( position + cardCount * ( position * multiplier % amount ) ) / amount
            }
        }
    }
}

func backward( start: Int, cardCount: Int, commands: [Substring] ) -> Int {
    var position = start

    for line in commands {
        let ( command, amount ) = parse( line: line )
        
        switch command {
        case .reverse:
            position = cardCount - position - 1
        case .cut:
            position = ( position + cardCount + amount ) % cardCount
        case .dealBy:
            guard let multiplier = ( 0 ..< amount ).first( where: {
                ( position + cardCount * $0 ) % amount == 0
            } )  else {
                print( "Unexpected x is unknown" )
                exit(1)
            }
            position = ( position + cardCount * multiplier ) / amount
        }
    }
    
    return position
}

func oldSchool( cardCount: Int, commands: [Substring] ) -> [Int] {
    var deck = ( 0 ..< cardCount ).map { $0 }
    
    for line in commands {
        let ( command, amount ) = parse( line: line )
        
        switch command {
        case .reverse:
            deck.reverse()
        case .cut:
            if amount > 0 {
                deck = Array( deck[ amount ..< deck.count ] ) + deck[ 0 ..< amount ]
            } else {
                deck = Array( deck[ deck.count + amount ..< deck.count ] ) + deck[ 0 ..< deck.count + amount ]
            }
        case .dealBy:
            var stack = deck
            var position = 0
            
            while !stack.isEmpty {
                let card = stack.removeFirst()
                
                deck[position] = card
                position = ( position + amount ) % deck.count
            }
        }
    }
    
    return deck
}
