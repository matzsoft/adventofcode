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

struct Valve {
    let name: String
    let flowRate: Int
    let tunnels: [ String : Int ]
    
    internal init( name: String, flowRate: Int, tunnels: [String : Int] ) {
        self.name = name
        self.flowRate = flowRate
        self.tunnels = tunnels
    }
    
    init( line: String ) {
        let words = line.split( whereSeparator: { " =;,".contains( $0 ) } ).map { String( $0 ) }
        
        name = words[1]
        flowRate = Int( words[5] )!
        tunnels = words[10...].reduce( into: [ String: Int ](), { $0[$1] = 1 } )
    }
}


struct Vertex {
    let name: String
    let clock: Int
    let pressure: Int
    
    internal init( name: String, clock: Int, pressure: Int ) {
        self.name = name
        self.clock = clock
        self.pressure = pressure
    }
    
    init( pressure: Int ) {
        self.name = startValve
        self.clock = timeLimit
        self.pressure = pressure
    }
}


func parse( input: AOCinput ) -> [ String : Valve ] {
    return input.lines.reduce( into: [ String : Valve ]() ) {
        let valve = Valve( line: $1 )
        $0[valve.name] = valve
    }
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
    let valves = parse( input: input )
    let working = valves.filter { $0.value.flowRate > 0 }.map { $0.key }
    let nodes = Set( [ startValve ] + working )
    let sparseMatrix = valves.values.reduce( into: [ String : [ String : Int ] ]() ) {
        $0[$1.name] = $1.tunnels
    }
//    print( matrix: sparseMatrix )
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
        fullMatrix[row.key]![row.key] = nil
    }
    let prunedMatrix = fullMatrix
        .filter { nodes.contains( $0.key ) }
        .mapValues { $0.filter { $0.key != startValve && nodes.contains( $0.key ) } }

//    print( matrix: fullMatrix )
    print( matrix: prunedMatrix )
    
    let relative = working.reduce( into: [ String : [ String : Int ] ]() ) { relative, first in
        relative[first] = working.reduce( into: [ String : Int ]() ) { row, second in
            if first == second { return }
            let firstTime = timeLimit - prunedMatrix[startValve]![first]! - 1
            let secondTime = firstTime - prunedMatrix[first]![second]! - 1
            row[second] = firstTime * valves[first]!.flowRate + secondTime * valves[second]!.flowRate
        }
    }
    print( "---------------" )
    print( matrix: relative )
    
    let times = working.reduce( into: [ String : [ String : Int ] ]() ) { times, first in
        times[first] = working.reduce( into: [ String : Int ]() ) { row, second in
            if first == second { return }
            let firstTime = timeLimit - prunedMatrix[startValve]![first]! - 1
            let secondTime = firstTime - prunedMatrix[first]![second]! - 1
            row[second] = firstTime + secondTime
        }
    }
    print( "---------------" )
    print( matrix: times )

    func trial( sequence: [String] ) -> Int {
        let answer = sequence.reduce( into: [ Vertex( pressure: 0 ) ] ) { answer, name in
            let clock = answer.last!.clock - prunedMatrix[answer.last!.name]![name]! - 1
            let pressure = answer.last!.pressure + clock * valves[name]!.flowRate
            if clock > 0 { answer.append( Vertex( name: name, clock: clock, pressure: pressure ) ) }
        }
        return answer.last!.pressure
    }
    
    var vertices = working.reduce( into: [ startValve : Vertex( pressure: Int.max ) ] ) { vertices, name in
        let clock = timeLimit - prunedMatrix[startValve]![name]! - 1
        let potential = valves[name]!.flowRate * clock
        vertices[name] = Vertex( name: name, clock: clock, pressure: potential )
    }
    var queue = [ startValve ] + working
    
    while !queue.isEmpty {
        let next = queue.max { vertices[$0]!.pressure < vertices[$1]!.pressure }!
        queue = queue.filter { $0 != next }
        
        for neighbor in queue {
            let clock = vertices[next]!.clock - prunedMatrix[next]![neighbor]! - 1
            let potential = max( clock * valves[neighbor]!.flowRate, 0 )
            vertices[neighbor] = Vertex( name: neighbor, clock: clock, pressure: potential )
        }
    }
    
    let theSequence = vertices.sorted { $0.value.clock > $1.value.clock }.map { $0.value.name }
    print( "=================" )
    print( "\( theSequence.joined( separator: "," ) )" )
    print( "=================" )
    return "\( trial( sequence: Array( theSequence.dropFirst() ) ) )"

    var remaining = Set( working )
    var sequence = [String]()
    var start = startValve
    var clock = timeLimit
    var pressure = 0
    
    while !remaining.isEmpty{
        let relative = remaining.reduce( into: [ String : [ String : Int ] ]() ) { relative, first in
            relative[first] = remaining.reduce( into: [ String : Int ]() ) { row, second in
                if first == second { return }
                let firstTime = clock - prunedMatrix[start]![first]! - 1
                let secondTime = firstTime - prunedMatrix[first]![second]! - 1
                row[second] =
                    ( firstTime > 0 ? firstTime * valves[first]!.flowRate : 0 ) +
                    ( secondTime > 0 ? secondTime * valves[second]!.flowRate : 0 )
            }
        }
        let results = remaining.map { first in
            let revised = remaining.filter { $0 != first }
            let trialSequence = sequence + [first] + revised.sorted { relative[$0]![$1]! > relative[$1]![$0]! }
            let result = trial( sequence: trialSequence )
            return ( first, result )
        }
        let best = results.max( by: { $0.1 < $1.1 } )!
        
        clock -= prunedMatrix[start]![best.0]! + 1
        start = best.0
        pressure += clock > 0 ? clock * valves[best.0]!.flowRate : 0
        remaining.remove( start )
    }
    
    return "\(pressure)"
    let ultimatum = nodes.reduce( into: [ String : [ String : [ String : Int ] ] ]() ) { ultimatum, start in
        ultimatum[start] = working.reduce( into: [ String : [ String : Int ] ]() ) { relative, first in
            if start == first { return }
            relative[first] = working.reduce( into: [ String : Int ]() ) { row, second in
                if start == second || first == second { return }
                let firstTime = timeLimit - prunedMatrix[start]![first]! - 1
                let secondTime = firstTime - prunedMatrix[first]![second]! - 1
                row[second] = firstTime * valves[first]!.flowRate + secondTime * valves[second]!.flowRate
            }
        }
    }
    
    print( "---------------" )
    let results = working.map { start in
        let revised = working.filter { $0 != start }
        let sequence = [ start ] + revised.sorted { ultimatum[start]![$0]![$1]! > ultimatum[start]![$1]![$0]! }
        let result = trial( sequence: sequence )
        print( "\( sequence.joined( separator: "," ) ) = \(result)" )
        return result
    }

    // 1825 is too low, 1847 is wrong
    return "\( results.max()! )"
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
