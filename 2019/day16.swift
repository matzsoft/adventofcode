//
//  main.swift
//  day16
//
//  Created by Mark Johnson on 12/16/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let basePattern = [ 0, 1, 0, -1 ]

func repeatingPattern( signalIndex: Int ) -> [ Int ] {
    return basePattern.flatMap { Array(repeating: $0, count: signalIndex + 1 ) }
}

func elementTerm( signal: [Int], signalIndex: Int, pattern: [Int] ) -> Int {
    return signal[signalIndex] * pattern[ ( signalIndex + 1 ) % pattern.count ]
}

func newSignalElement( signal: [Int], signalIndex: Int ) -> Int {
    let pattern = repeatingPattern( signalIndex: signalIndex )
    let sum = signal.indices.reduce( 0, {
        $0 + elementTerm( signal: signal, signalIndex: $1, pattern: pattern )
    } )
    
    return abs( sum % 10 )
}

func phase( signal: [Int] ) -> [Int] {
    return signal.indices.map { newSignalElement( signal: signal, signalIndex: $0 ) }
}

func signature( signal: [Int] ) -> String {
   return signal[ ..<8 ].map { String( $0 ) }.joined()
}

func phase2( signal: [Int] ) -> [Int] {
    var sum = 0
    
    return signal.map { sum += $0; return sum % 10 }
}

func signature2( signal: [Int] ) -> String {
    return signature( signal: signal.reversed() )
}


guard CommandLine.arguments.count > 1 else {
    print( "No input file specified" )
    exit( 1 )
}

//let input = "69317163492948606335995924319873"
let input = try String( contentsOfFile: CommandLine.arguments[1] ).dropLast( 1 )
let signal = input.map { Int( String( $0 ) )! }
let msgOffset = signal[ ..<7 ].reduce( 0, { 10 * $0 + $1 } )
var lastSignal = signal

( 1 ... 100 ).forEach { _ in lastSignal = phase( signal: lastSignal ) }

print( "Part 1: \( signature( signal: lastSignal ) )" )

let part2Length = 10000 * signal.count
var part2Signal = Array( signal[ ( msgOffset % signal.count )... ] )

( 0 ..< ( ( part2Length - msgOffset ) / signal.count ) ).forEach { _ in
    part2Signal.append( contentsOf: signal )
}

part2Signal.reverse()
( 1 ... 100 ).forEach { _ in part2Signal = phase2( signal: part2Signal ) }

print( "Part 2: \( signature2( signal: part2Signal ) )" )
