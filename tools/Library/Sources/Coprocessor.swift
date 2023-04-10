//
//  Coprocessor.swift
//  day18
//
//  Created by Mark Johnson on 4/24/21.
//

import Foundation

/// Implements the Coprocessor computer used by 2017 days 18 and 23.
///
/// In addition to basic emulator functionality the following features are provided:
/// - Multiple breakpoints with an action routine associated with each
/// - Cycle tracing
/// - ip tracing
/// - A dump facility that allows printing the contents of memory, nicely formatted.
public class Coprocessor {
    public enum Opcode: String, CaseIterable { case snd, set, add, sub, mul, mod, rcv, jgz, jnz }
    enum State { case running, waiting, halted }

    /// Used to hold the instructions stored in memory.
    public class Instruction {
        public var mnemonic: Opcode
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
            case .set, .add, .sub, .mul, .mod, .jgz, .jnz:
                y = String( instruction[2] )
            case .snd, .rcv:
                y = ""
            }
        }
        
        func description() -> String {
            return "\(mnemonic.rawValue) \(x) \(y)"
        }
    }

    public var memory: [Instruction]
    var registers = [ String : Int ]()
    var ip = 0
    var cycleNumber = 0
    var opcodes: [ Opcode : ( String, String ) -> Void ]
    var queue: [Int]
    var state: State
    var receiver: Coprocessor?
    var sendCount: Int
    var cycleTraceStart = Int.max
    var cycleTraceStop = Int.max
    var ipTraceStart = Int.max
    var ipTraceStop = Int.max
    var breakPoints = [ Int : ( ( Coprocessor ) -> Bool ) ]()
    
    /// Initialize a Coprocessor from assembly code.
    /// - Parameter lines: An array of lines.  Each line should have an opcode, x, and y seperated by space.
    /// The values of x and y ahould be either integer or a register designation.
    public init( lines: [String] ) {
        memory = lines.map { Instruction( input: $0 ) }
        
        queue = []
        state = .running
        sendCount = 0
        opcodes = [:]
        opcodes = [
            .snd : send,
            .set : set,
            .add : add,
            .sub : sub,
            .mul : multiply,
            .mod : modulo,
            .rcv : receive,
            .jgz : jumpGTZero,
            .jnz : jumpNonZero
        ]
    }
    
    /// Implements the action for the snd opcode.
    ///
    /// Sends the value of x to the receiver (if defined).
    /// - Parameters:
    ///   - x: Either an integer which means send that value or a register designation
    ///   which means send the value of that register.
    ///   - y: Ignored.
    func send( x: String, y: String ) -> Void {
        receiver?.receive( message: ( Int( x ) ?? ( registers[x] ?? 0 ) ) )
    }
    
    /// Implements the action for the set opcode.
    ///
    /// Store the value denoted by y into the register designated by x.
    /// - Parameters:
    ///   - x: The register to set to the value.
    ///   - y: The value to set into the register.
    ///   Either a literal integer or the designation of the register containing the value.
    func set( x: String, y: String ) -> Void {
        registers[x] = Int( y ) ?? ( registers[y] ?? 0 )
    }
    
    /// Implements the action for the add opcode.
    ///
    /// Store the sum of register x and the value denoted by y into the register designated by x.
    /// - Parameters:
    ///   - x: The register used to get the first addend and to store the sum.
    ///   - y: The value for the second addend.
    func add( x: String, y: String ) -> Void {
        registers[ x, default: 0 ] += Int( y ) ?? ( registers[y] ?? 0 )
    }
    
    /// Implements the action for the sub opcode.
    ///
    /// Store the difference of register x and the value denoted by y into the register designated by x.
    /// - Parameters:
    ///   - x: The register used to get the minuend and to store the difference.
    ///   - y: The value for the subtrahend.
    func sub( x: String, y: String ) -> Void {
        registers[ x, default: 0 ] -= Int( y ) ?? ( registers[y] ?? 0 )
    }
    
    /// Implements the action for the mul opcode.
    ///
    /// Store the product of register x and the value denoted by y into the register designated by x.
    /// - Parameters:
    ///   - x: The register used to get the multiplicand and to store the product.
    ///   - y: The value for the multiplier.
    func multiply( x: String, y: String ) -> Void {
        registers[ x, default: 0 ] *= Int( y ) ?? ( registers[y] ?? 0 )
    }
    
    /// Implements the action for the mod opcode.
    ///
    /// Store the remainder of register x divided by the value denoted by y
    /// into the register designated by x.
    /// - Parameters:
    ///   - x: The register used to get the dividend and to store the remainder.
    ///   - y: The value for the divisor.
    func modulo( x: String, y: String ) -> Void {
        registers[ x, default: 0 ] %= Int( y ) ?? ( registers[y] ?? 0 )
    }
    
    /// Implements the action for the rcv opcode.
    ///
    /// Remove the first entry in the input queue and store it into the register designated by x.
    ///
    /// If the input queue is empty, enter the waiting state and modify the ip so that
    /// the rcv instruction will be executed when the next value is entere into the input queue.
    /// - Parameters:
    ///   - x: The register used to store the received value.
    ///   - y: Ignored.
    func receive( x: String, y: String ) -> Void {
        if let regValue = registers[x], regValue != 0 {
            if let value = queue.first {
                queue.removeFirst()
                registers[x] = value
            } else {
                state = .waiting
                ip -= 1
                cycleNumber -= 1
            }
        }
    }

    /// Implements the action for the jgz opcode.
    ///
    /// Relative jump by the offset of the value of y if the value of x is greater than zero.
    /// - Parameters:
    ///   - x: The value to test for greater than zero.
    ///   - y: The relative jump offset if x > 0.
    func jumpGTZero( x: String, y: String ) -> Void {
        if ( Int( x ) ?? ( registers[x] ?? 0 ) ) > 0 {
            ip += ( Int( y ) ?? ( registers[y] ?? 0 ) ) - 1
        }
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
    
    /// Resets the Coprocessor to its initial state.
    func reset() -> Void {
        registers = [:]
        ip = 0
        cycleNumber = 0
        queue = []
        state = .running
        sendCount = 0
        setCycleTrace( start: Int.max, stop: Int.max )
        setIpTrace( start: Int.max, stop: Int.max )
        breakPoints = [:]
    }
    
    // Returns a string descriptive of the values in the registers.
    func registerValues() -> String {
        let values = [ "a", "b", "c", "d" ].map { "\($0): \(registers[$0]!)" }
        
        return "[" + values.joined( separator: ", " ) + "]"
    }
    
    /// Runs the Coprocessor until it must stop.
    /// - The Coprocessor must stop if it is not in the running state.
    /// - A breakpoint that returns false from its action stops the Coprossor but
    /// leaves it in the running state.
    /// - If the ip points outside the memory space then the Coprocessor stops in the halted state.
    /// - When a rcv opcode is executed and the input queue is empty,
    ///  the Coprocessor stops in the waiting state.
    public func run() -> Void {
        while state == .running && 0 <= ip && ip < memory.count {
            if let action = breakPoints[ip] {
                if !action(self) { return }
            }
            cycle()
        }
        
        if state == .running { state = .halted }
    }
    
    /// Executes a single instruction by the Coprocessor.
    /// - Does nothing unless the Coprocessor is in the running state
    /// - Handles ip tracing
    /// - Handles cycle tracing
    /// - Updates the ip and cycle count
    func cycle() -> Void {
        guard state == .running else { return }
        
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
    
    /// Called to allow this Coprocessor to send messages to another.
    /// - Parameter receiver: The Coprocessor that will receive messages from this one.
    func setReceiver( receiver: Coprocessor ) -> Void {
        self.receiver = receiver
    }
    
    /// Called when another Coprocessor sends a message to this one.
    ///
    /// The message is added to the input queue.  If this Coprocessor is in the waiting state
    /// it will be switched to the running state.
    /// - Parameter message: The message from the other Coprocessor.
    func receive( message: Int ) -> Void {
        queue.append( message )
        if state == .waiting { state = .running }
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
    
    /// Adds a breakpoint for the Coprocessor.
    ///
    /// The Coprocessor will stop and execute the action **before** executinng the instruction
    /// at the specified address.
    /// - Parameters:
    ///   - address: The address to execute the action before.
    ///   - action: A closure that returns a Bool - true to keep running, false to stop the Coprocessor.
    public func setBreakPoint( address: Int, action: @escaping ( Coprocessor ) -> Bool ) -> Void {
        breakPoints[address] = action
    }
    
    /// Returns a disassembly of the Coprocessor device memory.
    func dump() -> Void {
        for ( index, value ) in memory.enumerated() {
            print( String( format: "%02d:", index ), value.mnemonic, value.x, value.y )
        }
    }
}
