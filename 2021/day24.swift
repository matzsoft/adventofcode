//
//         FILE: main.swift
//  DESCRIPTION: day24 - Arithmetic Logic Unit
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/23/21 22:40:29
//

import Foundation

let modelNumberLength = 14
let inputIndices = 0 ..< modelNumberLength
let validInputs = 1 ..< 10

extension Range where Element : BinaryInteger {
    func offset( by: Bound ) -> Range { ( lowerBound + by ) ..< ( upperBound + by ) }
}


// This type is not required to solve the problem.  It does correctly execute any ALU program.
// It can be used to validate a submarine model number.
struct ALU: CustomStringConvertible {
    struct Instruction: CustomStringConvertible {
        enum VariableName: String { case w, x, y, z }
        enum Opcode: String { case inp, add, mul, div, mod, eql }
        enum Operand: CustomStringConvertible {
            case variable(VariableName), int(Int)
            var description: String {
                switch self {
                case .variable(let variable):
                    return "\(variable)"
                case .int(let int):
                    return "\(int)"
                }
            }
            var value: Int {
                switch self {
                case .variable:
                    return 0
                case .int(let int):
                    return int
                }
            }
        }
        let opcode: Opcode
        let result: VariableName
        let operand: Operand
        
        var description: String {
            switch opcode {
            case .inp:
                return "\(opcode) \(result)"
            default:
                return "\(opcode) \(result) \(operand)"
            }
        }
        
        init( line: String ) throws {
            let words = line.split( separator: " " )
            
            guard let opcode = Opcode( rawValue: String( words[0] ) ) else {
                throw RuntimeError( "Invalid opcode \(words[0])" )
            }
            self.opcode = opcode
            
            guard let result = VariableName( rawValue: String( words[1] ) ) else {
                throw RuntimeError( "Invalid result variable \(words[1])" )
            }
            self.result = result
            
            if opcode == .inp {
                self.operand = .int( 0 )
            } else if let operand = VariableName( rawValue: String( words[2] ) ) {
                self.operand = .variable( operand )
            } else if let operand = Int( String( words[2] ) ) {
                self.operand = .int( operand )
            } else {
                throw RuntimeError( "Invalid operand \(words[2])" )
            }
        }
    }
    
    let instructions: [Instruction]
    var variables: [ Instruction.VariableName : Int ]
    var dirty = [ Instruction.VariableName : String ]()
    var description: String {
        instructions.enumerated().map { String( format: "%3d: \($0.1)", $0.0 ) }.joined( separator: "\n" )
    }
    
    init( lines: [String] ) throws {
        instructions = try lines.map { try Instruction( line: $0 ) }
        variables = [ .w: 0, .x: 0, .y: 0, .z: 0 ]
    }
    
    func parameters( ip: Int ) -> [Int] {
        [ instructions[ip+4].operand.value, instructions[ip+5].operand.value, instructions[ip+15].operand.value ]
    }
    
    mutating func run( input: [Int] ) throws -> Void {
        var inputQueue = input
        
        variables = [ .w: 0, .x: 0, .y: 0, .z: 0 ]
        for ( ip, instruction ) in instructions.enumerated() {
            switch instruction.opcode {
            case .inp:
                if inputQueue.isEmpty { throw RuntimeError( "Input queue exhausted at ip \(ip)" ) }
                variables[ instruction.result ] = inputQueue.removeFirst()
            case .add:
                switch instruction.operand {
                case .variable( let variable ):
                    variables[ instruction.result ]! += variables[ variable ]!
                case .int( let int ):
                    variables[ instruction.result ]! += int
                }
            case .mul:
                switch instruction.operand {
                case .variable( let variable ):
                    variables[ instruction.result ]! *= variables[ variable ]!
                case .int( let int ):
                    variables[ instruction.result ]! *= int
                }
            case .div:
                switch instruction.operand {
                case .variable( let variable ):
                    variables[ instruction.result ]! /= variables[ variable ]!
                case .int( let int ):
                    variables[ instruction.result ]! /= int
                }
            case .mod:
                switch instruction.operand {
                case .variable( let variable ):
                    variables[ instruction.result ]! %= variables[ variable ]!
                case .int( let int ):
                    variables[ instruction.result ]! %= int
                }
            case .eql:
                switch instruction.operand {
                case .variable( let variable ):
                    variables[ instruction.result ]!
                        = variables[ instruction.result ]! == variables[ variable ]! ? 1 : 0
                case .int( let int ):
                    variables[ instruction.result ]! = variables[ instruction.result ]! == int ? 1 : 0
                }
            }
        }
    }
}


