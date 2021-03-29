//
//         FILE: main.swift
//  DESCRIPTION: day09 - Explosives in Cyberspace
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 03/27/21 16:55:41
//

import Foundation

func findCounts( line: String ) throws -> ( v1Count: Int, v2Count: Int ) {
    enum State { case plain, regionLength, expectX, repeatCount, closeParen, region }
    enum ParseError: Error { case badRegionLength, missingX, badRepeatCount, missingCloseParen, invalidEnd }

    let tokens = line.tokenize( delimiters: "(x)" )
    var state = State.plain
    var v1Count = 0
    var v2Count = 0
    var regionLength = 0
    var repeatCount = 0
    var region = ""
    
    for token in tokens {
        switch state {
        case .plain:
            if token == "(" {
                state = .regionLength
            } else {
                v1Count += token.count
                v2Count += token.count
            }
        case .regionLength:
            guard let intValue = Int( token ) else { throw ParseError.badRegionLength }
            regionLength = intValue
            state = .expectX
        case .expectX:
            guard token == "x" else { throw ParseError.missingX }
            state = .repeatCount
        case .repeatCount:
            guard let intValue = Int( token ) else { throw ParseError.badRepeatCount }
            repeatCount = intValue
            state = .closeParen
        case .closeParen:
            guard token == ")" else { throw ParseError.missingCloseParen }
            state = .region
        case .region:
            region += token
            if region.count >= regionLength {
                let difference = region.count - regionLength
                
                v1Count += difference
                v2Count += difference
                region = String( region.dropLast( difference ) )

                v1Count += regionLength * repeatCount
                v2Count += try repeatCount * findCounts( line: region ).v2Count
                region = ""
                state = .plain
            }
        }
    }
    
    guard state == .plain else { throw ParseError.invalidEnd }
    return ( v1Count: v1Count, v2Count: v2Count )
}


func parse( input: AOCinput ) -> ( v1Count: Int, v2Count: Int ) {
    return try! findCounts( line: input.line )
}


func part1( input: AOCinput ) -> String {
    let counts = parse( input: input )
    return "\(counts.v1Count)"
}


func part2( input: AOCinput ) -> String {
    let counts = parse( input: input )
    return "\(counts.v2Count)"
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
