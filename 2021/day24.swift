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

struct BottomlessStack {
    var values = [Int]()
    var top: Int { return values.isEmpty ? 0 : values.last! }
    mutating func push( value: Int ) -> Void { values.append( value ) }
    mutating func pop() -> Void { if !values.isEmpty { values.removeLast() } }
}

struct BottomlessStack2 {
    var values = [ ( Int, Int ) ]()
    var top: ( Int, Int ) { return values.isEmpty ? ( 0, 0 ) : values.last! }
    mutating func push( value: ( Int, Int ) ) -> Void { values.append( value ) }
    mutating func pop() -> Void { if !values.isEmpty { values.removeLast() } }
}

class Expression {
    enum Kind { case knownValue, input, add, mul, div, mod, eql }
    
    let type: Kind
    let value: Int
    let min: Int
    let max: Int
    let left: Expression?
    let right: Expression?
    
    internal init(
        type: Expression.Kind, value: Int, min: Int, max: Int,
        left: Expression? = nil, right: Expression? = nil
    ) {
        self.type = type
        self.value = value
        self.min = min
        self.max = max
        self.left = left
        self.right = right
    }
    
}


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
    
    func parameters( ip: Int ) -> ( Int, Int, Int ) {
        ( instructions[ip+4].operand.value, instructions[ip+5].operand.value, instructions[ip+15].operand.value )
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

//    mutating func addProcess( instruction: Instruction ) -> String {
//        <#function body#>
//    }
    
    mutating func interpret( input: [Int] ) throws -> Void {
        var inputPointer = 0
        
        variables = [ .w: 0, .x: 0, .y: 0, .z: 0 ]
        dirty = [:]
        for ( ip, instruction ) in instructions.enumerated() {
            let disassembly = String( format: "%3d: \(instruction)", ip )
            var comment = ""
            switch instruction.opcode {
            case .inp:
                if inputPointer >= input.count {
                    throw RuntimeError( "Input queue exhausted at ip \(ip)" ) }
                variables[ instruction.result ] = input[inputPointer]
                inputPointer += 1
                comment = "\(instruction.result) = d\(inputPointer)"
                dirty[instruction.result] = comment
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
            print( disassembly + String( repeating: " ", count: 20 - disassembly.count ) + "// \(comment)" )
        }
    }
}


func parse( input: AOCinput ) -> ALU {
    return try! ALU( lines: input.lines )
}

var stack = BottomlessStack()
var stack2 = BottomlessStack2()

func monad( input: Int, p1: Int, p2: Int, p3: Int ) -> Void {
    let top = stack.top
    if p1 == 26 { stack.pop() }
    if top + p2 != input { stack.push( value: input + p3 ) }
}


func monad2( input: Int, p1: Int, p2: Int, p3: Int ) -> ( Int, Int, Int )? {
    let top = stack2.top
    if p1 == 26 { stack2.pop() }
    
    let range1 = ( top.1 + p2 + 1 ... top.1 + p2 + 9 )
    let range2 = ( 1 ... 9 )
    if !range1.overlaps( range2 ) {
        stack2.push( value: ( input, p3 ) )
        return nil
    } else {
        print( "d\(top.0+1) + \(top.1 + p2) == d\(input+1)" )
        return ( top.0, top.1 + p2, input )
    }
}


func part1( input: AOCinput ) -> String {
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
//    try! alu.interpret( input: Array( "95985919997399" ).map { Int( String( $0 ) )! } )
    
//    monad( input: input[0], p1: 1, p2: 12, p3: 7 )
//    monad( input: input[1], p1: 1, p2: 11, p3: 15 )
//    monad( input: input[2], p1: 1, p2: 12, p3: 2 )
//    monad( input: input[3], p1: 26, p2: -3, p3: 15 )
//    monad( input: input[4], p1: 1, p2: 10, p3: 14 )
//    monad( input: input[5], p1: 26, p2: -9, p3: 2 )
//    monad( input: input[6], p1: 1, p2: 10, p3: 15 )
//    monad( input: input[7], p1: 26, p2: -7, p3: 1 )
//    monad( input: input[8], p1: 26, p2: -11, p3: 15 )
//    monad( input: input[9], p1: 26, p2: -4, p3: 15 )
//    monad( input: input[10], p1: 1, p2: 14, p3: 12 )
//    monad( input: input[11], p1: 1, p2: 11, p3: 2 )
//    monad( input: input[12], p1: 26, p2: -8, p3: 13 )
//    monad( input: input[13], p1: 26, p2: -10, p3: 13 )
//    print( "\( stack.values.isEmpty ? 0 : stack.values.reduce( 0 ) { $0 * 26 + $1 } )" )
    
    stack = BottomlessStack()
    input.indices.forEach {
        let parameters = alu.parameters( ip: 18 * $0 )
        monad( input: input[$0], p1: parameters.0, p2: parameters.1, p3: parameters.2 )
    }
    print( "From monad: \( stack.values.isEmpty ? 0 : stack.values.reduce( 0 ) { $0 * 26 + $1 } )" )
    
    let answer = input.indices.reduce( into: Array( repeating: 0, count: 14 ) ) {
        let parameters = alu.parameters( ip: 18 * $1 )
        if let result = monad2( input: $1, p1: parameters.0, p2: parameters.1, p3: parameters.2 ) {
            if result.1 > 0 {
                $0[result.0] = 9 - result.1
                $0[result.2] = 9
            } else {
                $0[result.0] = 9
                $0[result.2] = 9 + result.1
            }
        }
    }.map { String( $0 ) }.joined()
    return "\(answer)"
}


func part2( input: AOCinput ) -> String {
    var alu = parse( input: input )
    let input = Array( "11211619541713" ).map { Int( String( $0 ) )! }

    try! alu.run( input: input )
    print( "From ALU: \( alu.variables[.z]! )" )

    stack = BottomlessStack()
    stack2 = BottomlessStack2()
    input.indices.forEach {
        let parameters = alu.parameters( ip: 18 * $0 )
        monad( input: input[$0], p1: parameters.0, p2: parameters.1, p3: parameters.2 )
    }
    print( "From monad: \( stack.values.isEmpty ? 0 : stack.values.reduce( 0 ) { $0 * 26 + $1 } )" )
    
    let answer = input.indices.reduce( into: Array( repeating: 0, count: 14 ) ) {
        let parameters = alu.parameters( ip: 18 * $1 )
        if let result = monad2( input: $1, p1: parameters.0, p2: parameters.1, p3: parameters.2 ) {
            if result.1 > 0 {
                $0[result.0] = 1
                $0[result.2] = 1 + result.1
            } else {
                $0[result.0] = 1 - result.1
                $0[result.2] = 1
            }
        }
    }.map { String( $0 ) }.joined()
    return "\(answer)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
