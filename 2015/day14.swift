//
//         FILE: main.swift
//  DESCRIPTION: day14 - Reindeer Olympics
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/08/21 09:46:10
//

import Foundation

struct Reindeer {
    let name: String
    let velocity: Int
    let flightDuration: Int
    let restDuration: Int
    let cycleDuration: Int
    
    init( line: String ) {
        let words = line.components( separatedBy: CharacterSet.whitespaces )
        
        name = words[0]
        velocity = Int( words[3] )!
        flightDuration = Int( words[6] )!
        restDuration = Int( words[13] )!
        cycleDuration = flightDuration + restDuration
    }
    
    func distance( time: Int ) -> Int {
        let cycles = time / cycleDuration
        let extraFlight = min( time % cycleDuration, flightDuration )
        
        return velocity * ( cycles * flightDuration + extraFlight )
    }
}


func parse( input: AOCinput ) -> [Reindeer] {
    return input.lines.map { Reindeer( line: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let reindeer = parse( input: input )
    let raceDuration = Int( input.extras[0] )!
    
    return "\( reindeer.map { $0.distance( time: raceDuration ) }.max()! )"
}


func part2( input: AOCinput ) -> String {
    let reindeer = parse( input: input )
    let raceDuration = Int( input.extras[0] )!
    var scores = [ String : Int ]()

    for time in 1 ... raceDuration {
        let leadDistance = reindeer.map { $0.distance( time: time ) }.max()!
        let leaders = reindeer.filter { $0.distance( time: time ) == leadDistance }
        
        leaders.forEach{ scores[ $0.name, default: 0 ] += 1 }
    }
    
    return "\( scores.values.max()! )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
