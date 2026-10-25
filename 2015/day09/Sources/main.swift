//
//         FILE: main.swift
//  DESCRIPTION: day09 - All in a Single Night
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/05/21 21:55:56
//

import Foundation
import Library

struct Map {
    let map: [ String : [ String : Int ] ]
    
    init( lines: [String] ) {
        map = lines.reduce(into: [ String : [ String : Int ] ]() ) { dict, line in
            let words = line.components( separatedBy: " " )
            let distance = Int( words[4] )!
            
            dict[ words[0], default: [:] ][words[2]] = distance
            dict[ words[2], default: [:] ][words[0]] = distance
        }
    }
    
    var routes: [Int] {
        return map.keys.flatMap { name -> [Int] in
            routesFrom( name: name, others: map.keys.filter { $0 != name } )
        }
    }
    
    func routesFrom( name: String, others: [String] ) -> [Int] {
        guard others.count > 1 else { return [ map[name]![others[0]]! ] }
        
        return others.flatMap { next -> [Int] in
            let distance = map[name]![next]!
            return routesFrom( name: next, others: others.filter { $0 != next } ).map { distance + $0 }
        }
    }
}


func parse( input: AOCinput ) -> [Int] {
    return Map( lines: input.lines ).routes
}


func part1( input: AOCinput ) -> String {
    let routes = parse( input: input )
    return "\( routes.min()! )"
}


func part2( input: AOCinput ) -> String {
    let routes = parse( input: input )
    return "\( routes.max()! )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
