//
//         FILE: main.swift
//  DESCRIPTION: day16 - Dragon Checksum
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/04/21 23:09:26
//

import Foundation

extension Substring {
    subscript( offset: Int ) -> Character {
        return self[ self.index( self.startIndex, offsetBy: offset ) ]
    }
}

func checksum( input: Substring ) -> String {
    guard input.count > 2 else { return input[0] == input[1] ? "1" : "0" }
    
    let index = input.index( input.startIndex, offsetBy: input.count / 2 )
    let left = input[..<index]
    let right = input[index...]
    
    if left == right { return "1" }
    return checksum( input: left ) == checksum( input: right ) ? "1" : "0"
}

func checksum( input: String ) -> String {
    let current = input.count
    var chunkSize = 1
    var result = ""
    
    while current & chunkSize == 0 { chunkSize <<= 1 }
    for offset in stride( from: 0, to: input.count, by: chunkSize ) {
        let startIndex = input.index( input.startIndex, offsetBy: offset )
        let endIndex = input.index( startIndex, offsetBy: chunkSize  )
        
        result += checksum( input: input[ startIndex ..< endIndex ] )
    }
    
    return result
}

func fill( length: Int, initial: String ) -> String {
    var data = initial
    
    while data.count < length {
        data += "0" + data.reversed().map { $0 == "1" ? "0" : "1" }
    }
    
    return String( data.prefix( length ) )
}

func fillAndChecksum( length: Int, initial: String ) -> String {
    return checksum( input: fill( length: length, initial: initial ) )
}


func parse( input: AOCinput ) -> String {
    return input.line
}


func part1( input: AOCinput ) -> String {
    let initial = parse( input: input )
    
    return "\(fillAndChecksum( length: 272, initial: initial ))"
}


func part2( input: AOCinput ) -> String {
    let initial = parse( input: input )
    
    return "\(fillAndChecksum( length: 35651584, initial: initial ))"
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
