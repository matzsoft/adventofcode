//
//         FILE: main.swift
//  DESCRIPTION: day25 - Full of Hot Air
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/24/22 21:20:49
//

import Foundation
import Library

let quintToInt: [ Character : Int ] = [ "=" : -2, "-" : -1, "0" : 0, "1" : 1, "2" : 2 ]
let intToQuint                      = [ -2 : "=", -1 : "-", 0 : "0", 1 : "1", 2 : "2" ]

func snafuToInt( string: String ) -> Int {
    Array( string ).reduce( 0 ) { return 5 * $0 + quintToInt[$1]! }
}


func intToSnafu( number: Int ) -> String {
    var number = number
    var place  = 1
    var result = ""

    while abs( number ) > 5 * place / 2 { place *= 5 }
    while place > 0 {
        let digit = ( number + number.signum() * place / 2 ) / place
        
        result += intToQuint[digit]!
        number -= digit * place
        place /= 5
    }
    
    return result
}


func part1( input: AOCinput ) -> String {
    let numbers = input.lines.map { snafuToInt( string: $0 ) }
    let sum = numbers.reduce( 0, + )

    return "\(intToSnafu( number: sum ))"
}


func part2( input: AOCinput ) -> String {
    return "None"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
