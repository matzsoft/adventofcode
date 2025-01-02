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

struct Gate: Hashable {
    enum Operation: String { case and = "AND", or = "OR", xor = "XOR" }
    
    let left: String
    let right: String
    let operation: Operation
    let output: String
    var fired: Bool
    
    init(
        left: String, right: String, operation: Gate.Operation,
        output: String, fired: Bool = false
    ) {
        if left < right {
            self.left = left
            self.right = right
        } else {
            self.left = right
            self.right = left

        }
        self.operation = operation
        self.output = output
        self.fired = fired
    }
    
    init( line : String ) {
        let fields = line
            .split( whereSeparator: { " ->".contains( $0 ) } )
            .map { String( $0 ) }
        
        self.init(
            left: fields[0], right: fields[2],
            operation: Operation( rawValue: fields[1] )!,
            output: fields[3], fired: false
        )
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
    
    func updating( output: String ) -> Gate {
        Gate(
            left: left, right: right, operation: operation,
            output: output, fired: fired
        )
    }
    
    func replacing( mapping: Mapping ) -> Gate? {
        guard let left = mapping[left] else { return nil }
        guard let right = mapping[right] else { return nil }
        
        return Gate( left: left, right: right, operation: operation, output: output )
    }
}

struct Names {
    let cnm: String
    let xnn: String
    let ynn: String
    let znn: String
    let fnn: String
    let gnn: String
    let hnn: String
    let cnn: String

    init( bitNo: Int, bitCount: Int ) {
        cnm = String( format: "c%02d", bitNo - 1 )
        xnn = String( format: "x%02d", bitNo )
        ynn = String( format: "y%02d", bitNo )
        znn = String( format: "z%02d", bitNo )
        fnn = String( format: "f%02d", bitNo )
        gnn = String( format: "g%02d", bitNo )
        hnn = String( format: "h%02d", bitNo )
        if bitNo < bitCount - 1 {
            cnn = String( format: "c%02d", bitNo )
        } else {
            cnn = String( format: "z%02d", bitCount )
        }
    }
}

struct Mapping {
    var canonical: [ String : String ]
    var actual: [ String : String ]
    
    init( initial: [String] ) {
        canonical = initial.reduce( into: [ String : String ]() ) { $0[$1] = $1 }
        actual = canonical
    }
    
    subscript( _ key: String ) -> String? {
        canonical[key]
    }
    
    mutating func add( canonical: String, actual: String ) -> Void {
        self.canonical[canonical] = actual
        self.actual[actual] = canonical
    }
}

struct Monitor {
    let initialWires: [Wire]
    let bitCount: Int
    var wireValues: [ String : Bool ]
    var gates: [Gate]
    let gatesMap: [ String : Gate ]
    
    init(
        initialWires: [Wire], wireValues: [String : Bool]? = nil,
        gates: [Gate], gatesMap: [ String : Gate ]? = nil
    ) {
        self.initialWires = initialWires
        self.bitCount = initialWires.count / 2
        if let wireValues = wireValues {
            self.wireValues = wireValues
        } else {
            self.wireValues = initialWires.reduce( into: [ String : Bool ]() ) {
                $0[$1.name] = $1.value
            }
        }
        self.gates = gates
        if let gatesMap = gatesMap {
            self.gatesMap = gatesMap
        } else {
            self.gatesMap = gates.reduce( into: [ String : Gate ]() ) {
                $0[ $1.output ] = $1
            }
        }
    }
    
    init( paragraphs: [[String]] ) {
        let initialWires = paragraphs[0].map { Wire( line: $0 ) }
        let gates = paragraphs[1].map { Gate( line: $0 ) }

        self.init( initialWires: initialWires, gates: gates )
    }
    
    var makeAdder: Monitor {
        let initialGates = [
            Gate( left: "x00", right: "y00", operation: .xor, output: "z00" ),
            Gate( left: "x00", right: "y00", operation: .and, output: "c00" ),
        ]
        let gates = ( 1 ..< bitCount ).reduce( into: initialGates ) {
            let n = Names( bitNo: $1, bitCount: bitCount )

            $0.append( contentsOf: [
                Gate( left: n.xnn, right: n.ynn, operation: .xor, output: n.fnn ),
                Gate( left: n.fnn, right: n.cnm, operation: .xor, output: n.znn ),
                Gate( left: n.cnm, right: n.fnn, operation: .and, output: n.gnn ),
                Gate( left: n.xnn, right: n.ynn, operation: .and, output: n.hnn ),
                Gate( left: n.gnn, right: n.hnn, operation: .or,  output: n.cnn )
            ] )
        }

        return Monitor( initialWires: initialWires, gates: gates )
    }
    
