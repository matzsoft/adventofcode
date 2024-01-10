//
//         FILE: day20.swift
//  DESCRIPTION: Advent of Code 2023 Day 20: Pulse Propagation
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/19/23 21:00:01
//

import Foundation
import Library

enum PulseType: Int { case low, high }

struct Pulse {
    let source: String
    let destination: String
    let type: PulseType
}


struct Module {
    enum ModuleType: Character {
        case flipFlop = "%", conjunction = "&"
        var description: String {
            switch self {
            case .flipFlop:
                return "FlipFlop"
            case .conjunction:
                return "Conjunction"
            }
        }
    }
    
    enum State {
        case off, on
        
        mutating func toggle() -> Void {
            self = self == .off ? .on : .off
        }
    }
    
    let name: String
    let type: ModuleType?
    let outputs: [String]
    var inputs: [ String : PulseType ]
    var state: State
    var cycleLow: Int?
    var cycleHigh: Int?
    
    init( name: String, type: Module.ModuleType?, outputs: [String], inputs: [String : PulseType] ) {
        self.name = name
        self.type = type
        self.outputs = outputs
        self.inputs = inputs
        self.state = .off
    }
    
    init( line: String ) {
        let words = line.split(whereSeparator: { " ->,".contains( $0 ) } ).map { String( $0 ) }
        
        if let type = ModuleType( rawValue: words[0].first! ) {
            self.type = type
            name = String( words[0].dropFirst() )
        } else {
            type = nil
            name = words[0]
        }
        
        outputs = Array( words[1...] )
        inputs = [:]
        state = .off
    }
    
    var outputsLine: String {
        "\(name)\( type == nil ? "" : " " + type!.description ) -> \(outputs.joined(separator: ", " ) )"
    }
    
    var inputsLine: String {
        "\(name)\( type == nil ? "" : " " + type!.description ) <- \(inputs.keys.joined(separator: ", " ) )"
    }
    
    mutating func process( pulse: Pulse ) -> [ Pulse ] {
        if name == "broadcaster" {
            return outputs.map { Pulse( source: name, destination: $0, type: pulse.type ) }
        }
        if name == "rx" && pulse.type == .low { state.toggle() }
        guard let type = type else { return [] }
        
        switch type {
        case .flipFlop:
            guard pulse.type == .low else { return [] }
            state.toggle()
            if state == .off { return outputs.map { Pulse( source: name, destination: $0, type: .low ) } }
            return outputs.map { Pulse( source: name, destination: $0, type: .high ) }
        case .conjunction:
            inputs[pulse.source] = pulse.type
            if inputs.values.allSatisfy( { $0 == .high } ) {
                return outputs.map { Pulse( source: name, destination: $0, type: .low ) }
            }
            return outputs.map { Pulse( source: name, destination: $0, type: .high ) }
        }
    }
}


struct Network {
    var modules: [ String : Module ]
    var lowCount = 0
    var highCount = 0

    init( modules: [String : Module], lowCount: Int = 0, highCount: Int = 0 ) {
        self.modules = modules
        self.lowCount = lowCount
        self.highCount = highCount
    }
    
    init( lines: [String] ) {
        var modules = lines
            .map { Module( line: $0 ) }
            .reduce( into: [ String : Module ]() ) { $0[$1.name] = $1 }
        
        for ( name, module ) in modules {
            for output in module.outputs {
                if modules[output] != nil {
                    modules[output]!.inputs[name] = .low
                } else {
                    modules[output] = Module( name: output, type: nil, outputs: [], inputs: [ name : .low ] )
                }
            }
        }
        self.modules = modules
    }
    
    func diagram( node: String, inputs: Bool = true ) -> String {
        var done = Set<String>()
        
        func diagramInputs( _ node: String, prefix: String ) -> String? {
            if done.contains( node ) { return nil }
            done.insert( node )
            
            let outputLines = modules[node]!
                .inputs.keys.filter { !done.contains( $0 ) }
                .compactMap { diagramInputs( $0, prefix: "\( "|  " + prefix )" ) }
            let lines = [ prefix + modules[node]!.inputsLine ] + outputLines
            
            return lines.joined( separator: "\n" )
        }
        
        func diagramOutputs( _ node: String, prefix: String ) -> String? {
            if done.contains( node ) { return nil }
            done.insert( node )
            
            let outputLines = modules[node]!
                .outputs.filter { !done.contains( $0 ) }
                .compactMap { diagramOutputs( $0, prefix: "\( "|  " + prefix )" ) }
            let lines = [ prefix + modules[node]!.outputsLine ] + outputLines
            
            return lines.joined( separator: "\n" )
        }
        
        if inputs { return diagramInputs( node, prefix: "" )! }
        return diagramOutputs( node, prefix: "" )!
    }
    
    mutating func push() -> Void {
        var queue = [ Pulse( source: "button", destination: "broadcaster", type: .low ) ]
        
        while !queue.isEmpty {
            let pulse = queue.removeFirst()
            let results = modules[ pulse.destination ]!.process( pulse: pulse )
            
            if pulse.type == .low { lowCount += 1 } else { highCount += 1 }
            queue.append( contentsOf: results )
        }
    }
    
    func extractSubnet( parent: String, start: String, exclude: String ) -> Network {
        guard modules[start]?.type == .flipFlop else { fatalError( "\(start) is not a flipflop." ) }
        var modules = [ parent : Module( name: parent, type: nil, outputs: [start], inputs: [:] ) ]
        var queue = [ start ]
        var seen = Set( [start] )
        
        while !queue.isEmpty {
            let next = queue.removeFirst()
            let old = self.modules[next]!
            let outputs = old.outputs.filter { $0 != exclude }
            
            modules[next] = Module( name: next, type: old.type, outputs: outputs, inputs: old.inputs )
            let more = outputs.filter { !seen.contains( $0 ) }
            
            seen.formUnion( more )
            queue.append( contentsOf: more )
        }
        
        if modules.values.contains( where: { $0.inputs.keys.contains( where: { modules[$0] == nil } ) } ) {
            fatalError( "Non-disjoint subnetork." )
        }
        
        if modules.values.filter( { $0.outputs.isEmpty } ).count != 1 {
            fatalError( "Unexpected conjunction count." )
        }
        
        return Network( modules: modules )
    }
    
    mutating func watch( for pulseType: PulseType, on node: String ) -> Int {
        var pushNumber = 0
        
        while true {
            var queue = [ Pulse( source: "button", destination: "broadcaster", type: .low ) ]
            
            pushNumber += 1
            while !queue.isEmpty {
                let pulse = queue.removeFirst()
                if pulse.type == pulseType && pulse.destination == node { return pushNumber }
                queue.append( contentsOf: modules[ pulse.destination ]!.process( pulse: pulse ) )
            }
        }
    }
}


func parse( input: AOCinput ) -> Any? {
    return nil
}


func part1( input: AOCinput ) -> String {
    var network = Network( lines: input.lines )

    for _ in 1 ... 1000 { network.push() }
    return "\( network.lowCount * network.highCount )"
}


func part2( input: AOCinput ) -> String {
    var network = Network( lines: input.lines )
    let terminal = network.modules["rx"]!.inputs.keys.first!
    let subnets = network.modules["broadcaster"]!.outputs
        .map { network.extractSubnet( parent: "broadcaster", start: $0, exclude: terminal ) }
    
    let cycles = subnets.map {
        var subnet = $0
        let final = subnet.modules.values.first { $0.outputs.isEmpty }!.name
        return subnet.watch( for: .low, on: final )
    }

    return "\( cycles.reduce( 1, { lcm( $0, $1 ) } ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
