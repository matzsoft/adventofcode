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

struct Row: Hashable {
    let statuses: [SpringStatus]
    let groups: [Int]
    let needsOperational: Bool
    
    init( statuses: [SpringStatus], groups: [Int], needsOperational: Bool = false ) {
        self.statuses = statuses
        self.groups = groups
        self.needsOperational = needsOperational
    }
    
    init( line: String ) {
        let words = line.split(whereSeparator: { " ,".contains( $0 ) } )
        
        statuses = words[0].map { SpringStatus( rawValue: $0 )! }
        groups = words[1...].map { Int( $0 )! }
        needsOperational = false
    }

    func append( other: Row, seperator: [ SpringStatus ] ) -> Row {
        Row(
            statuses: statuses + seperator + other.statuses,
            groups: groups + other.groups,
            needsOperational: needsOperational
        )
    }
    
    func dropFirst( statuses: [SpringStatus], needsOperation: Bool = false ) -> Row {
        let tail = Array( statuses.dropFirst( groups[0] + 1 ) )
        return Row( statuses: tail, groups: Array( groups.dropFirst() ), needsOperational: needsOperation )
    }
    
    func dropUnknown( statuses: [SpringStatus] ) -> Row {
        Row( statuses: Array( statuses.dropFirst() ), groups: groups )
    }
    
    func check( group: Int, statuses: [SpringStatus], last: Bool ) -> [ Row : Int ] {
        if statuses[..<group].contains( where: { $0 == .operational } ) { return [:] }
        if group < statuses.count {
            if statuses[group] == .damaged { return [:] }
            return dropFirst( statuses: statuses ).countArrangements( last: last )
        }
        
        if !last { return [ dropFirst( statuses: statuses, needsOperation: true ) : 1 ] }
        return groups.count == 1 ? [ Row( statuses: [], groups: [] ) : 1 ] : [:]
    }
    
    func countArrangements( last: Bool ) -> [ Row : Int ] {
        guard let group = groups.first else {
            if !last { return [ self : 1 ] }
            return statuses.contains( where: { $0 == .damaged } ) ? [:] : [ self : 1 ]
        }
        
        let statuses = Array( statuses.drop( while: { $0 == .operational } ) )
        if statuses.isEmpty { return last ? [:] : [ Row( statuses: [], groups: groups ) : 1 ] }
        
        if statuses.count < group { return last ? [:] : [ Row( statuses: statuses, groups: groups ) : 1 ] }

        if statuses[0] == .damaged {
            return check( group: group, statuses: statuses, last: last )
        }
        
        let damaged: [ Row : Int ] = check( group: group, statuses: statuses, last: last )
        let operational = dropUnknown( statuses: statuses ).countArrangements( last: last )
        
        return damaged.merging( operational, uniquingKeysWith: + )
    }

    var arrangementsCount: Int {
        countArrangements( statuses: statuses, groups: groups )
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
        let operational = countArrangements( statuses: Array( statuses.dropFirst() ), groups: groups )
        
        return damaged + operational
    }
}


func part1( input: AOCinput ) -> String {
    let rows = input.lines.map { Row(line: $0 ) }

    return "\( rows.map { $0.arrangementsCount }.reduce( 0, + ) )"
}


func part2( input: AOCinput ) -> String {
    let rows = input.lines.map { Row(line: $0 ) }
    let foldCount = 5
    let foldSeperator = [ SpringStatus.unknown ]
    let counts = rows.map { row in
        var tails = [ row : 1 ]
        var newTails = [ Row : Int ]()
        for fold in 1 ... foldCount {
            let updatedTails = tails.map { tail in
                tail.key
                    .countArrangements( last: fold == foldCount )
                    .mapValues { $0 * tail.value }
            }
            newTails = [:]
            updatedTails.forEach { newTails.merge( $0, uniquingKeysWith: + ) }
            if fold < foldCount {
                tails = updatedTails.reduce( into: [ Row : Int ]() ) { newTails, updatedTails in
                    newTails.merge( updatedTails, uniquingKeysWith: + )
                }.reduce( into: [ Row : Int ]() ) { tails, tail in
                    let newTail = tail.key.append( other: row, seperator: foldSeperator )
                    if !tail.key.needsOperational {
                        tails[ newTail ] = tail.value
                    } else if newTail.statuses[0] != .damaged {
                        tails[ newTail.dropUnknown( statuses: newTail.statuses ) ] = tail.value
                    }
                }
            }
        }
        
        return newTails
    }

    return "\( counts.map { $0.values.reduce( 0, + ) }.reduce( 0, + ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
