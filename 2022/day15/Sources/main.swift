//
//         FILE: main.swift
//  DESCRIPTION: day15 - Beacon Exclusion Zone
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/14/22 22:39:00
//

import Foundation
import Library

struct Sensor: CustomStringConvertible {
    let location: Point2D
    let beacon:   Point2D
    let radius:   Int
    
    internal init(location: Point2D, beacon: Point2D) {
        self.location = location
        self.beacon = beacon
        radius = location.distance( other: beacon )
    }
    
    var description: String {
        "Sensor at \(location.x),\(location.y), becon at \(beacon.x),\(beacon.y), radius \(radius)"
    }
    
    var bounds: Rect2D {
        Rect2D(
            min: Point2D( x: location.x - radius, y: location.y - radius ),
            max: Point2D( x: location.x + radius, y: location.y + radius )
        )
    }
    
    func yExclusion( at y: Int ) -> Range<Int>? {
        let excess = radius - abs( location.y - y )
        if excess < 0 { return nil }
        return location.x - excess ..< location.x + excess + 1
    }
    
    func yExclusion( at y: Int, xRange: Range<Int> ) -> Range<Int>? {
        guard let range = yExclusion( at: y ) else { return nil }
        return range.clamped( to: xRange )
    }
}


func parse( input: AOCinput ) -> [Sensor] {
    return input.lines.map {
        let chunks = $0.split( whereSeparator: { "=,:".contains( $0 ) } )
        let coords = [ 1, 3, 5, 7 ].map { Int( chunks[$0] )! }
        return [ Point2D( x: coords[0], y: coords[1] ), Point2D( x: coords[2], y: coords[3] ) ]
    }.map { Sensor( location: $0[0], beacon: $0[1] ) }
}


func part1( input: AOCinput ) -> String {
    let sensors = parse( input: input )
    let y = Int( input.extras[0] )!
    let ranges = sensors.compactMap { $0.yExclusion( at: y ) }.condensed
    let beacons = Set( sensors.filter { $0.beacon.y == y }.map { $0.beacon } )
    
    return "\( ranges.reduce( 0, { $0 + $1.count } ) - beacons.count )"
}

func isContained( coord: Int, ranges: [Range<Int>] ) -> Bool {
    ranges.contains( where: { $0.contains( coord ) } )
}


func map( sensors: [Sensor] ) -> Void {
    let bounds = sensors.reduce( sensors[0].bounds ) { $0.expand( with: $1.bounds ) }
    var map = Array( repeating: Array( repeating: ".", count: bounds.width ), count: bounds.height )
    
    for y in bounds.min.y ... bounds.max.y {
        for sensor in sensors {
            if let exclusions = sensor.yExclusion( at: y ) {
                for x in exclusions { map[ y - bounds.min.y ][ x - bounds.min.x ] = "#" }
            }
        }
    }
    sensors.forEach {
        map[ $0.location.y - bounds.min.y ][ $0.location.x - bounds.min.x ] = "S"
        map[ $0.beacon.y - bounds.min.y ][ $0.beacon.x - bounds.min.x ] = "B"
    }
    
    var header1 = Array( repeating: Character( " " ), count: bounds.width + 4 )
    var header2 = header1
    let zeroIndex = 4 - bounds.min.x
    header1[ zeroIndex - 5 ] = "-"
    for index in stride( from: zeroIndex + 10, to: header1.count, by: 5 ) {
        let label = Character( String( ( index - zeroIndex ) / 10 ) )
        header1[index] = label
    }
    for index in stride(from: zeroIndex, to: header2.count, by: 10 ) { header2[index] = "0" }
    for index in stride( from: zeroIndex - 5, to: header2.count, by: 10 ) { header2[index] = "5" }
    print( String( header1 ) )
    print( String( header2 ) )
    for ( rowNumber, row ) in map.enumerated() {
        print( String(format: "%3d", rowNumber + bounds.min.y ), row.joined() )
    }
}


func part2( input: AOCinput ) -> String {
    let sensors = parse( input: input )
    let limit = Int( input.extras[1] )!
    let candidates = ( 0 ... limit ).reduce( into: [ Int : [Int] ]() ) { dict, y in
        let exclusions = sensors
            .compactMap { $0.yExclusion( at: y, xRange: 0 ..< limit + 1 ) }
            .condensed
        if exclusions.count > 1 {
            for index in 0 ..< exclusions.count - 1 {
                if exclusions[index].upperBound + 1 == exclusions[index+1].lowerBound {
                    dict[ y, default: [] ].append( exclusions[index].upperBound )
                }
            }
        }
    }
    
    // map( sensors: sensors )     // For debug, example data only.  Will NOT work on real data.
    if candidates.count == 1 && candidates.first!.value.count == 1 {
        let frequency = 4000000 * candidates.first!.value.first! + candidates.first!.key
        return "\(frequency)"
    }
    return "No solution"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
