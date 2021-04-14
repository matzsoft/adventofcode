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

func captcha( input: [Int], delta: Bool = false ) -> Int {
    let offset = delta ? ( input.count / 2 ) : 1
    
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
    return "\(captcha( input: parse( input: input ), delta: true ))"
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