// This function is also not needed to solve the problem.  It simulates what an ALU running the MONAD
// program does.  Hence it can also be used to validate a submarine model number.
func MONAD( alu: ALU, input: [Int] ) -> Int {
    struct BottomlessStack {
        var values = [Int]()
        var top: Int { return values.isEmpty ? 0 : values.last! }
        mutating func push( value: Int ) -> Void { values.append( value ) }
        mutating func pop() -> Void { if !values.isEmpty { values.removeLast() } }
    }

    var stack = BottomlessStack()

    func monad( input: Int, p1: Int, p2: Int, p3: Int ) -> Void {
        let top = stack.top
        if p1 == 26 { stack.pop() }
        if top + p2 != input { stack.push( value: input + p3 ) }
    }
    
    input.indices.forEach {
        let parameters = alu.parameters( ip: 18 * $0 )
        monad( input: input[$0], p1: parameters[0], p2: parameters[1], p3: parameters[2] )
    }
    
    return stack.values.isEmpty ? 0 : stack.values.reduce( 0 ) { $0 * 26 + $1 }
}


struct Solver {
    struct BottomlessStack {
        var values = [ ( Int, Int ) ]()
        var top: ( Int, Int ) { return values.isEmpty ? ( 0, 0 ) : values.last! }
        mutating func push( value: ( Int, Int ) ) -> Void { values.append( value ) }
        mutating func pop() -> Void { if !values.isEmpty { values.removeLast() } }
    }

    struct Condition: CustomStringConvertible {
        let firstIndex: Int
        let offset: Int
        let secondIndex: Int

        var description: String {
            if offset > 0 {
                return "d\(firstIndex+1) + \(offset) == d\(secondIndex+1)"
            }
            return "d\(firstIndex+1) - \(-offset) == d\(secondIndex+1)"
        }
    }

    let conditions: [Condition]
    let ranges: [Range<Int>]

    init( alu: ALU ) {
        var stack = BottomlessStack()
        var conditions = [Condition]()

        ranges = inputIndices.reduce( into: Array( repeating: validInputs, count: modelNumberLength ) ) {
            let parameters = alu.parameters( ip: 18 * $1 )
            let top = stack.top
            if parameters[0] == 26 { stack.pop() }

            let actualRange = ( top.1 + parameters[1] + 1 ..< top.1 + parameters[1] + 10 )
            if !actualRange.overlaps( validInputs ) {
                stack.push( value: ( $1, parameters[2] ) )
            } else {
                conditions.append(
                    Condition( firstIndex: top.0, offset: top.1 + parameters[1], secondIndex: $1 ) )
                $0[$1] = actualRange.clamped( to: validInputs )
                $0[top.0] = $0[$1].offset( by: -top.1 - parameters[1] )
            }
        }
        self.conditions = conditions
    }
}


func parse( input: AOCinput ) -> ALU {
    return try! ALU( lines: input.lines )
}


func part0( input: AOCinput ) -> String {
    var alu = parse( input: input )
//    print("\(alu)")
    
//    for base in 0 ... 17 {
//        for other in stride( from: base, to: input.lines.count, by: 18 ) {
//            if input.lines[base] != input.lines[other] {
//                print( String( format: "%3d: \(alu.instructions[base])", base ) )
//                print( String( format: "%3d: \(alu.instructions[other])", other ) )
//                print( "-------------------------" )
//            }
//        }
//    }
    let input = Array( "65984919997939" ).map { Int( String( $0 ) )! }
    try! alu.run( input: input )
    print( "From ALU: \( alu.variables[.z]! )" )
    print( "From monad: \( MONAD( alu: alu, input: input ) )" )
    
    let solver = Solver( alu: alu )
    solver.conditions.forEach { print( "\($0)" ) }
    print( "solver: \( solver.ranges.map { String( $0.last! ) }.joined() )" )

    return "\( solver.ranges.map { String( $0.last! ) }.joined() )"
}


func part1( input: AOCinput ) -> String {
    let alu = parse( input: input )

    return "\( Solver( alu: alu ).ranges.map { String( $0.last! ) }.joined() )"
}


func part2( input: AOCinput ) -> String {
    let alu = parse( input: input )

    return "\( Solver( alu: alu ).ranges.map { String( $0.first! ) }.joined() )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
