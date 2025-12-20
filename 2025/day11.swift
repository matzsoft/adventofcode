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

struct Key: Hashable {
    let start: String
    let end: String
}
var cache = [ Key : Int ]()


struct Device: Hashable {
    let name: String
    let connections: [String]
}


struct Path: Hashable {
    let current: String
    let seen: Set<String>
    
    init( start: String ) {
        current = start
        seen = Set( [ start ] )
    }
    
    init( current: String, seen: Set<String> ) {
        self.current = current
        self.seen = seen
    }
    
    func adding( _ new: String ) -> Path? {
        if seen.contains( new ) { return nil }
        return Path( current: new, seen: seen.union( [ new ] ) )
    }
}


func parse( input: AOCinput ) -> [ String: Device ] {
    return input.lines.reduce( into: [ String : Device ]() ) {
        let names = $1.split( whereSeparator: { ": ".contains( $0 ) } )
        $0[ String( names[0] ) ] = Device( name: String( names[0] ), connections: names.dropFirst().map { String( $0 ) } )
        
    }
}


func findPaths( devices: [ String : Device ], start: String, end: String ) -> Int {
    func doit( _ start: String, _ end: String ) -> Int {
        if let cached = cache[ Key( start: start, end: end ) ] { return cached }
        if start == end { return 1 }
        guard let device = devices[ start ] else { return 0 }
        let endCount = device.connections
            .map { findPaths( devices: devices, start: $0, end: end ) }
            .reduce( 0, + )
        
        cache[ Key( start: start, end: end ) ] = endCount
        return endCount
    }
    
    return doit( start, end )
//    var endCount = 0
//    
//    var queue = [ Path( start: start ) ]
//    
//    while !queue.isEmpty {
//        let path = queue.removeFirst()
//        if path.current == end {
//            endCount += 1
//        } else if let device = devices[ path.current ] {
//            for connection in device.connections {
//                if connection == end {
//                    endCount += 1
//                } else {
//                    if let newPath = path.adding( connection ) {
//                        queue.append( newPath )
//                    }
//                }
//            }
//        }
//    }
//    return endCount
}


func part1( input: AOCinput ) -> String {
    cache = [:]
    
    let devices = parse( input: input )
    let endCount = findPaths( devices: devices, start: "you", end: "out" )

    return "\(endCount)"
}


func part2( input: AOCinput ) -> String {
    cache = [:]
    
    let devices = parse( input: input )
    let svr2dac = findPaths( devices: devices, start: "svr", end: "dac" )
    let dac2fft = findPaths( devices: devices, start: "dac", end: "fft" )
    let dac2out = findPaths( devices: devices, start: "dac", end: "out" )
    let svr2fft = findPaths( devices: devices, start: "svr", end: "fft" )
    let fft2dac = findPaths( devices: devices, start: "fft", end: "dac" )
    let fft2out = findPaths( devices: devices, start: "fft", end: "out" )
    let dac2fftCount = svr2dac * dac2fft * fft2out
    let fft2dacCount = svr2fft * fft2dac * dac2out
    let endCount = dac2fftCount + fft2dacCount

    print( "svr2dac = \(svr2dac)" )
    print( "dac2fft = \(dac2fft)" )
    print( "fft2out = \(fft2out)" )
    print( "svr2fft = \(svr2fft)" )
    print( "fft2dac = \(fft2dac)" )
    print( "dac2out = \(dac2out)" )
    
    return "\(endCount)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
