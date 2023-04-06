//
//  Intcode.swift
//  day05
//
//  Created by Mark Johnson on 5/31/21.
//

import Foundation

public class Intcode {
    public struct Instruction {
        enum Mode: Int { case  position = 0, immediate = 1, relative = 2 }
        public enum Opcode: Int {
            case add = 1, multiply = 2, input = 3, output = 4
            case jumpIfTrue = 5, jumpIfFalse = 6, lessThan = 7, equals = 8
            case relativeBaseOffset = 9, halt = 99
        }
        
        public let opcode: Opcode
        let modes: [Mode]

        init( instruction: Int ) {
            opcode = Opcode( rawValue: instruction % 100 )!
            modes = [
                Mode( rawValue: instruction /   100 % 10 )!,
                Mode( rawValue: instruction /  1000 % 10 )!,
                Mode( rawValue: instruction / 10000 % 10 )!,
            ]
        }
        
        func mode( operand: Int ) -> Mode {
            return modes[ operand - 1 ]
        }
    }

    let name: String
    public var ip: Int
    var relativeBase: Int
    public var memory: [Int]
    public var inputs: [Int]
    var debug = false
    
    public var nextInstruction: Instruction {
        return Instruction( instruction: memory[ip] )
    }

    public init( name: String, memory: [Int] ) {
        self.name = name
        ip = 0
        relativeBase = 0
        self.memory = memory
        self.inputs = []
    }
    
    public init( from other: Intcode ) {
        name = other.name
        ip = other.ip
        relativeBase = other.relativeBase
        memory = other.memory
        inputs = other.inputs
        debug = other.debug
    }

    func fetch( _ instruction: Instruction, operand: Int ) throws -> Int {
        var location = memory[ ip + operand ]
        
        switch instruction.mode( operand: operand ) {
        case .position:
            break
        case .immediate:
            return location
        case .relative:
            location += relativeBase
        }

        if location < 0 {
            throw RuntimeError( "Negative memory fetch (\(location)) at address \(ip)" )
        } else if location >= memory.count {
            return 0
        }
        return memory[location]
    }
    
    func store( _ instruction: Instruction, operand: Int, value: Int ) throws -> Void {
        var location = memory[ ip + operand ]
        
        switch instruction.mode( operand: operand ) {
        case .position:
            break
        case .immediate:
            throw RuntimeError( "Immediate mode invalid for address \(ip)" )
        case .relative:
            location += relativeBase
        }

        if location < 0 {
            throw RuntimeError( "Negative memory store (\(location)) at address \(ip)" )
        } else if location >= memory.count {
            memory.append( contentsOf: Array( repeating: 0, count: location - memory.count + 1 ) )
        }
        memory[location] = value
    }

    public func step() throws -> Int? {
        let instruction = Instruction( instruction: memory[ip] )
        
        switch instruction.opcode {
        case .add:
            let operand1 = try fetch( instruction, operand: 1 )
            let operand2 = try fetch( instruction, operand: 2 )
            
            try store( instruction, operand: 3, value: operand1 + operand2 )
            ip += 4
        case .multiply:
            let operand1 = try fetch( instruction, operand: 1 )
            let operand2 = try fetch( instruction, operand: 2 )
            
            try store( instruction, operand: 3, value: operand1 * operand2 )
            ip += 4
        case .input:
            if debug { print( "\(name): inputs \(inputs.first!)" ) }
            try store( instruction, operand: 1, value: inputs.removeFirst() )
            ip += 2
        case .output:
            let operand1 = try fetch( instruction, operand: 1 )
            
            ip += 2
            if debug { print( "\(name): outputs \(operand1)" ) }
            return operand1
        case .jumpIfTrue:
            let operand1 = try fetch( instruction, operand: 1 )
            let operand2 = try fetch( instruction, operand: 2 )
            
            ip = operand1 != 0 ? operand2 : ip + 3
        case .jumpIfFalse:
            let operand1 = try fetch( instruction, operand: 1 )
            let operand2 = try fetch( instruction, operand: 2 )
            
            ip = operand1 == 0 ? operand2 : ip + 3
        case .lessThan:
            let operand1 = try fetch( instruction, operand: 1 )
            let operand2 = try fetch( instruction, operand: 2 )
            
            try store( instruction, operand: 3, value: operand1 < operand2 ? 1 : 0 )
            ip += 4
        case .equals:
            let operand1 = try fetch( instruction, operand: 1 )
            let operand2 = try fetch( instruction, operand: 2 )
            
            try store( instruction, operand: 3, value: operand1 == operand2 ? 1 : 0 )
            ip += 4
        case .relativeBaseOffset:
            let operand1 = try fetch( instruction, operand: 1 )
            
            relativeBase += operand1
            ip += 2
        case .halt:
            if debug { print( "\(name): halts" ) }
        }

        return nil
    }
    
    public func execute() throws -> Int? {
        while true {
            if let output = try step() { return output }
            if nextInstruction.opcode == .halt { return nil }
        }
    }

    func operandDescription( _ instruction: Instruction, operand: Int ) -> String {
        let location = memory[ ip + operand ]
        
        switch instruction.mode( operand: operand ) {
        case .position:
            return "@\(location)"
        case .immediate:
            return "\(location)"
        case .relative:
            return "*\(location)"
        }
    }
    
