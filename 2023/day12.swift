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
    
    var arrangementsCount: Int {
        let count = countArrangements( statuses: statuses, groups: groups )
        return count
    }
    
    func countArrangements( statuses: [SpringStatus], groups: [Int] ) -> Int {
        guard let group = groups.first else {
            return statuses.contains( where: { $0 == .damaged } ) ? 0 : 1
        }
        
        let statuses = Array( statuses.drop( while: { $0 == .operational } ) )
        if statuses.isEmpty { return 0 }
        
        if statuses.count < group { return 0 }

        if statuses[0] == .damaged {
            if statuses[..<group].contains( where: { $0 == .operational } ) { return 0 }
            if statuses.count == group { return groups.count == 1 ? 1 : 0 }
            if statuses[group] == .damaged { return 0 }

            let tail = Array( statuses.dropFirst( group + 1 ) )
            return countArrangements( statuses: tail, groups: Array( groups.dropFirst() ) )
        }
        
        let damaged = {
            if statuses[..<group].contains( where: { $0 == .operational } ) { return 0 }
            if statuses.count == group { return groups.count == 1 ? 1 : 0 }
            if statuses[group] == .damaged { return 0 }

            let tail = Array( statuses.dropFirst( group + 1 ) )
            return countArrangements( statuses: tail, groups: Array( groups.dropFirst() ) )
        }()
        let operational = countArrangements(statuses: Array( statuses.dropFirst() ), groups: groups )
        
        return damaged + operational
    }
}

func parse( input: AOCinput ) -> [Row] {
    return input.lines.map { Row(line: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let rows = parse( input: input )

    return "\( rows.map { $0.arrangementsCount }.reduce( 0, + ) )"
}


func part2( input: AOCinput ) -> String {
    let rows = parse( input: input ).map { $0.unfolded }

    return "\( rows.map { $0.arrangementsCount }.reduce( 0, + ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
