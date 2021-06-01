//
//         FILE: main.swift
//  DESCRIPTION: day08 - Space Image Format
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/01/21 13:48:27
//

import Foundation

let width = 25
let height = 6
let layerSize = width * height

extension Array {
    func split( by length: Int ) -> [[Element]] {
        return stride( from: startIndex, to: endIndex, by: length ).map {
            return Array( self[ $0 ..< $0 + length ] )
        }
    }
}


extension Array where Element: Equatable {
    func count( char: Element ) -> Int {
        return self.filter { $0 == char }.count
    }
}


func parse( input: AOCinput ) -> [[Character]] {
    return Array( input.line ).split( by: layerSize )
}


func part1( input: AOCinput ) -> String {
    let layers = parse( input: input )
    let targetLayer = layers.min( by: { $0.count( char: "0" ) < $1.count( char: "0") } )!

    return "\(targetLayer.count( char: "1" ) * targetLayer.count( char: "2" ))"
}


func part2( input: AOCinput ) -> String {
    let layers = parse( input: input )
    let blockLetters = try! BlockLetterDictionary( from: "5x6+0.txt" )
    
    let image = ( 0 ..< layerSize ).map { index -> Bool in
        for layer in layers {
            if layer[index] != "2" {
                switch layer[index] {
                case "0":
                    return false
                case "1":
                    return true
                default:
                    break
                }
                break
            }
        }
        return false
    }.split( by: width )
    
    return "\(blockLetters.makeString( screen: image ) )"
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
