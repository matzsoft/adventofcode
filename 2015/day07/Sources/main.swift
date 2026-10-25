//
//         FILE: main.swift
//  DESCRIPTION: day07 - Some Assembly Required
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/05/21 13:10:54
//

import Foundation
import Library

struct Instruction {
    enum Operator { case load, and, or, not, rshift, lshift }
    
    let opcode: Operator
    let operand1: String
    let operand2: String
    let destination: String
    
    init( line: String ) throws {
        let sides = line.components( separatedBy: " -> " )
        let words = sides[0].components( separatedBy: " " )
        
        switch words.count {
        case 1:
            opcode = .load
            operand1 = words[0]
            operand2 = words[0]
        case 2:
            guard words[0] == "NOT" else { throw RuntimeError( "Invalid operator '\(words[0])'." ) }
            opcode = .not
            operand1 = words[1]
            operand2 = words[1]
        case 3:
            switch words[1] {
            case "AND":
                opcode = .and
            case "OR":
                opcode = .or
            case "RSHIFT":
                opcode = .rshift
            case "LSHIFT":
                opcode = .lshift
            default:
                throw RuntimeError( "Invalid operator '\(words[1])'." )
            }
            operand1 = words[0]
            operand2 = words[2]
        default:
            throw RuntimeError( "Too many words on the input side: '\(line)'." )
        }
        destination = sides[1]
    }
}


struct Circuit {
    let wiring: [ String : Instruction ]
    var values = [ String : UInt16 ]()
    
    init( lines: [String] ) throws {
        wiring = try lines.reduce( into: [ String : Instruction ]() ) { dict, line in
            let instruction = try Instruction( line: line )
            dict[instruction.destination] = instruction
        }
    }
    
    mutating func reset() -> Void {
        values.removeAll()
    }
    
    mutating func overide( name: String, value: UInt16 ) -> Void {
        values[name] = value
    }
    
    mutating func fetch( operand: String ) throws -> UInt16 {
        if let value = UInt16( operand ) { return value }
        return try nodeValue( name: operand )
    }
    
    mutating func nodeValue( name: String ) throws -> UInt16 {
        if let value = values[name] { return value }
        guard let node = wiring[name] else { throw RuntimeError( "Broken circuit for '\(name)'." ) }
        
        switch node.opcode {
        case .load:
            values[name] = try fetch( operand: node.operand1 )
        case .and:
            values[name] = try fetch( operand: node.operand1 ) & fetch( operand: node.operand2 )
        case .or:
            values[name] = try fetch( operand: node.operand1 ) | fetch( operand: node.operand2 )
        case .not:
            values[name] = try ~fetch( operand: node.operand1 )
        case .lshift:
            values[name] = try fetch( operand: node.operand1 ) << fetch( operand: node.operand2 )
        case .rshift:
            values[name] = try fetch( operand: node.operand1 ) >> fetch( operand: node.operand2 )
        }
        return values[name]!
    }
}


func parse( input: AOCinput ) -> Circuit {
    return try! Circuit( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    var circuit = parse( input: input )
    
    return "\( try! circuit.nodeValue( name: "a" ) )"
}


func part2( input: AOCinput ) -> String {
    var circuit = parse( input: input )
    let part1 = try! circuit.nodeValue( name: "a" )
    
    circuit.reset()
    circuit.overide( name: "b", value: part1 )
    return "\( try! circuit.nodeValue( name: "a" ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
