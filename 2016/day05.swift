//
//         FILE: main.swift
//  DESCRIPTION: day05 - How About a Nice Game of Chess?
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 03/24/21 23:05:40
//

import Foundation

let passwordLength = 8

func parse( input: AOCinput ) -> String {
    return input.line
}


func part1( input: AOCinput ) -> String {
    let doorID = parse( input: input )
    var index = 0
    var password = ""

    while password.count < passwordLength {
        let hash = md5Hash( str: "\(doorID)\(index)" )
        
        if hash.starts( with: "00000" ) {
            password.append( hash[ hash.index( hash.startIndex, offsetBy: 5 ) ] )
        }
        index += 1
    }
    return password
}


func part2( input: AOCinput ) -> String {
    let doorID = parse( input: input )
    var index = 0
    var password = Array<Character?>( repeating: nil, count: passwordLength )

    while password.filter( { $0 != nil } ).count < passwordLength {
        let hash = md5Hash( str: "\(doorID)\(index)" )

        if hash.starts( with: "00000" ) {
            let char6 = hash[ hash.index( hash.startIndex, offsetBy: 5 ) ]
            
            if let position = Int( String( char6 ), radix: 16 ) {
                if position < passwordLength && password[position] == nil {
                    password[position] = hash[ hash.index( hash.startIndex, offsetBy: 6 ) ]
                }
            }
        }
        index += 1
    }
    
    return password.map { String( $0! ) }.joined()
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
