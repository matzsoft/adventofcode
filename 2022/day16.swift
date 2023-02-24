//
//         FILE: main.swift
//  DESCRIPTION: day16 - Proboscidea Volcanium
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/15/22 21:00:53
//

import Foundation

let startValve = "AA"
let timeLimit  = 30

func parse( input: AOCinput ) -> ( [String], [ String : Int ], [ String : [ String : Int ] ] ) {
    let words = input.lines.map {
        $0.split( whereSeparator: { " =;,".contains( $0 ) } ).map { String( $0 ) }
    }
    let flowRates = words.reduce( into: [ String : Int ]() ) { $0[$1[1]] = Int( $1[5] )! }
    let working = flowRates.keys.filter { flowRates[$0]! > 0 }.map { String( $0 ) }
    let tunnels = words.reduce(into: [ String : [ String : Int ] ]() ) { tunnels, line in
        tunnels[line[1]] = line[10...].reduce( into: [ String: Int ](), { $0[$1] = 1 } )
    }
    let matrix = tunnels.reduce( into: [ String : [ String : Int ] ]() ) { $0[$1.key] = $1.value }

    return ( working, flowRates, matrix )
}


func print( matrix: [ String : [ String : Int ] ] ) -> Void {
    let list = matrix.keys.sorted()
    print( "," + list.joined( separator: "," ) )
    list.forEach { name in print( "\(name)," + list.map {
        guard let distance = matrix[name]?[$0] else { return "" }
        return String( distance )
    }.joined( separator: "," ) ) }
}


func part1( input: AOCinput ) -> String {
    let ( working, flowRates, sparseMatrix ) = parse( input: input )
    let nodes = Set( [ startValve ] + working )
    let fullMatrix = sparseMatrix.reduce( into: sparseMatrix ) { fullMatrix, row in
        for distance in 1 ... fullMatrix.count {
            let neighbors = fullMatrix[row.key]!.filter { $0.value == distance }.map { $0.key }
            if neighbors.isEmpty { break }
            for neighbor in neighbors {
                let onceRemoved = fullMatrix[neighbor]!.filter { $0.value == 1 }.map { $0.key }
                for candidate in onceRemoved {
                    if fullMatrix[row.key]![candidate] == nil {
                        fullMatrix[row.key]![candidate] = distance + 1
                    }
                }
            }
        }
    }
    let prunedMatrix = fullMatrix
        .filter { nodes.contains( $0.key ) }
        .mapValues { $0.filter { $0.key != startValve } }

    let valveMasks = working.enumerated().reduce( into: [String : Int]() ) { valveMasks, tuple in
        valveMasks[tuple.element] = 1 << tuple.offset
    }
    var answer = Array( repeating: 0, count: 2 * valveMasks.values.max()! )

//    print( matrix: sparseMatrix )
//    print( matrix: fullMatrix )
//    print( matrix: prunedMatrix )
    
    func visit( valve: String, clock: Int, state: Int, flow: Int ) -> Void {
        answer[state] = max( answer[state], flow )
        for next in working {
            let newClock = clock - prunedMatrix[valve]![next]! - 1
            if ( valveMasks[next]! & state ) == 0 && newClock > 0 {
                let newState = state | valveMasks[next]!
                let newFlow = flow + newClock * flowRates[next]!
                visit( valve: next, clock: newClock, state: newState, flow: newFlow )
            }
        }
    }
    
    visit( valve: startValve, clock: timeLimit, state: 0, flow: 0 )
    return "\( answer.max()! )"
}


func part2( input: AOCinput ) -> String {
    let something = parse( input: input )
    return ""
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
