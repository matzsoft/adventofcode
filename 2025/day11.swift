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


func findPaths(
    devices: [ String : Device ], start: Path,
    end: String, exceptions: [String] )
-> [Path] {
    var paths = [Path]()
    var queue = [ start ]
    
    while !queue.isEmpty {
        let path = queue.removeFirst()
        if path.current == end {
            paths.append( path )
        } else if !exceptions.contains( path.current ) {
            for connection in devices[ path.current ]!.connections {
                if connection == end {
                    paths.append( path.adding( connection )! )
                } else {
                    if let newPath = path.adding( connection ) {
                        queue.append( newPath )
                    }
                }
            }
        }
    }
    return paths
}


func part1( input: AOCinput ) -> String {
    let devices = parse( input: input )
    let paths = findPaths(
        devices: devices, start: Path( start: "you" ),
        end: "out", exceptions: []
    )

    return "\(paths.count)"
}


func part2( input: AOCinput ) -> String {
    let devices = parse( input: input )
    let svr2dac = findPaths(
        devices: devices, start: Path( start: "svr" ), end: "dac",
        exceptions: [ "fft", "out" ]
    )
    let dac2fft = svr2dac.flatMap {
        findPaths(
            devices: devices, start: $0, end: "fft",
            exceptions: [ "svr", "out" ]
        )
    }
//    let dac2fft = findPaths(
//        devices: devices, start: Path( start: "dac" ), end: "fft",
//        exceptions: [ "svr", "out" ]
//    )
//    let dac2out = dac2fft.flatMap {
//        findPaths(
//            devices: devices, start: $0, end: "out",
//            exceptions: [ "svr", "fft" ]
//        )
//    }
    let dac2out = findPaths(
        devices: devices, start: Path( start: "dac" ), end: "out",
        exceptions: [ "svr", "fft" ]
    )
    let svr2fft = findPaths(
        devices: devices, start: Path( start: "svr" ), end: "fft",
        exceptions: [ "dac", "out" ]
    )
    let fft2dac = svr2fft.flatMap {
        findPaths(
            devices: devices, start: $0, end: "dac",
            exceptions: [ "svr", "out" ]
        )
    }
//    let fft2dac = findPaths(
//        devices: devices, start: Path( start: "fft" ), end: "dac",
//        exceptions: [ "svr", "out" ]
//    )
//    let fft2out = fft2dac.flatMap {
//        findPaths(
//            devices: devices, start: $0, end: "out",
//            exceptions: [ "svr", "dac" ]
//        )
//    }
    let fft2out = findPaths(
        devices: devices, start: Path( start: "fft" ), end: "out",
        exceptions: [ "svr", "dac" ]
    )
    let dac2fftCount = svr2dac.count * dac2fft.count * fft2out.count
    let fft2dacCount = svr2fft.count * fft2dac.count * dac2out.count
    let endCount = dac2fftCount + fft2dacCount

    print( "svr2dac = \(svr2dac.count)" )
    print( "dac2fft = \(dac2fft.count)" )
    print( "fft2out = \(fft2out.count)" )
    print( "svr2fft = \(svr2fft.count)" )
    print( "fft2dac = \(fft2dac.count)" )
    print( "dac2out = \(dac2out.count)" )
    
    return "\(endCount)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
