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


func parse( input: AOCinput ) -> [ String : [String] ] {
    return input.lines.reduce( into: [ String : [String] ]() ) {
        let names = $1.split( whereSeparator: { ": ".contains( $0 ) } )
        $0[ String( names[0] ) ] = names.dropFirst().map { String( $0 ) }
        
    }
}


func findPaths( devices: [ String : [String] ], start: String, end: String ) -> Int {
    if let cached = cache[ Key( start: start, end: end ) ] { return cached }
    if start == end { return 1 }
    guard let connections = devices[ start ] else { return 0 }
    let endCount = connections
        .map { findPaths( devices: devices, start: $0, end: end ) }
        .reduce( 0, + )
    
    cache[ Key( start: start, end: end ) ] = endCount
    return endCount
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

    return "\(endCount)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
