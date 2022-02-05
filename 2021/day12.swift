//
//         FILE: main.swift
//  DESCRIPTION: day12 - Passage Pathing
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/11/21 21:00:11
//

import Foundation

struct Cave {
    enum Size { case big, small }
    let name: String
    let type: Size
    let connected: Set<String>
    
    init( name: String, connected: Set<String> ) {
        self.name = name
        self.type = name.uppercased() == name ? .big : .small
        self.connected = connected
    }
}

class Path {
    let path: [String]
    let offLimits: Set<String>
    let exception: Bool

    var current: String { path.last! }
    
    init() {
        path = [ "start" ]
        offLimits = Set( [ "start" ] )
        exception = false
    }
    
    init( from: Path, goto: Cave ) {
        path = from.path + [ goto.name ]
        if goto.type == .small {
            if from.offLimits.contains( goto.name ) {
                exception = true
            } else {
                exception = from.exception
            }
            offLimits = from.offLimits.union( [ goto.name ] )
        } else {
            offLimits = from.offLimits
            exception = from.exception
        }
    }
}


func countValid( input: AOCinput, allowTwice: Bool = false ) -> Int {
    let network = parse( input: input )
    var queue = [ Path() ]
    var valid = [Path]()
    
    while !queue.isEmpty {
        let path = queue.removeFirst()
        let current = network[ path.current ]!
        
        for neighbor in current.connected.map( { network[ $0 ]! } ) {
            if neighbor.name == "start" { continue }
            if neighbor.name == "end" {
                valid.append( Path( from: path, goto: neighbor ) )
                continue
            }
            if !path.offLimits.contains( neighbor.name ) || allowTwice && !path.exception {
                queue.append( Path( from: path, goto: neighbor ) )
            }
        }
    }
    return valid.count
}


func parse( input: AOCinput ) -> [ String : Cave ] {
    let dict = input.lines.reduce( into: [ String : Set<String> ]() ) { dict, line in
        let words = line.split( separator: "-" ).map { String( $0 ) }
        dict[ words[0], default: Set() ].insert( words[1] )
        dict[ words[1], default: Set() ].insert( words[0] )
    }
    return Dictionary( uniqueKeysWithValues: dict.map { ( $0, Cave( name: $0, connected: $1 ) ) } )
}


func part1( input: AOCinput ) -> String {
    return "\( countValid( input: input ) )"
}


func part2( input: AOCinput ) -> String {
    return "\( countValid( input: input, allowTwice: true ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
