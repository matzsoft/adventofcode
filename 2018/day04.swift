//
//         FILE: main.swift
//  DESCRIPTION: day04 - Repose Record
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/27/21 19:52:30
//

import Foundation
import Library

enum Status { case awake, asleep }

struct GuardInfo {
    var minutes = 0
    var histo = Array(repeating: 0, count: 60)
}


func parse( input: AOCinput ) -> [ Int : GuardInfo ] {
    var status = Status.awake
    var watchman = 0
    var start = 0
    var guardsInfo = [ Int : GuardInfo ]()

    for line in input.lines.sorted() {
        let words = line.split( whereSeparator: { "[ :]#".contains($0) } )
        let minute = Int( words[2] )!
        let observation = words[3]
        
        switch observation {
        case "Guard":
            switch status {
            case .awake:
                break
            case .asleep:
                guardsInfo[watchman]?.minutes += 60 - start
                ( start ..< 60  ).forEach( { guardsInfo[watchman]?.histo[$0] += 1 } )
            }
            
            watchman = Int( words[4] )!
            status = .awake
            
            if guardsInfo[watchman] == nil { guardsInfo[watchman] = GuardInfo() }
        case "falls":
            switch status {
            case .asleep:
                print( "Guard \(watchman) already sleeping" )
            case .awake:
                start = minute
                status = .asleep
            }
        case "wakes":
            switch status {
            case .awake:
                print( "Guard already awake" )
            case .asleep:
                guardsInfo[watchman]?.minutes += minute - start
                ( start ..< minute ).forEach( { guardsInfo[watchman]?.histo[$0] += 1 } )
                status = .awake
            }
        default:
            print( "Unknown observation", observation )
        }
    }

    return guardsInfo
}


func part1( input: AOCinput ) -> String {
    let guardsInfo = parse( input: input )
    let culprit = guardsInfo.max( by: { $0.value.minutes < $1.value.minutes } )!.key
    let target = guardsInfo[culprit]!.histo.enumerated().max(by: { $0.element < $1.element } )!.offset

    return "\(culprit * target)"
}


func part2( input: AOCinput ) -> String {
    let guardsInfo = parse( input: input )
    let ( key, minute, _ ) = guardsInfo.map { ( key, info ) -> ( key: Int, minute: Int, count: Int ) in
        let ( minute, count ) = info.histo.enumerated().max( by: { $0.element < $1.element } )!
        return ( key: key, minute: minute, count: count )
    }.max( by: { $0.count < $1.count } )!

    return "\(key * minute)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
