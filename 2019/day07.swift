//
//         FILE: main.swift
//  DESCRIPTION: day07 - Amplification Circuit
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/01/21 12:19:55
//

import Foundation

func permutations( set: Set<Int> ) -> [[Int]] {
    var result: [[Int]] = []
    
    for element in set {
        let newSet = set.filter { $0 != element }
        
        if newSet.isEmpty { return [[element]] }
        
        permutations( set: newSet ).forEach { result.append( [element] + $0 ) }
    }
    
    return result
}


func parse( input: AOCinput ) -> [Int] {
    return input.line.split( separator: "," ).map { Int( $0 )! }
}


func part1( input: AOCinput ) -> String {
    let initialMemory = parse( input: input )
    var result = 0
    
    for permutation in permutations( set: [ 0, 1, 2, 3, 4 ] ) {
        var lastOutput = 0
        
        for phase in permutation {
            let ampflifier = Intcode( name: "A", memory: initialMemory )
            
            ampflifier.inputs = [ phase, lastOutput ]
            lastOutput = try! ampflifier.execute()!
        }
        result = max( result, lastOutput )
    }

    return "\(result)"
}


func part2( input: AOCinput ) -> String {
    let initialMemory = parse( input: input )
    var result = 0

    for permutation in permutations( set: [ 5, 6, 7, 8, 9 ] ) {
        let nameMapping = [ ( "A", 0 ), ( "B", 1 ), ( "C", 2 ), ( "D", 3 ), ( "E", 4 ) ]
        let amplifiers = nameMapping.map { mapping -> Intcode in
            let amplifier = Intcode( name: mapping.0, memory: initialMemory )
            
            amplifier.inputs = [ permutation[ mapping.1 ] ]
            return amplifier
        }
        var lastOutput = 0
        var done = false

        while !done {
            for amplifier in amplifiers {
                amplifier.inputs.append( lastOutput )
                if let output = try! amplifier.execute() {
                    lastOutput = output
                } else {
                    done = true
                }
            }
        }
        result = max( result, lastOutput )
    }

    return "\(result)"
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
