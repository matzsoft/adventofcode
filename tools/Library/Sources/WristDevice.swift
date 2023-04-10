//
//  WristDevice.swift
//  day16
//
//  Created by Mark Johnson on 5/27/21.
//

import Foundation

/// Implements the WristDevice computer used by 2018 days 16, 19, and 21.
///
/// This is a fairly simple emulator with a few additional features to aid in solving the problems.
/// - A single breakpoint can be set with a closure as an action routine.
/// - A trace can be produced whenever the ip is withing a given range.
/// - A trace can be produced whenever the cycle count is within a given range.
/// - A dump of the machine status can be produced.
///
/// Note that the emulator is set up to allow for the numeric value of the opcodes to be flexible for day 16.
public class WristDevice {
    /// Defines the instructions stored in the WristDevice memory.
    public class Instruction {
        public let opcode: Int
        public let a: Int
        public let b: Int
        public let c: Int
        
        /// Creates a WristDevice instruction from machine code.
        /// - Parameter machineCode: A string of 4 integers, seperated by space.
        public init( machineCode: String ) {
            let instruction = machineCode.split( separator: " " )
            
            opcode = Int( instruction[0] )!
            a = Int( instruction[1] )!
            b = Int( instruction[2] )!
            c = Int( instruction[3] )!
        }
        
        /// Creates a WristDevice instruction from assembly code.
        /// - Parameters:
        ///   - assembly: A string with an opcode mnemonic followed by 3 integers seperated by space.
        ///   - mnemonicOpcodes: A dictionary that maps an instruction mnemonic to an integer opcode.
        init( assembly: String, mnemonicOpcodes: [ String: Int ] ) {
            let instruction = assembly.split( separator: " " )
            
            opcode = mnemonicOpcodes[ String( instruction[0] ) ]!
            a = Int( instruction[1] )!
            b = Int( instruction[2] )!
            c = Int( instruction[3] )!
        }
        
        /// Generates a crude disassembly of an instruction.
        /// - Parameter opcodeMnemonics: A dictionary that maps from an integer opcode
        /// to an instruction mnemonic.
        /// - Returns: A string with an opcode mnemonic followed by 3 integers seperated by space.
        func description( opcodeMnemonics: [ Int : String ] ) -> String {
            return "\(opcodeMnemonics[opcode]!) \(a) \(b) \(c)"
        }
    }

    public var registers: [Int]
    public var memory = [Instruction]()
    public var mnemonicActions = [ String : ( Int, Int, Int ) -> Void ]()
    public var opcodeActions   = [ Int : ( Int, Int, Int ) -> Void ]()
    public var opcodeMnemonics = [ Int : String ]()
    
    let initialRegisters: [Int]
    var ip = 0
    var ipBound: Int?
    var cycleNumber = 0
    var mnemonicOpcodes = [ String : Int ]()

    var breakpoint: Int?
    var action:     () -> Bool = { return true }
    
    var cycleTraceStart = Int.max
    var cycleTraceStop  = Int.max
    var ipTraceStart    = Int.max
    var ipTraceStop     = Int.max
    
    /// Creates a WristDevice from machine code.
    /// - Parameter machineCode: An array of lines.  Each line is a string of 4 integers, seperated by space.
    public init( machineCode: [String] ) {
        initialRegisters = [ 0, 0, 0, 0 ]
        registers = initialRegisters
        memory = machineCode.map { Instruction( machineCode: $0 ) }
        setupOpcodes()
    }
    
    /// Creates a WristDevice from assembly code.
    /// - Parameter assembly: An array of lines.  Each line is a string with an opcode mnemonic
    /// followed by 3 integers seperated by space.
    public init( assembly: [String] ) {
        initialRegisters = [ 0, 0, 0, 0, 0, 0 ]
        registers = initialRegisters
        ipBound = Int( assembly[0].split( separator: " " )[1] )!
        setupOpcodes()
        memory = assembly[1...].map { Instruction( assembly: $0, mnemonicOpcodes: mnemonicOpcodes ) }
    }
    
