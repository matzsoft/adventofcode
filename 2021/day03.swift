//
//         FILE: main.swift
//  DESCRIPTION: day03 - Binary Diagnostic
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/02/21 21:07:35
//

import Foundation

func mostCommon( report: [[Character]], index: Array<Character>.Index ) -> Character {
    let count = report.filter { $0[index] == "1" }.count
    
    if count > report.count / 2 { return "1" }
    if count < report.count / 2 { return "0" }
    if report.count.isMultiple( of: 2 ) { return "1" }
    return "0"
}


func parse( input: AOCinput ) -> [[Character]] {
    return input.lines.map { [Character]( $0 ) }
}


func part1( input: AOCinput ) -> String {
    let report = parse( input: input )
    var gamma = [Character]()
    var epsilon = [Character]()
    for index in report[0].indices {
        let frequent = mostCommon( report: report, index: index )
        gamma.append( frequent )
        epsilon.append( frequent == "1" ? "0" : "1" )
    }
    let gammaRate = Int( String( gamma ), radix: 2 )!
    let epsilonRate = Int( String( epsilon ), radix: 2 )!
    return "\( gammaRate * epsilonRate )"
}


func elimination( report: [[Character]], predicate: ( Character, Character ) -> Bool ) -> Int {
    var report = report
    
    for index in report[0].indices {
        let frequent = mostCommon( report: report, index: index )
        
        report = report.filter { predicate( $0[index], frequent ) }
        if report.count == 1 { break }
    }

    return Int( String( report[0] ), radix: 2 )!
}


func part2( input: AOCinput ) -> String {
    let report = parse( input: input )
    let O2rating = elimination( report: report, predicate: == )
    let CO2rating = elimination( report: report, predicate: != )

    return "\( O2rating * CO2rating )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
