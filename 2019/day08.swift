//
//  main.swift
//  day08
//
//  Created by Mark Johnson on 12/7/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

extension StringProtocol {
    func split( by length: Int ) -> [Substring] {
        var startIndex = self.startIndex
        var results = [Substring]()

        while startIndex < self.endIndex {
            let endIndex = self.index( startIndex, offsetBy: length, limitedBy: self.endIndex ) ?? self.endIndex
            
            results.append( self[ startIndex ..< endIndex ] as! Substring )
            startIndex = endIndex
        }

        return results
    }
    
    func countChar( _ char: Character ) -> Int {
        return self.reduce( 0, { $0 + ( ( $1 == char ) ? 1 : 0 ) } )
    }
}


guard CommandLine.arguments.count > 1 else {
    print( "No input file specified" )
    exit( 1 )
}

let input = try String( contentsOfFile: CommandLine.arguments[1] ).dropLast( 1 )
let width = 25
let height = 6
let layerSize = width * height
let layers = String( input ).split( by: layerSize )

var min0Count = Int.max
var part1 = 0

for layer in layers {
    let count0 = layer.countChar( "0" )

    if count0 < min0Count {
        min0Count = count0
        part1 = layer.countChar( "1" ) * layer.countChar( "2" )
    }
}

print( "Part 1: \(part1)" )

var image = ""

for offset in 0 ..< layerSize {
    for layer in layers {
        let index = layer.index( layer.startIndex, offsetBy: offset )
        if layer[index] != "2" {
            switch layer[index] {
            case "0":
                image.append( " " )
            case "1":
                image.append( "█" )
            default:
                break
            }
            break
        }
    }
}

print( "Part 2:" )
image.split( by: width ).forEach { print( $0 ) }
