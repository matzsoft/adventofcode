//
//         FILE: main.swift
//  DESCRIPTION: day05 - Doesn&apos;t He Have Intern-Elves For This?
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/05/21 11:06:30
//

import Foundation


func part1( input: AOCinput ) -> String {
    func isNice( string: String ) -> Bool {
        guard string.filter( { "aeiou".contains( $0 ) } ).count > 2 else { return false }

        if string.range( of: "(.)\\1", options: .regularExpression ) == nil { return false }
        
        if string.contains( "ab" ) { return false }
        if string.contains( "cd" ) { return false }
        if string.contains( "pq" ) { return false }
        if string.contains( "xy" ) { return false }
        
        return true
    }

    return "\( input.lines.filter { isNice( string: $0 ) }.count )"
}


func part2( input: AOCinput ) -> String {
    func isNice( string: String ) -> Bool {
        if string.range( of: "(..).*\\1", options: .regularExpression ) == nil { return false }
        if string.range( of: "(.).\\1", options: .regularExpression ) == nil { return false }

        return true
    }

    return "\( input.lines.filter { isNice( string: $0 ) }.count )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
