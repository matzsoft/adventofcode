//
//  Assembunny.swift
//  Introduced in 2016 for day12.  Also used by day23 and day25.
//
//  Created by Mark Johnson on 4/1/21.
//

import Foundation

/// Implements the Assembunny computer used by 2016 days 12, 23, and 25.
///
/// In addition to basic emulator functionality the following features are provided:
/// - A single breakpoints with an action routine associated
/// - Cycle tracing
/// - ip tracing
/// - A dump facility that allows printing the contents of memory, nicely formatted.
public class Assembunny {
    enum Opcode: String, CaseIterable { case cpy, inc, dec, jnz, tgl, out }

    /// Used to hold the instructions stored in memory.
    public class Instruction {
        var mnemonic: Opcode
        public let x: String
        public let y: String
        
        /// Initialize an instruction from assembly code.
        /// - Parameter input: A String consisting of opcode, x, and y seperated by space.
        /// The values of x and y ahould be either integer or a register designation.
        init( input: String ) {
            let instruction = input.split( separator: " " )
            
            mnemonic = Opcode( rawValue: String( instruction[0] ) )!
            x = String( instruction[1] )
            switch mnemonic {
            case .cpy, .jnz:
                y = String( instruction[2] )
            case .inc, .dec, .tgl, .out:
                y = ""
            }
        }
        
        func description() -> String {
            return "\(mnemonic.rawValue) \(x) \(y)"
        }
    }

    public var registers: [ String : Int ]
    public var memory: [Instruction]
    var ip = 0
    var cycleNumber = 0
    var opcodes: [ Opcode : ( String, String ) -> Void ] = [:]
    var cycleTraceStart = Int.max
    var cycleTraceStop = Int.max
    var ipTraceStart = Int.max
    var ipTraceStop = Int.max
    var breakPoint: Int?
    var action: (( Assembunny ) -> Bool)?
    
    /// Initialize an Assembunny from assembly code.
    /// - Parameter lines: An array of lines.  Each line should have an opcode, x, and y seperated by space.
    /// The values of x and y ahould be either integer or a register designation.
    public init( lines: [String] ) {
        registers = [ "a" : 0, "b" : 0, "c" : 0, "d" : 0 ]
        memory = lines.map { Instruction( input: $0 ) }
        
        opcodes = [
            .cpy : copy,
            .inc : increment,
            .dec : decrement,
            .jnz : jumpNonZero,
            .tgl : toggle,
            .out : out
        ]
    }
    
    /// Implements the action for the cpy opcode.
    ///
    /// Store the value denoted by x into the register designated by y.
    /// - Parameters:
    ///   - x: The value to set into the register.
    ///   Either a literal integer or the designation of the register containing the value.
    ///   - y: The register to set to the value.
    func copy( x: String, y: String ) -> Void {
        guard registers[y] != nil else { return }
        registers[y] = Int( x ) ?? ( registers[x] ?? 0 )
    }
    
    /// Implements the action for the inc opcode.
    ///
    /// Increments register x by 1.
    /// - Parameters:
    ///   - x: The register to increment.
    ///   - y: Ignored.
    func increment( x: String, y: String ) -> Void {
        registers[ x, default: 0 ] += 1
    }
    
    /// Implements the action for the dec opcode.
    ///
    /// Decrements register x by 1.
    /// - Parameters:
    ///   - x: The register to decrement.
    ///   - y: Ignored.
    func decrement( x: String, y: String ) -> Void {
        registers[ x, default: 0 ] -= 1
    }
    
    /// Implements the action for the jnz opcode.
    ///
    /// Relative jump by the offset of the value of y if the value of x is not equal to zero.
    /// - Parameters:
    ///   - x: The value to test for not equal to zero.
    ///   - y: The relative jump offset if x != 0.
    func jumpNonZero( x: String, y: String ) -> Void {
        if ( Int( x ) ?? ( registers[x] ?? 0 ) ) != 0 {
            ip += ( Int( y ) ?? ( registers[y] ?? 0 ) ) - 1
        }
    }
    
