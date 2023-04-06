//
//         FILE: main.swift
//  DESCRIPTION: day04 - The Ideal Stocking Stuffer
//        NOTES: Using md5Fast instead of md5Hash runs 20 times faster.
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/03/21 22:47:10
//

import Foundation
import Library

//func part1( input: AOCinput ) -> String {
//    var number = 0
//
//    while !md5Hash( str: "\(input.line)\(number)" ).hasPrefix( "00000" ) {
//        number += 1
//    }
//    return "\(number)"
//}


func part1( input: AOCinput ) -> String {
    var number = 0
    
    while true {
        let hash = md5Fast( str: "\(input.line)\(number)" )
        if hash[0] == 0 && hash[1] == 0 && hash[2] < 0x10 {
            return "\(number)"
        }
        number += 1
    }
}


//func part2( input: AOCinput ) -> String {
//    var number = 0
//
//    while !md5Hash( str: "\(input.line)\(number)" ).hasPrefix( "000000" ) {
//        number += 1
//    }
//    return "\(number)"
//}


func part2( input: AOCinput ) -> String {
    var number = 0
    
    while true {
        let hash = md5Fast( str: "\(input.line)\(number)" )
        if hash[0] == 0 && hash[1] == 0 && hash[2] == 0 {
            return "\(number)"
        }
        number += 1
    }
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
