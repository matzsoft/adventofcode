//
//         FILE: day08.swift
//  DESCRIPTION: Advent of Code 2025 Day 8: Playground
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2025 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/07/25 21:00:01
//

import Foundation
import Library

extension Int {
    var squared: Int { self * self }
}


extension Point3D {
    func euclidian( other: Point3D ) -> Int {
        (( x - other.x ).squared + ( y - other.y ).squared + ( z - other.z ).squared)
    }
}

struct Connector: Hashable {
    let junction1: Point3D
    let junction2: Point3D
    let distance: Int
}


struct Circuits {
    var circuits: [Set<Point3D>]
    var connectsCount = 0
    let connections: [Connector]
    var count: Int { circuits.count }
    var big3: Int {
        guard count > 2 else { return 0 }
        let sorted = circuits.sorted( by: { $0.count > $1.count } )
        return sorted[0].count * sorted[1].count * sorted[2].count
    }
    
    init( junctions: [Point3D] ) {
        self.circuits = junctions.map( { Set( [ $0 ] ) } )
        self.connections = ( 0 ..< junctions.count - 1 ).reduce( into: [ Connector ]() ) {
            distances, index1 in
            for index2 in ( index1 + 1 ) ..< junctions.count {
                let distance = junctions[index1].euclidian( other: junctions[index2] )
                let connector = Connector(
                    junction1: junctions[index1], junction2: junctions[index2], distance: distance
                )
                distances.append( connector )
            }
        }.sorted( by: { $0.distance < $1.distance } )
    }
    
    mutating func connect( connector: Connector ) {
        let index1 = circuits.firstIndex { $0.contains( connector.junction1 ) }!
        let index2 = circuits.firstIndex { $0.contains( connector.junction2 ) }!
        
        if index1 == index2 { return }
        
        let small = min( index1, index2 )
        let big = max( index1, index2 )
        circuits[small].formUnion( circuits[big] )
        circuits.remove( at: big )
        return
    }
    
    mutating func connect( until limit: Int ) {
        for connector in connections {
            connect( connector: connector )
            connectsCount += 1
            if connectsCount == limit { break }
        }
    }
    
    mutating func connectAll() -> Connector? {
        for connector in connections {
            connect( connector: connector )
            if circuits.count == 1 {
                return connector
            }
        }
        return nil
    }
}


func parse( input: AOCinput ) -> [Point3D] {
    input.lines.map {
        let numbers = $0.split( separator: "," ).map { Int( $0 )! }
        return Point3D( x: numbers[0], y: numbers[1], z: numbers[2] )
    }
}


func part1( input: AOCinput ) -> String {
    let junctions = parse( input: input )
    let limit = Int( input.extras[0] )!
    var circuits = Circuits( junctions: junctions )
    
    circuits.connect( until: limit )
    return "\(circuits.big3)"
}


func part2( input: AOCinput ) -> String {
    let junctions = parse( input: input )
    var circuits = Circuits( junctions: junctions )

    guard let connector = circuits.connectAll() else { return "No Solution" }
    return "\(connector.junction1.x * connector.junction2.x)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
