//
//  main.swift
//  day05
//
//  Created by Mark Johnson on 11/28/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

let passwordLength = 8
let doorID = "reyedfim"
var part1Password = ""
var part2Password: [Int:Character] = [:]

for index in 0 ... Int.max {
    let md5 = "\(doorID)\(index)".utf8.md5
    
    if md5.description.starts(with: "00000") {
        let hex = md5.description
        let char6 = hex[ hex.index( hex.startIndex, offsetBy: 5 ) ]
        
        if part1Password.count < passwordLength {
            part1Password.append( char6 )
        }
        
        if let position = Int( String(char6), radix: 16 ) {
            if position < passwordLength && part2Password[position] == nil {
                part2Password[position] = hex[ hex.index( hex.startIndex, offsetBy: 6 ) ]
                if part2Password.keys.count == passwordLength { break }
            }
        }
    }
}

print( "Part1:", part1Password )

let sorted = part2Password.sorted( by: { $0.0 < $1.0 } )

print( "Part2:", String( sorted.map( { $0.value } ) ) )
