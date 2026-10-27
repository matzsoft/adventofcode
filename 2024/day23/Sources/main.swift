//
//         FILE: day23.swift
//  DESCRIPTION: Advent of Code 2024 Day 23: LAN Party
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/22/24 21:02:14
//

import Foundation
import Library

struct Network {
    let connectedTo: [ String : Set<String> ]
    
    init( lines: [String] ) {
        connectedTo = lines.reduce( into: [ String : Set<String> ]() ) {
            let fields = $1.split( separator: "-" ).map { String( $0 ) }
            $0[ fields[0], default: Set() ].insert( fields[1] )
            $0[ fields[1], default: Set() ].insert( fields[0] )
        }
    }
    
    var findThrees: Set<Set<String>> {
        var result = Set<Set<String>>()
        for ( target, connected ) in connectedTo {
            for computer in connected {
                let inCommon = connected.intersection( connectedTo[computer]! )
                for endpoint in inCommon {
                    result.insert( Set( [ target, computer, endpoint ] ) )
                }
            }
        }
        return result
    }
    
    func findNext( current: Set<Set<String>> ) -> Set<Set<String>> {
        var result = Set<Set<String>>()
        for candidate in current {
            let initial = connectedTo[ candidate.first! ]!
            let intersection = candidate.reduce( into: initial ) {
                $0 = $0.intersection( connectedTo[$1]! )
            }
            for endpoint in intersection {
                result.insert( candidate.union( [ endpoint ] ) )
            }
        }

        return result
    }
}


func parse( input: AOCinput ) -> Any? {
    return nil
}


func part1( input: AOCinput ) -> String {
    let network = Network( lines: input.lines )
    let sets = network.findThrees
    let goal = sets.filter { $0.contains { $0.hasPrefix( "t") } }
    return "\(goal.count)"
}


func part2( input: AOCinput ) -> String {
    let network = Network( lines: input.lines )
    let starter = network.findThrees
    var currentLevel = starter
    
    while true {
        var nextLevel = network.findNext( current: currentLevel )
        if nextLevel.isEmpty { break }
        currentLevel = nextLevel
    }
    
    let password = currentLevel.first!.sorted().joined( separator: "," )
    return password
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
