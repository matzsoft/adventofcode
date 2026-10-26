//
//         FILE: main.swift
//  DESCRIPTION: day04 - Secure Container
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/31/21 22:55:02
//

import Foundation
import Library


func parse( input: AOCinput ) -> [Int] {
    return input.line.split( separator: "-" ).map { Int( $0 )! }
}


func findWithDuplicate( bounds: [Int] ) -> [Int] {
    return ( bounds[0] ... bounds[1] ).filter {
        let digits = Array( String( $0 ) )
        var duplicate = false
        var last: Character = " "
        
        for digit in digits {
            if digit < last {
                return false
            }
            if digit == last {
                duplicate = true
            }
            last = digit
        }
        
        return duplicate
    }
}


func part1( input: AOCinput ) -> String {
    let bounds = parse( input: input )
    let list = findWithDuplicate( bounds: bounds )
    
    return "\(list.count)"
}


func part2( input: AOCinput ) -> String {
    let bounds = parse( input: input )
    let list = findWithDuplicate( bounds: bounds ).filter {
        let digits = Array( String( $0 ) )
        var duplicateCount = 1
        var last: Character = " "
        
        for digit in digits {
            if digit == last {
                duplicateCount += 1
            } else if duplicateCount == 2 {
                return true
            } else {
                duplicateCount = 1
            }
            last = digit
        }
        
        return duplicateCount == 2
    }
    
    return "\(list.count)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
