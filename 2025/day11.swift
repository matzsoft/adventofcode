//
//         FILE: day11.swift
//  DESCRIPTION: Advent of Code 2025 Day 11: Reactor
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2025 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/10/25 21:08:16
//

import Foundation
import Library

struct Device: Hashable {
    let name: String
    let connections: [String]
}


struct Path: Hashable {
    let current: String
    let seen: Set<String>
    let sawDAC: Bool
    let sawFFT: Bool
    
    init( start: String ) {
        current = start
        seen = Set( [ start ] )
        sawDAC = false
        sawFFT = false
    }
    
    init( current: String, seen: Set<String>, sawDAC: Bool, sawFFT: Bool ) {
        self.current = current
        self.seen = seen
        self.sawDAC = sawDAC
        self.sawFFT = sawFFT
    }
    
    func adding( _ new: String ) -> Path? {
        if seen.contains( new ) { return nil }
        switch new {
        case "dac":
            return Path(
                current: new, seen: seen.union( [ new ] ),
                sawDAC: true, sawFFT: sawFFT
            )
        case "fft":
            return Path(
                current: new, seen: seen.union( [ new ] ),
                sawDAC: sawDAC, sawFFT: true
            )
        default:
            return Path(
                current: new, seen: seen.union( [ new ] ),
                sawDAC: sawDAC, sawFFT: sawFFT
            )
        }
    }
}


func parse( input: AOCinput ) -> [ String: Device ] {
    return input.lines.reduce( into: [ String : Device ]() ) {
        let names = $1.split( whereSeparator: { ": ".contains( $0 ) } )
        $0[ String( names[0] ) ] = Device( name: String( names[0] ), connections: names.dropFirst().map { String( $0 ) } )
        
    }
}


func part1( input: AOCinput ) -> String {
    let devices = parse( input: input )
    let start = "you"
    let end = "out"
    var endCount = 0
    var queue = [ Path( start: start ) ]
    
    while !queue.isEmpty {
        let path = queue.removeFirst()
        if path.current == end {
            endCount += 1
        }
        for connection in devices[ path.current ]!.connections {
            if connection == end {
                endCount += 1
            } else {
                if let newPath = path.adding( connection ) {
                    queue.append( newPath )
                }
            }
        }
    }
    return "\(endCount)"
}


func part2( input: AOCinput ) -> String {
    let devices = parse( input: input )
    let start = "svr"
    let end = "out"
    var endCount = 0
    var queue = [ Path( start: start ) ]
    
    while !queue.isEmpty {
        let path = queue.removeFirst()
        if path.current == end {
            endCount += 1
        }
        for connection in devices[ path.current ]!.connections {
            if connection == end {
                if path.sawDAC && path.sawFFT {
                    endCount += 1
                }
            } else {
                if let newPath = path.adding( connection ) {
                    queue.append( newPath )
                }
            }
        }
    }
    return "\(endCount)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
