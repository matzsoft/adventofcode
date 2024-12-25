//
//         FILE: day24.swift
//  DESCRIPTION: Advent of Code 2024 Day 24: Crossed Wires
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/23/24 21:00:32
//

import Foundation
import Library

struct Wire {
    let name: String
    var value: Bool
    
    init( line: String ) {
        let fields = line.split( whereSeparator: { ": ".contains( $0 ) } )
        
        name = String( fields[0] )
        value = Int( fields[1] )! == 1
    }
}

struct Gate {
    enum Operation: String { case and = "AND", or = "OR", xor = "XOR" }
    
    let left: String
    let right: String
    let operation: Operation
    let output: String
    var fired: Bool
    
    init( line : String ) {
        let fields = line
            .split( whereSeparator: { " ->".contains( $0 ) } )
            .map { String( $0 ) }
        
        left = fields[0]
        operation = Operation( rawValue: fields[1] )!
        right = fields[2]
        output = fields[3]
        fired = false
    }
    
    mutating func operate( wireValues: [ String : Bool ] ) -> Bool? {
        guard let left = wireValues[self.left] else { return nil }
        guard let right = wireValues[self.right] else { return nil }
        
        fired = true
        switch operation {
        case .and:
            return left && right
        case .or:
            return left || right
        case .xor:
            return left != right
        }
    }
}

struct Monitor {
    let initialWires: [Wire]
    var wireValues: [ String : Bool ]
    var gates: [Gate]
    
    init( paragraphs: [[String]] ) {
        initialWires = paragraphs[0].map { Wire( line: $0 ) }
        wireValues = initialWires.reduce( into: [ String : Bool ]() ) {
            $0[$1.name] = $1.value
        }
        gates = paragraphs[1].map { Gate( line: $0 ) }
    }
    
    func valueOf( startsWith: String ) -> Int {
        let keys = wireValues.keys
            .filter { $0.hasPrefix( startsWith ) }.sorted().reversed()
        return keys.reduce( 0 ) { $0 << 1 | ( wireValues[$1]! ? 1 : 0 ) }
    }
    
    mutating func engage() -> Void {
        while true {
            let indices = gates.indices.filter { !gates[$0].fired }
            if indices.isEmpty { break }
            for index in indices {
                if let success = gates[index].operate( wireValues: wireValues ) {
                    wireValues[gates[index].output] = success
                }
            }
        }
    }
    
    func blarg( zAffected: [String] ) -> [ String : Set<String> ] {
        let zAffected = Set( zAffected )
        let allZ = wireValues.keys.filter { $0.hasPrefix( "z" ) }
        var result = [ String : Set<String> ]()
        
        for thisZ in allZ {
            var queue = [thisZ]
            var seen = Set<String>()
            while !queue.isEmpty {
                let current = queue.removeFirst()
                let matchingGates = gates.filter { $0.output == current }
                
                for gate in matchingGates {
                    if seen.insert( gate.left ).inserted { queue.append( gate.left ) }
                    if seen.insert( gate.right ).inserted { queue.append( gate.right ) }
                }
            }
            result[thisZ] = seen
        }
        let jango = result.sorted { $0.key < $1.key }
        let wango = result.reduce( into: [ String : Set<String> ]() ) { wango, thisZ in
            if !thisZ.value.isDisjoint( with: zAffected ) {
                wango[thisZ.key] = result[thisZ.key]
            }
        }
        return result
    }
}


func enabled( value: Int, startsWith: String ) -> [String] {
    var bitNumber = 0
    var value = value
    var result = [String]()
    
    while value > 0 {
        if value & 1 == 1 {
            result.append( String( format: "\(startsWith)%02d", bitNumber ) )
        }
        bitNumber += 1
        value >>= 1
    }
    return result
}


func parse( input: AOCinput ) -> Any? {
    return nil
}


func part1( input: AOCinput ) -> String {
    var monitor = Monitor( paragraphs: input.paragraphs )
    monitor.engage()
    return "\( monitor.valueOf( startsWith: "z" ) )"
}


func part2( input: AOCinput ) -> String {
    var monitor = Monitor( paragraphs: input.paragraphs )
    monitor.engage()
    let xValue = monitor.valueOf( startsWith: "x" )
    let yValue = monitor.valueOf( startsWith: "y" )
    let zValue = monitor.valueOf( startsWith: "z" )
    let effected = ( xValue + yValue ) ^ zValue
    let zAffected = enabled( value: effected, startsWith: "z" )
    let blarg = monitor.blarg( zAffected: zAffected )
    return "\( ( xValue + yValue ) ^ zValue )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
