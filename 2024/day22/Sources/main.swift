//
//         FILE: day22.swift
//  DESCRIPTION: Advent of Code 2024 Day 22: Monkey Market
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/21/24 21:00:28
//

import Foundation
import Library

func nextSecret( secret: Int ) -> Int {
    let step1 = ( ( secret << 6 ) ^ secret ) % 16777216
    let step2 = ( ( step1 >> 5 ) ^ step1 ) % 16777216
    let step3 = ( ( step2 << 11 ) ^ step2 ) % 16777216
    
    return step3
}


func parse( input: AOCinput ) -> Any? {
    return nil
}


func part1( input: AOCinput ) -> String {
    let finals = input.lines.map { Int( $0 )! }.map { initial in
        ( 1 ... 2000 ).reduce( into: initial ) { previous, _ in
            previous = nextSecret( secret: previous )
        }
    }
    return "\( finals.reduce( 0, + ) )"
}


func part2( input: AOCinput ) -> String {
    let secrets = input.lines.map { Int( $0 )! }.map { initial in
        ( 1 ... 2000 ).reduce( into: [initial] ) { secrets, _ in
            secrets.append( nextSecret( secret: secrets.last! ) )
        }
    }
    let prices = secrets.map { $0.map { $0 % 10 } }
    let deltas = prices.map { buyer in
        buyer.indices.dropFirst().reduce( into: [0] ) { deltas, index in
            deltas.append( buyer[index] - buyer[index-1] )
        }
    }
    let changes = deltas.indices.map { index1 in
        deltas[index1].indices.dropFirst( 4 )
            .reduce( into: [ [Int] : Int ]() ) { dict, index2 in
                let prefix = [
                    deltas[index1][index2-3], deltas[index1][index2-2],
                    deltas[index1][index2-1], deltas[index1][index2]
                ]
                if dict[prefix] == nil {
                    dict[prefix] = prices[index1][index2]
                }
            }
    }
    let histogram = changes.reduce(into: [ [Int] : Int ]() ) { histogram, buyer in
        for ( prefix, _ ) in buyer {
            histogram[ prefix, default: 0 ] += 1
        }
    }
    let bestPrefix = histogram
        .sorted { $0.value > $1.value }
    let bananas = bestPrefix.reduce( into: [Int]() ) { bananas, prefix in
        bananas.append( changes.reduce( 0 ) { $0 + $1[ prefix.key, default: 0 ] } )
    }
    return "\(bananas.max()!)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
