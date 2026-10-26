//
//         FILE: main.swift
//  DESCRIPTION: day20 - Firewall Rules
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/08/21 20:01:17
//

import Foundation
import Library

struct Range {
    let low: Int
    let high: Int
    
    init( low: Int, high: Int ) {
        self.low = low
        self.high = high
    }
    
    init( line: String ) {
        let words = line.split( separator: "-" )
        
        low = Int( words[0] )!
        high = Int( words[1] )!
    }
    
    func overlaps( other: Range ) -> Bool {
        return low <= other.low && other.low <= high + 1
    }
}

func sortMerge( original: [Range] ) -> [Range] {
    let sorted = original.sorted {
        if $0.low < $1.low { return true }
        if $0.low > $1.low { return false }
        return $0.high < $1.high
    }
    var results: [Range] = []
    var i = 0
    
    while i < sorted.count - 1 {
        var merged = sorted[i]
        var j = i + 1
        
        while merged.overlaps( other: sorted[j] ) {
            merged = Range( low: merged.low, high: max( merged.high, sorted[j].high ) )
            j += 1
            if j >= sorted.count { break }
        }
        
        results.append( merged )
        i = j
    }
    
    return results
}




func parse( input: AOCinput ) -> [Range] {
    return input.lines.map { Range( line: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let original = parse( input: input )
    let sorted = sortMerge( original: original )

    return "\(sorted[0].low > 0 ? 0 : sorted[0].high + 1)"
}


func part2( input: AOCinput ) -> String {
    let original = parse( input: input )
    let sorted = sortMerge( original: original )
    var count = sorted[0].low

    for i in 0 ..< sorted.count - 1 {
        count += sorted[ i + 1 ].low - sorted[i].high - 1
    }
    count += Int( UInt32.max ) - sorted.last!.high

    return "\(count)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