    func storeLocation( _ instruction: Instruction, operand: Int ) throws -> Int {
        var location = memory[ ip + operand ]
        
        switch instruction.mode( operand: operand ) {
        case .position:
            break
        case .immediate:
            throw RuntimeError( "Immediate mode invalid for address \(ip)" )
        case .relative:
            location += relativeBase
        }

        if location < 0 {
            throw RuntimeError( "Negative memory store (\(location)) at address \(ip)" )
        }
        
        return location
    }

    public func trace() throws -> String {
        let instruction = Instruction( instruction: memory[ip] )
        var line = String( format: "%04d: ", ip )
        
        func pad() -> Void {
            let column = 35
            guard line.count < column else { return }
            line.append( String( repeating: " ", count: column - line.count ) )
        }
        
        switch instruction.opcode {
        case .add:
            let operand1 = try fetch( instruction, operand: 1 )
            let operand2 = try fetch( instruction, operand: 2 )
            
            line.append( "add " )
            line.append( "\(operandDescription( instruction, operand: 1 ) ), " )
            line.append( "\(operandDescription( instruction, operand: 2 ) ), " )
            line.append( operandDescription( instruction, operand: 3 ) )
            pad()
            line.append( "\(operand1) + \(operand2) = \(operand1 + operand2) -> " )
            line.append( "\( try storeLocation( instruction, operand: 3 ) )" )
        case .multiply:
            let operand1 = try fetch( instruction, operand: 1 )
            let operand2 = try fetch( instruction, operand: 2 )
            
            line.append( "multiply " )
            line.append( "\(operandDescription( instruction, operand: 1 ) ), " )
            line.append( "\(operandDescription( instruction, operand: 2 ) ), " )
            line.append( operandDescription( instruction, operand: 3 ) )
            pad()
            line.append( "\(operand1) * \(operand2) = \(operand1 * operand2) -> " )
            line.append( "\( try storeLocation( instruction, operand: 3 ) )" )
        case .input:
            let value = inputs.first!
            line.append( "input " )
            line.append( operandDescription( instruction, operand: 1 ) )
            pad()
            line.append( "input \(value)" )
            if 0 < value && value < 256 {
                if let code = UnicodeScalar( value ) {
                    let char = Character( code )
                    
                    if char.isASCII {
                        if char != "\n" {
                            line.append( " \"\(char)\"" )
                        } else {
                            line.append( " \"\\n\"" )
                        }
                    }
                }
            }
            line.append( " -> \( try storeLocation( instruction, operand: 1 ) )" )
        case .output:
            let operand1 = try fetch( instruction, operand: 1 )
            
            line.append( "output " )
            line.append( operandDescription( instruction, operand: 1 ) )
            pad()
            line.append( "output \(operand1)" )
            if 0 < operand1 && operand1 < 256 {
                if let code = UnicodeScalar( operand1 ) {
                    let char = Character( code )
                    
                    if char.isASCII {
                        if char != "\n" {
                            line.append( " \"\(char)\"" )
                        } else {
                            line.append( " \"\\n\"" )
                        }
                    }
                }
            }
        case .jumpIfTrue:
            let operand1 = try fetch( instruction, operand: 1 )
            let operand2 = try fetch( instruction, operand: 2 )
            
            line.append( "jumpIfTrue " )
            line.append( "\(operandDescription( instruction, operand: 1 ) ), " )
            line.append( operandDescription( instruction, operand: 2 ) )
            pad()
            line.append( "jumpIfTrue \(operand1), \(operand2)" )
        case .jumpIfFalse:
            let operand1 = try fetch( instruction, operand: 1 )
            let operand2 = try fetch( instruction, operand: 2 )
            
            line.append( "jumpIfFalse " )
            line.append( "\(operandDescription( instruction, operand: 1 ) ), " )
            line.append( operandDescription( instruction, operand: 2 ) )
            pad()
            line.append( "jumpIfFalse \(operand1), \(operand2)" )
        case .lessThan:
            let operand1 = try fetch( instruction, operand: 1 )
            let operand2 = try fetch( instruction, operand: 2 )
            
            line.append( "lessThan " )
            line.append( "\(operandDescription( instruction, operand: 1 ) ), " )
            line.append( "\(operandDescription( instruction, operand: 2 ) ), " )
            line.append( operandDescription( instruction, operand: 3 ) )
            pad()
            line.append( "\(operand1) < \(operand2) => \( operand1 < operand2 ? 1 : 0 ) -> " )
            line.append( "\( try storeLocation( instruction, operand: 3 ) )" )
        case .equals:
            let operand1 = try fetch( instruction, operand: 1 )
            let operand2 = try fetch( instruction, operand: 2 )
            
            line.append( "equals " )
            line.append( "\(operandDescription( instruction, operand: 1 ) ), " )
            line.append( "\(operandDescription( instruction, operand: 2 ) ), " )
            line.append( operandDescription( instruction, operand: 3 ) )
            pad()
            line.append( "\(operand1) == \(operand2) => \( operand1 == operand2 ? 1 : 0 ) -> " )
            line.append( "\( try storeLocation( instruction, operand: 3 ) )" )
        case .relativeBaseOffset:
            let operand1 = try fetch( instruction, operand: 1 )
            
            line.append( "relativeBaseOffset " )
            line.append( operandDescription( instruction, operand: 1 ) )
            pad()
            line.append( "relativeBase = \( relativeBase + operand1 )" )
        case .halt:
            line.append( "halt" )
        }

        return line
    }
}
