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
    
    init( input: String ) {
        let words = input.split( whereSeparator: { "<>,=".contains($0) } )
        
        position = Point3D( x: Int( words[1] )!, y: Int( words[2] )!, z: Int( words[3] )! )
        radius = Int( words[5] )!
    }
    
    func intersect( other: Nanobot ) -> Bool {
        let distance = position.distance( other: other.position)
        
        return distance <= radius + other.radius
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


// Somewhat of a cheat - adapted from a Python program in the subreddit.
// Also will probably not work for all inputs.
func part2( input: AOCinput ) -> String {
    let bots = parse( input: input )
    var queue: [ ( d:Int, e: Int ) ] = []
    
    for bot in bots {
        let distance = bot.position.distance( other: Point3D( x: 0, y: 0, z: 0 ) )
        
        queue.append( ( d: max( 0, distance - bot.radius ), e: 1 ) )
        queue.append( ( d: distance + bot.radius + 1, e: -1 ) )
    }
    
    var count = 0
    var maxCount = 0
    var result = 0
    
    queue.sort( by: { $0.d < $1.d } )
    while let entry = queue.first {
        queue.removeFirst()
        count += entry.e
        if count > maxCount {
            result = entry.d
            maxCount = count
        }
    }
    
    return "\(result)"
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
