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
    
    init(
        left: String, right: String, operation: Gate.Operation, output: String, fired: Bool
    ) {
        self.left = left
        self.right = right
        self.operation = operation
        self.output = output
        self.fired = fired
    }
    
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
    
    mutating func reset() -> Void {
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
    
    func update( output: String ) -> Gate {
        Gate( left: left, right: right, operation: operation, output: output, fired: fired )
    }
}

struct Monitor {
    let initialWires: [Wire]
    var wireValues: [ String : Bool ]
    var gates: [Gate]
    let gatesMap: [ String : Int ]
    
    init( paragraphs: [[String]] ) {
        initialWires = paragraphs[0].map { Wire( line: $0 ) }
        wireValues = initialWires.reduce( into: [ String : Bool ]() ) {
            $0[$1.name] = $1.value
        }
        let gates = paragraphs[1].map { Gate( line: $0 ) }
        self.gates = gates
        gatesMap = gates.indices.reduce( into: [ String : Int ]() ) {
            $0[ gates[$1].output ] = $1
        }
    }
    
    mutating func reset() -> Void {
        wireValues = initialWires.reduce( into: [ String : Bool ]() ) {
            $0[$1.name] = $1.value
        }
        gates.indices.forEach { gates[$0].reset() }
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
    
    func allInfluences() -> [ String : Set<String> ] {
        let allZ = Set( wireValues.keys.filter { $0.hasPrefix( "z" ) } )
        
        return allZ.reduce( into: [ String : Set<String> ]() ) { result, thisZ in
            var queue = [thisZ]
            var seen = Set<String>()
            while !queue.isEmpty {
                let current = queue.removeFirst()
                if let gateIndex = gatesMap[current] {
                    let gate = gates[gateIndex]
                    
                    if seen.insert( gate.left ).inserted { queue.append( gate.left ) }
                    if seen.insert( gate.right ).inserted { queue.append( gate.right ) }
                }
            }
            result[thisZ] = seen
        }
    }
    
    mutating func swapPair( zAffected: [String], allInfluences: [ String : Set<String> ] ) {
        let zAffected = Set( zAffected )
        let allZ = Set( wireValues.keys.filter { $0.hasPrefix( "z" ) } )
        let notAffected = allZ.subtracting( zAffected )
        let moose = zAffected
            .reduce( into: [ String : Set<String> ]() ) { moose, thisZ in
                moose[thisZ] = notAffected.reduce( allInfluences[thisZ]! ) {
                    $0.subtracting( allInfluences[$1]! )
            }
        }
            .filter { !$0.value.isEmpty }
        
        guard moose.count == 1 else { fatalError( "Pair count invalid" ) }
        guard moose.first!.value.count == 2 else { fatalError( "Not a pair" ) }
        
        let pair = Array( moose.first!.value )
        
        gates[ gatesMap[pair[0]]! ] = gates[ gatesMap[pair[0]]! ].update( output: pair[1] )
        gates[ gatesMap[pair[1]]! ] = gates[ gatesMap[pair[1]]! ].update( output: pair[0] )
    }

//    func blarg( zAffected: [String] ) -> [ String : Set<String> ] {
//        let zAffected = Set( zAffected )
//        let allZ = Set( wireValues.keys.filter { $0.hasPrefix( "z" ) } )
//        let notAffected = allZ.subtracting( zAffected )
//        let result = allZ.reduce( into: [ String : Set<String> ]() ) { result, thisZ in
//            var queue = [thisZ]
//            var seen = Set<String>()
//            while !queue.isEmpty {
//                let current = queue.removeFirst()
//                if let gateIndex = gatesMap[current] {
//                    let gate = gates[gateIndex]
//                    
//                    if seen.insert( gate.left ).inserted { queue.append( gate.left ) }
//                    if seen.insert( gate.right ).inserted { queue.append( gate.right ) }
//                }
//            }
//            result[thisZ] = seen
//        }
//        let moose = zAffected.reduce( into: [ String : Set<String> ]() ) { moose, thisZ in
//            moose[thisZ] = notAffected.reduce( result[thisZ]! ) {
//                $0.subtracting( result[$1]! )
//            }
//        }
//        let jango = result.sorted { $0.key < $1.key }
//        let wango = result.reduce( into: [ String : Set<String> ]() ) { wango, thisZ in
//            if !thisZ.value.isDisjoint( with: zAffected ) {
//                wango[thisZ.key] = result[thisZ.key]
//            }
//        }
//        return result
//    }
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


func part1( input: AOCinput ) -> String {
    var monitor = Monitor( paragraphs: input.paragraphs )
    monitor.engage()
    return "\( monitor.valueOf( startsWith: "z" ) )"
}


func part2( input: AOCinput ) -> String {
    var monitor = Monitor( paragraphs: input.paragraphs )
    let xValue = monitor.valueOf( startsWith: "x" )
    let yValue = monitor.valueOf( startsWith: "y" )
    let sum = xValue + yValue
    
    monitor.engage()
    var zValue = monitor.valueOf( startsWith: "z" )

    while sum != zValue {
        let bitsAffected = ( xValue + yValue ) ^ zValue
        let zAffected = enabled( value: bitsAffected, startsWith: "z" )
        let allInfluences = monitor.allInfluences()
        
        monitor.swapPair( zAffected: zAffected, allInfluences: allInfluences )
        monitor.reset()
        monitor.engage()
        zValue = monitor.valueOf( startsWith: "z" )
    }
    
    return "\( ( xValue + yValue ) ^ zValue )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