    /// Implements the action for the tgl opcode.
    ///
    /// Modify the opcode of the instruction at the relative offset of the value of x.
    /// - Parameters:
    ///   - x: The relative offset of the instruction that will have its opcode toggled.
    ///   - y: Ignored.
    func toggle( x: String, y: String ) -> Void {
        let address = ip + ( Int( x ) ?? ( registers[x] ?? 0 ) )
        
        if 0 <= address && address < memory.count {
            switch memory[address].mnemonic {
            case .inc:
                memory[address].mnemonic = .dec
            case .dec, .tgl, .out:
                memory[address].mnemonic = .inc
            case .cpy:
                memory[address].mnemonic = .jnz
            case .jnz:
                memory[address].mnemonic = .cpy
            }
        }
    }
    
    /// Implements the action for the out opcode.
    ///
    /// Transmits the value of x. In this case, just print it out.
    /// - Parameters:
    ///   - x: The value to transmit.
    ///   - y: Ignored.
    func out( x: String, y: String ) -> Void {
        print( "Output =", Int( x ) ?? ( registers[x] ?? 0 ) )
    }
    
    /// Resets the Assembunny to its initial state.
    func reset() -> Void {
        registers = [ "a" : 0, "b" : 0, "c" : 0, "d" : 0 ]
        ip = 0
        cycleNumber = 0
        setCycleTrace( start: Int.max, stop: Int.max )
    }
    
    // Returns a string descriptive of the values in the registers.
    func registerValues() -> String {
        let values = [ "a", "b", "c", "d" ].map { "\($0): \(registers[$0]!)" }
        
        return "[" + values.joined( separator: ", " ) + "]"
    }
    
    /// Executes a single instruction by the Assembunny.
    /// - Handles ip tracing
    /// - Handles cycle tracing
    /// - Updates the ip and cycle count
    func cycle() -> Void {
        let instruction = memory[ip]
        let cycleTracing = cycleTraceStart <= cycleNumber && cycleNumber <= cycleTraceStop
        let ipTracing = ipTraceStart <= ip && ip <= ipTraceStop
        var initial: String = ""
        
        if cycleTracing || ipTracing {
            initial = String( format: "ip=%02d \(registerValues()) \(memory[ip].description())", ip )
        }
        
        opcodes[instruction.mnemonic]!( instruction.x, instruction.y )
        ip += 1
        cycleNumber += 1
        
        if cycleTracing || ipTracing {
            print( initial, registerValues() )
        }
    }
    
    /// Sets up tracing when the cycle count is within the specified range.
    /// - Parameters:
    ///   - start: The cycle count when tracing should start.
    ///   - stop: The cycle count when tracing should end.
    func setCycleTrace( start: Int, stop: Int ) -> Void {
        cycleTraceStart = start
        cycleTraceStop = stop
    }
    
    /// Sets up tracing when the ip falls within the specified range.
    /// - Parameters:
    ///   - start: The beginning of desired tracing range.
    ///   - stop: The end of desired tracing range.
    func setIpTrace( start: Int, stop: Int ) -> Void {
        ipTraceStart = start
        ipTraceStop = stop
    }
    
    /// Runs the Assembunny until it must stop.
    /// - If the breakpoint returns false from its action the Assembunny stops.
    /// - If the ip points outside the memory space then the Assembunny stops.
    public func run() -> Void {
        while 0 <= ip && ip < memory.count {
            if let bp = breakPoint {
                if ip == bp {
                    if !action!(self) { return }
                }
            }
            cycle()
        }
    }
    
    /// Sets the breakpoint for the Assembunny.
    ///
    /// The Assembunny will stop and execute the action **before** executinng the instruction
    /// at the specified address.
    /// - Parameters:
    ///   - address: The address to execute the action before.
    ///   - action: A closure that returns a Bool - true to keep running, false to stop the Assembunny.
    func setBreakPoint( address: Int, action: @escaping ( Assembunny ) -> Bool ) -> Void {
        breakPoint = address
        self.action = action
    }
    
    /// Returns a disassembly of the Coprocessor device memory.
    func dump() -> Void {
        for ( index, value ) in memory.enumerated() {
            print( String(format: "%02d:", index), value.mnemonic, value.x, value.y )
        }
    }
}
