//
//  Intcode.swift
//  day05
//
//  Created by Mark Johnson on 5/31/21.
//

import Foundation

/// Implements the Intcode computer used by many problems in 2019.
///
/// The instruction set is a little different
/// - Memory is just an array of integers
/// - Instruction occupy multiple memory locations
/// - Instruction length varies by the numer of operands
/// - There are no registers, data is stored in memory
///
/// The emulator provides support for tracing and instruction inspection.
public class Intcode {
    /// Breaks down a memory location into an opcode and modes for (potentially) 3 operands.
    public struct Instruction {
        enum Mode: Int { case  position = 0, immediate = 1, relative = 2 }
        public enum Opcode: Int {
            case add = 1, multiply = 2, input = 3, output = 4
            case jumpIfTrue = 5, jumpIfFalse = 6, lessThan = 7, equals = 8
            case relativeBaseOffset = 9, halt = 99
        }
        
        public let opcode: Opcode
        let modes: [Mode]
        
        /// Initializes an Instruction from an integer.
        /// - Parameter instruction: An integer representing the first word of an instruction.
        init( instruction: Int ) {
            opcode = Opcode( rawValue: instruction % 100 )!
            modes = [
                Mode( rawValue: instruction /   100 % 10 )!,
                Mode( rawValue: instruction /  1000 % 10 )!,
                Mode( rawValue: instruction / 10000 % 10 )!,
            ]
        }
        
        /// Returns the mode for one of the operands.
        /// - Parameter operand: The desired operand, a number from 1 to 3.
        /// - Returns: The mode of the selected operand.
        func mode( operand: Int ) -> Mode {
            return modes[ operand - 1 ]
        }
    }

    let name: String
    var relativeBase: Int
    var debug = false

    public var ip: Int
    public var memory: [Int]
    public var inputs: [Int]
    
    /// Returns the next instruction to be executed.
    public var nextInstruction: Instruction {
        return Instruction( instruction: memory[ip] )
    }
    
    /// Initializes an Intcode computer from an array of integers.
    /// - Parameters:
    ///   - name: The name used to identify this particular Intcode computer.
    ///   - memory: An array of integers to be used as the initial memory of the new Intcode computer.
    public init( name: String, memory: [Int] ) {
        self.name = name
        ip = 0
        relativeBase = 0
        self.memory = memory
        self.inputs = []
    }
    
    /// Initializes an Intcode computer as a copy of another.
    /// - Parameter other: The other Intcode computer to copy.
    public init( from other: Intcode ) {
        name = other.name
        ip = other.ip
        relativeBase = other.relativeBase
        memory = other.memory
        inputs = other.inputs
        debug = other.debug
    }
    
    /// Fetches the value of an operand based on the mode.
    /// - position mode - the operand contains a memory address to fetch the value from.
    /// - immediate mode - the operand is the desired value.
    /// - relative mode - the operand contains an offset from the relative base
    /// for the memory address to fetch the value from.
    ///
    /// Attempts to fetch memory from an address less than zero produce an error.
    /// Attempts to fetch memory from an address beyond the current end of memory return zero.
    /// - Parameters:
    ///   - instruction: The instruction used to get the base of the operand.
    ///   - operand: The operand number.  Either 1, 2, or 3.
    /// - Returns: The fetched value.
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
    
    /// Store a value into memory at the address determined by the mode of the operand.
    /// - position mode - The operand contains the memory address to store into.
    /// - immediate mode - This is not permitted for a store operation and generates an error.
    /// - relative mode - the operand contains an offset from the relative base
    /// for the memory address to store the value into.
    ///
    /// Attempts to store memory at an address less than zero produce an error.
    /// Attempts to store memory at an address beyond the current end of memory expands
    /// the memory with zero values up to that address and then stores the value.
    /// - Parameters:
    ///   - instruction: The instruction used to get the base of the operand.
    ///   - operand: The operand number.  Either 1, 2, or 3.
    ///   - value: The integer value to be stored.
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
    
    /// Executes the instruction pointed to by ip.
    ///
    /// Additionally ip is updated to point to the next instruction to be executed.
    /// - Returns: All instructions return nil except out which returns the value to be output.
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
    
    /// Execute the xxx until the next output or halt instruction.
    /// - An output instruction will return the value output.
    /// - A halt instruction will return nil.
    public func execute() throws -> Int? {
        while true {
            if let output = try step() { return output }
            if nextInstruction.opcode == .halt { return nil }
        }
    }
    
    /// Provides a description (disassembly) of an operand value.
    ///
    /// Returns a string with a prefix and the operand value.
    /// - position mode - the prefix is @
    /// - immediate mode - no prefix
    /// - relative mode - the prefix is *
    /// - Parameters:
    ///   - instruction: The instruction used to get the mode.
    ///   - operand: The operand number - either 1, 2, or 3.
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
    
    /// Computes the store location (address) for a given instruction and operand.
    /// - position mode - the address is the value of the operand.
    /// - immediate mode - this is invalid and produces an error.
    /// - relative mode - the address is the value of the operand added to the relative base.
    /// - Parameters:
    ///   - instruction: The instruction used to get the mode.
    ///   - operand: The operand number. Either 1, 2, or 3.
    /// - Returns: The address that would be stored into.
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
    
    /// Returns a description of the operation of the next instruction to be executed.
    ///
    /// The description includes
    /// - The address of the instruction
    /// - A disassembly of the instruction
    /// - The actual values of the operands.
    /// - The actual values stored and where if any.
    ///
    /// Note that the ip is **not** updated.
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
