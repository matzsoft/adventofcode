//
//         FILE: main.swift
//  DESCRIPTION: day02 - Password Philosophy
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/23/21 16:52:15
//

import Foundation

struct Password {
    let first: Int
    let last: Int
    let letter: Character
    let value: [Character]
    
    init( line: String ) {
        let fields = line.split( whereSeparator: { "- :".contains( $0 ) } )
        
        first  = Int( fields[0] )!
        last   = Int( fields[1] )!
        letter = Character( String( fields[2] ) )
        value  = Array( fields[3] )
    }
}


func parse( input: AOCinput ) -> [Password] {
    return input.lines.map { Password( line: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let passwords = parse( input: input )
    let counts = passwords.map { password in password.value.filter { $0 == password.letter }.count }
    let pairs = zip( passwords, counts )
    
    return "\( pairs.filter { $0.0.first <= $0.1 && $0.1 <= $0.0.last }.count )"
}


func part2( input: AOCinput ) -> String {
    let passwords = parse( input: input )
    let valid = passwords.filter {
        ( $0.value[ $0.first - 1 ] == $0.letter ) != ( $0.value[ $0.last - 1 ] == $0.letter )
    }
    
    return "\( valid.count )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