    func standardIndex( of wire: String ) -> Int? {
        let prefix = wire.first!
        let bitNo = Int( wire.dropFirst() )!
        
        if bitNo == 0 {
            return [ "z", "c" ].firstIndex( of: prefix )
        } else {
            let base = 5 * bitNo - 3
            let valid: [Character] = [ "f", "z", "g", "h", "c" ]
            guard let offset = valid.firstIndex( of: prefix ) else { return nil }
            return base + offset
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
    
    func find( gate: Gate ) -> Gate? {
        gates.first {
            $0.left == gate.left && $0.right == gate.right
            && $0.operation == gate.operation
        }
    }
    
    func find( input: String ) -> [Gate] {
        gates.filter { $0.left == input || $0.right == input }
    }
    
    func isOK( zGate: Gate, xorGate: Gate ) -> Bool {
        let bitNo = Int( zGate.output.dropFirst() )!
        let xnn = String( format: "x%02d", bitNo )
        let ynn = String( format: "y%02d", bitNo )
        
        return xorGate.left == xnn && xorGate.right == ynn
    }
    
    func isOK( zGate: Gate, orGate: Gate ) -> Bool {
        let left = gatesMap[ orGate.left ]!
        let right = gatesMap[ orGate.right ]!
        
        return left.operation == .and && right.operation == .and
    }
    
    func canonical() -> ( String, String )? {
        let adder = makeAdder
        var mapping = Mapping( initial: initialWires.map { $0.name } )
        var badBunnies = Set<String>()
        
        var newGates = ( 0 ... 1 ).map {
            find( gate: adder.gates[$0].replacing( mapping: mapping )! )!
        }
        mapping.add( canonical: "c00", actual: newGates[1].output )
        
        for index in 2 ..< gates.count {
            let target = adder.gates[index].replacing( mapping: mapping )!
            if let actual = find( gate: target ) {
                mapping.add(
                    canonical: adder.gates[ index].output, actual: actual.output
                )
                newGates.append( actual )
            } else {
                if target.left.hasPrefix( "z" ) {
                    let other = newGates[ standardIndex( of: target.left )! ].output
                    return ( target.left, other )
                }
                if target.right.hasPrefix( "z" ) {
                    let other = newGates[ standardIndex( of: target.right )! ].output
                    return ( target.right, other )
                }
                
                let leftInputs = find( input: target.left )
                let rightInputs = find( input: target.right )
                switch target.operation {
                case .or:
                    if leftInputs.count == 2 {
                        badBunnies.insert( target.left )
                    }
                    if rightInputs.count == 2 {
                        badBunnies.insert( target.right )
                    }
                case .xor, .and:
                    if leftInputs.count == 1 {
                        badBunnies.insert( target.left )
                    }
                    if rightInputs.count == 1 {
                        badBunnies.insert( target.right )
                    }
                }
                mapping.add( canonical: target.output, actual: target.output )
                newGates.append( target )
                if badBunnies.count > 1 {
                    let pair = Array( badBunnies )
                    return ( pair[0], pair[1] )
                }
            }
        }
        
        return nil
    }
    
    func allInfluences() -> [ String : Set<String> ] {
        let allZ = Set( wireValues.keys.filter { $0.hasPrefix( "z" ) } )
        
        return allZ.reduce( into: [ String : Set<String> ]() ) { result, thisZ in
            var queue = [thisZ]
            var seen = Set<String>()
            while !queue.isEmpty {
                let current = queue.removeFirst()
                if let gate = gatesMap[current] {
                    if seen.insert( gate.left ).inserted { queue.append( gate.left ) }
                    if seen.insert( gate.right ).inserted { queue.append( gate.right ) }
                }
            }
            result[thisZ] = seen
        }
    }
    
    func swapingPair( output1: String, output2: String ) -> Monitor {
        let newGates = gates.map { gate in
            if gate.output == output1 {
                return gate.updating( output: output2 )
            } else if gate.output == output2 {
                return gate.updating( output: output1 )
            }
            return gate
        }
        
        return Monitor( initialWires: initialWires, gates: newGates )
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
    
    var modified = monitor
    var badWires = Set<String>()
    
    while true {
        guard let pair = modified.canonical() else { break }
        badWires.formUnion( [ pair.0, pair.1 ] )
        modified = modified.swapingPair( output1: pair.0, output2: pair.1 )
    }
    
    return "\( badWires.sorted().joined( separator: "," ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
