//
//         FILE: day12.swift
//  DESCRIPTION: Advent of Code 2023 Day 12: Hot Springs
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/11/23 21:00:01
//

import Foundation
import Library

enum SpringStatus: Character { case operational = ".", damaged = "#", unknown = "?" }

struct Row {
    let statuses: [SpringStatus]
    let groups: [Int]
    
    init( statuses: [SpringStatus], groups: [Int] ) {
        self.statuses = statuses
        self.groups = groups
    }
    
    init( line: String ) {
        let words = line.split(whereSeparator: { " ,".contains( $0 ) } )
        
        statuses = words[0].map { SpringStatus( rawValue: $0 )! }
        groups = words[1...].map { Int( $0 )! }
    }
    
    var unfolded: Row {
        let groups = Array( repeating: self.groups, count: 5 ).flatMap { $0 }
        let statuses = Array( repeating: self.statuses, count: 5 )
            .joined( separator: [ SpringStatus.unknown ] )
            .compactMap { $0 }
        
        return Row( statuses: statuses, groups: groups )
    }
    
    func countArrangements( statuses: [SpringStatus], groups: [Int] ) -> Int {
        guard let group = groups.first else {
            return statuses.contains( where: { $0 == .damaged } ) ? 0 : 1
        }
        
        let statuses = Array( statuses.drop( while: { $0 == .operational } ) )
        if statuses.isEmpty { return 0 }
        
        if statuses[0] == .unknown {
            let tail = Array( statuses.dropFirst() )
            let damaged = countArrangements( statuses: [ SpringStatus.damaged ] + tail, groups: groups )
            let operational = countArrangements( statuses: tail, groups: groups )
            return operational + damaged
        }
        
        // Now statuses[next] == .damaged
        let damaged = statuses.prefix( while: { $0 == .damaged } )
        if damaged.count > group { return 0 }
        if damaged.count < group {
            if damaged.count == statuses.count { return 0 }
            if statuses[damaged.count] == .operational { return 0 }
            var newStatuses = statuses
            newStatuses[damaged.count] = .damaged
            return countArrangements( statuses: newStatuses, groups: groups )
        }

        // damaged.count == group
        if damaged.count == statuses.count { return groups.count == 1 ? 1 : 0 }
        
        let newStatuses = Array( statuses.dropFirst( damaged.count + 1 ) )
        return countArrangements( statuses: newStatuses, groups: Array( groups.dropFirst() ) )
        
    }
    
    func countArrangements() -> Int {
        let count = countArrangements( statuses: statuses, groups: groups )
        return count
    }
}

func parse( input: AOCinput ) -> [Row] {
    return input.lines.map { Row(line: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let rows = parse( input: input )

    return "\( rows.map { $0.countArrangements() }.reduce( 0, + ) )"
}


func part2( input: AOCinput ) -> String {
    let rows = parse( input: input ).map { $0.unfolded }

    return "\( rows.map { $0.countArrangements() }.reduce( 0, + ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
