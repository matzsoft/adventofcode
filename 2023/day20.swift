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
    enum ModuleType: Character { case flipFlop = "%", conjuction = "&" }
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
    
    mutating func process( pulse: Pulse ) -> [ Pulse ] {
        if name == "broadcaster" {
            return outputs.map { Pulse( source: name, destination: $0, type: pulse.type ) }
        }
        guard let type = type else { return [] }
        
        switch type {
        case .flipFlop:
            guard pulse.type == .low else { return [] }
            state.toggle()
            if state == .off { return outputs.map { Pulse( source: name, destination: $0, type: .low ) } }
            return outputs.map { Pulse( source: name, destination: $0, type: .high ) }
        case .conjuction:
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

    init( lines: [String] ) {
        var modules = lines
            .map { Module( line: $0 ) }
            .reduce( into: [ String : Module ]() ) { $0[$1.name] = $1 }
        
        for ( name, module ) in modules {
            for output in module.outputs {
                if let outputModule = modules[output] {
                    modules[output]!.inputs[name] = .low
                } else {
                    modules[output] = Module( name: output, type: nil, outputs: [], inputs: [ name : .low ] )
                }
            }
        }
        self.modules = modules
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
    let something = parse( input: input )
    return ""
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
