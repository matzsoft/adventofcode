//
//         FILE: main.swift
//  DESCRIPTION: day04 - Easter Bunny HQ encrypted room names
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 03/24/21 21:38:51
//

import Foundation
import Library

let lowerCaseA = Character("a").unicodeScalars.first!.value

func decrypt( letter: Character, key: Int ) -> Character {
    let encrypted = letter.unicodeScalars.first!.value - lowerCaseA
    let decrypted = ( encrypted + UInt32( key ) ) % 26 + lowerCaseA
    
    return Character( UnicodeScalar( decrypted )! )
}


struct Room {
    let words: [String]
    let sectorID: Int
    let checksum: String
    
    var isValid: Bool {
        let histogram = words.joined().reduce( into: [ Character : Int ]() ) { ( histogram, letter ) in
            histogram[letter] = histogram[ letter, default: 0 ] + 1
        }.sorted { $0.1 > $1.1 ? true : ( $0.1 < $1.1 ? false : ( $0.0 < $1.0 ) ) }
        let check = String( histogram.prefix(5).map( { $0.key } ) )

        return check == checksum
    }
    
    var decryptedName: String {
        return words.map {
            String( $0.map { decrypt( letter: $0, key: sectorID ) } )
        }.joined( separator: " ")
    }
    
    init( line: String ) {
        let chunks = line.split() { "-[]".contains($0) }
        
        words = chunks.prefix( chunks.count - 2 ).map { String( $0 ) }
        checksum = String( chunks.last! )
        sectorID = Int( chunks[ chunks.count - 2 ] )!
    }
}


func parse( input: AOCinput ) -> [Room] {
    return input.lines.map { Room( line: $0 ) }.filter { $0.isValid }
}


func part1( input: AOCinput ) -> String {
    let rooms = parse( input: input )
    let sum = rooms.reduce( 0, { $0 + $1.sectorID } )
    
    return "\(sum)"
}


func part2( input: AOCinput ) -> String {
    let rooms = parse( input: input )
    let target = rooms.first( where: { $0.decryptedName.contains( "north" ) } )!
    
    print("Found \(target.decryptedName)")
    return "\(target.sectorID)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
