//
//         FILE: main.swift
//  DESCRIPTION: day23 - Experimental Emergency Teleportation
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/19/21 20:01:09
//

import Foundation

struct Nanobot {
    let position: Point3D
    let radius: Int
    let bounds: Rect3D
    
    init( input: String ) {
        let words = input.split( whereSeparator: { "<>,=".contains($0) } )
        
        position = Point3D( x: Int( words[1] )!, y: Int( words[2] )!, z: Int( words[3] )! )
        radius = Int( words[5] )!
        
        let vector = Point3D( x: radius, y: radius, z: radius )
        
        bounds = Rect3D( min: position - vector, max: position + vector )
    }
    
    func inRange( of box: Rect3D ) -> Bool {
        var distance = 0
        
        if position.x < box.min.x { distance += box.min.x - position.x }
        if position.x > box.max.x { distance += position.x - box.max.x }
        if position.y < box.min.y { distance += box.min.y - position.y }
        if position.y > box.max.y { distance += position.y - box.max.y }
        if position.z < box.min.z { distance += box.min.z - position.z }
        if position.z > box.max.z { distance += position.z - box.max.z }
        
        return distance <= radius
    }
}


func parse( input: AOCinput ) -> [Nanobot] {
    return input.lines.map { Nanobot( input: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let bots = parse( input: input )
    let strongest = bots.max( by: { $0.radius < $1.radius } )!
    let inRange = bots.filter { strongest.position.distance( other: $0.position ) <= strongest.radius }
    
    return "\(inRange.count)"
}


extension Rect3D {
    var split: [Rect3D] {
        guard volume > 1 else { return [] }
        let half = Point3D( x: width / 2, y: length / 2, z: height / 2 )
        let bigHalf = Point3D( x: width - half.x, y: length - half.y, z: height - half.z )
        
//        return [
//            Rect3D( min: min, width: bigHalf.x, length: bigHalf.y, height: bigHalf.z ),
//            Rect3D( min: Point3D( x: min.x + bigHalf.x, y: min.y, z: min.z ),
//                    width: half.x, length: bigHalf.y, height: bigHalf.z ),
//            Rect3D( min: Point3D( x: min.x, y: min.y + bigHalf.y, z: min.z ),
//                    width: bigHalf.x, length: half.y, height: bigHalf.z ),
//            Rect3D( min: Point3D( x: min.x + bigHalf.x, y: min.y + bigHalf.y, z: min.z ),
//                    width: half.x, length: half.y, height: bigHalf.z ),
//            Rect3D( min: Point3D( x: min.x, y: min.y, z: min.z + bigHalf.z ),
//                    width: bigHalf.x, length: bigHalf.y, height: half.z ),
//            Rect3D( min: Point3D( x: min.x + bigHalf.x, y: min.y, z: min.z + bigHalf.z ),
//                    width: half.x, length: bigHalf.y, height: half.z ),
//            Rect3D( min: Point3D( x: min.x, y: min.y + bigHalf.y, z: min.z + bigHalf.z ),
//                    width: bigHalf.x, length: half.x, height: half.z ),
//            Rect3D( min: Point3D( x: min.x + bigHalf.x, y: min.y + bigHalf.y, z: min.z + bigHalf.z ),
//                    width: half.x, length: half.y, height: half.z )
//        ].compactMap { $0 }
        
        return [ ( min.z, bigHalf.z ), ( min.z + bigHalf.z, half.z ) ].flatMap { ztuple in
            [ ( min.y, bigHalf.y ), ( min.y + bigHalf.y, half.y ) ].flatMap { ytuple in
                [ ( min.x, bigHalf.x ), ( min.x + bigHalf.x, half.x ) ].compactMap { xtuple in
                    Rect3D( min: Point3D( x: xtuple.0, y: ytuple.0, z: ztuple.0 ),
                            width: xtuple.1, length: ytuple.1, height: ztuple.1 )
                }
            }
        }
    }
}


func part2( input: AOCinput ) -> String {
    let origin = Point3D( x: 0, y: 0, z: 0 )
    let bots = parse( input: input )
    let box = Rect3D( rects: bots.map { $0.bounds } )
    var boxes = box.split

    while !boxes.isEmpty {
        let counts = boxes.map { box in ( box, bots.filter { $0.inRange( of: box ) }.count ) }
        let bestCount = counts.max { $0.1 < $1.1 }!.1
        
        boxes = counts.filter { $0.1 == bestCount }.map { $0.0 }
        if boxes.allSatisfy( { $0.volume == 1 } ) {
            let closest = boxes.min { $0.min.distance( other: origin ) < $1.min.distance( other: origin ) }!
            return "\(closest.min.distance( other: origin ))"
        }
        boxes = boxes.flatMap { $0.split }
    }
    return "Failure"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