    /// Used internally to set up the tables that define instruction mnemonics, opcodes,
    /// and instruction actions.
    func setupOpcodes() -> Void {
        mnemonicActions = [
            "addr" : { self.registers[$2] = self.registers[$0] + self.registers[$1] },
            "addi" : { self.registers[$2] = self.registers[$0] + $1 },
            "mulr" : { self.registers[$2] = self.registers[$0] * self.registers[$1] },
            "muli" : { self.registers[$2] = self.registers[$0] * $1 },
            "banr" : { self.registers[$2] = self.registers[$0] & self.registers[$1] },
            "bani" : { self.registers[$2] = self.registers[$0] & $1 },
            "borr" : { self.registers[$2] = self.registers[$0] | self.registers[$1] },
            "bori" : { self.registers[$2] = self.registers[$0] | $1 },
            "setr" : { self.registers[$2] = self.registers[$0] },
            "seti" : { self.registers[$2] = $0 },
            "gtir" : { self.registers[$2] = $0 > self.registers[$1] ? 1 : 0 },
            "gtri" : { self.registers[$2] = self.registers[$0] > $1 ? 1 : 0 },
            "gtrr" : { self.registers[$2] = self.registers[$0] > self.registers[$1] ? 1 : 0 },
            "eqir" : { self.registers[$2] = $0 == self.registers[$1] ? 1 : 0 },
            "eqri" : { self.registers[$2] = self.registers[$0] == $1 ? 1 : 0 },
            "eqrr" : { self.registers[$2] = self.registers[$0] == self.registers[$1] ? 1 : 0 },
        ]
        opcodeActions = Dictionary(
            uniqueKeysWithValues: mnemonicActions.values.enumerated().map { ( $0.offset, $0.element ) } )
        mnemonicOpcodes = Dictionary(
            uniqueKeysWithValues: mnemonicActions.keys.enumerated().map { ( $0.element, $0.offset ) } )
        opcodeMnemonics = Dictionary(
            uniqueKeysWithValues: mnemonicActions.keys.enumerated().map { ( $0.offset, $0.element ) } )
    }
    
    /// Resets a WristDevice to its initial state, i.e all registers 0 and ip 0.
    public func reset() -> Void {
        registers = initialRegisters
        ip = 0
    }
    
    /// Sets a breakpoint for the WristDevice.
    ///
    /// The WristDevice will stop and execute the action **before** executinng the instruction
    /// at the specified address.
    /// - Parameters:
    ///   - address: The address to execute the action before.
    ///   - action: A closure that returns a Bool - true to keep running, false to halt the WristDevice.
    public func setBreakpoint( address: Int, action: @escaping () -> Bool ) -> Void {
        breakpoint = address
        self.action = action
    }
    
    /// Setup ip tracing for the WristDevice.
    ///
    /// Produce an execution trace whenever the ip is within the specified range.
    /// - Parameters:
    ///   - start: Address of the beginning of the trace range.
    ///   - stop: Address of the end of the trace range.
    func setIpTrace( start: Int, stop: Int ) -> Void {
        ipTraceStart = start
        ipTraceStop = stop
    }
    
    /// Executes the current instruction on the WristDevice.
    ///
    /// Handles
    /// - The ip bound behavior
    /// - Cycle tracing
    /// - ip tracing
    /// - Execution of the instruction
    /// - ip update
    /// - Cycle count update
    func cycle() -> Void {
        let instruction = memory[ip]
        let cycleTracing = cycleTraceStart <= cycleNumber && cycleNumber <= cycleTraceStop
        let ipTracing = ipTraceStart <= ip && ip <= ipTraceStop
        var initial: String = ""
        
        if cycleTracing || ipTracing {
            let description = memory[ip].description( opcodeMnemonics: opcodeMnemonics )
            initial = String( format: "ip=%03d \(registers) \(description)", ip )
        }

        if let ipBound = ipBound { registers[ipBound] = ip }
        opcodeActions[instruction.opcode]!( instruction.a, instruction.b, instruction.c )
        if let ipBound = ipBound { ip = registers[ipBound] }
        ip += 1
        cycleNumber += 1

        if cycleTracing || ipTracing {
            print( initial, registers )
        }
    }
    
    /// Runs the WristDevice until a halt condition occurs.
    ///
    /// A halt occurs when
    /// - The ip is set to outside the range of memory
    /// - A breakpoint is hit and the action returns false
    public func run() -> Void {
        while 0 <= ip && ip < memory.count {
            if let breakpoint = breakpoint {
                if ip == breakpoint && !action() { return }
            }
            
            cycle()
        }
    }
    
    /// Returns a disassembly of the WristCode device memory including the #ip directive if there is one.
    var dump: String {
        return ( ipBound == nil ? "" : "#ip \(ipBound!)\n" ) + memory.enumerated().map {
            let description = $0.element.description( opcodeMnemonics: opcodeMnemonics )
            return String( format: "%03d \(description)", $0.offset )
        }.joined( separator: "\n" )
    }
}
