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

func mostCommon( report: [String], index: String.Index ) -> Character {
    let count = report.filter { $0[index] == "1" }.count
    
    if count > report.count / 2 { return "1" }
    if count < report.count / 2 { return "0" }
    if report.count.isMultiple( of: 2 ) { return "1" }
    return "0"
}


func part1( input: AOCinput ) -> String {
    var gamma = ""
    var epsilon = ""
    for index in input.lines[0].indices {
        let frequent = mostCommon( report: input.lines, index: index )
        gamma.append( frequent )
        epsilon.append( frequent == "1" ? "0" : "1" )
    }
    let gammaRate = Int( gamma, radix: 2 )!
    let epsilonRate = Int( epsilon, radix: 2 )!
    return "\( gammaRate * epsilonRate )"
}


func elimination( report: [String], predicate: ( Character, Character ) -> Bool ) -> Int {
    var report = report
    
    for index in report[0].indices {
        let frequent = mostCommon( report: report, index: index )
        
        report = report.filter { predicate( $0[index], frequent ) }
        if report.count == 1 { break }
    }

    return Int( report[0], radix: 2 )!
}


func part2( input: AOCinput ) -> String {
    let O2rating = elimination( report: input.lines, predicate: == )
    let CO2rating = elimination( report: input.lines, predicate: != )

    return "\( O2rating * CO2rating )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
