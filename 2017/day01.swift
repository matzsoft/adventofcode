//
//         FILE: main.swift
//  DESCRIPTION: day01 - Inverse Captcha
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/13/21 17:36:19
//

import Foundation
import Library

func captcha( input: [Int], offset: Int = 1 ) -> Int {
    return zip( input, input[offset...] + input[..<offset] ).reduce( 0 ) {
        return $0 + ( $1.0 == $1.1 ? $1.0 : 0 )
    }
}


func parse( input: AOCinput ) -> [Int] {
    return Array( input.line ).map { Int( String( $0 ) )! }
}


func part1( input: AOCinput ) -> String {
    return "\(captcha( input: parse( input: input ) ))"
}


func part2( input: AOCinput ) -> String {
    let digits = parse( input: input )
    return "\(captcha( input: digits, offset: digits.count / 2 ))"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
