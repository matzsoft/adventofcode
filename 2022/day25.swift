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

let quintToInt: [ Character : Int ] = [ "=" : -2, "-" : -1, "0" : 0, "1" : 1, "2" : 2 ]
let intToQuint                      = [ -2 : "=", -1 : "-", 0 : "0", 1 : "1", 2 : "2" ]

func snafuToInt( string: String ) -> Int {
    Array( string ).reduce( 0 ) { return 5 * $0 + quintToInt[$1]! }
}


func intToSnafu( number: Int ) -> String {
//    let sign = number.signum()
    var number = number
    var place  = 1
    var result = ""

    while true {
        if abs( number ) <= 5 * place / 2 {
            let basis = ( number + number.signum() * place / 2 )
            let digit = basis / place
            
            result = intToQuint[digit]!
            number -= digit * place
            break
        }
        place *= 5
    }
    
    while place > 1 {
        place /= 5
        let basis = ( number + number.signum() * place / 2 )
        let digit = basis / place
        
        result += intToQuint[digit]!
        number -= digit * place
    }
    
    return result
}


func parse( input: AOCinput ) -> Any? {
    return nil
}


func part1( input: AOCinput ) -> String {
    let numbers = input.lines.map { snafuToInt( string: $0 ) }
    let sum = numbers.reduce( 0, + )
//    numbers.forEach { print( $0 ) }
    return "\(intToSnafu(number: sum ))"
}


func part2( input: AOCinput ) -> String {
    let something = parse( input: input )
    return ""
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
