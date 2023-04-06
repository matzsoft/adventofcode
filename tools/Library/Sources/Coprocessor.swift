//
//  Coprocessor.swift
//  day18
//
//  Created by Mark Johnson on 4/24/21.
//

import Foundation

public class Coprocessor {
    public enum Opcode: String, CaseIterable { case snd, set, add, sub, mul, mod, rcv, jgz, jnz }
    enum State { case running, waiting, halted }

    public class Instruction {
        public var mnemonic: Opcode
        let x: String
        public let y: String
        
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

    struct Trace {
        var lastHit: Int?
        var lastCycle: Int?
        var cycleCount: Int
    }

    var registers = [ String : Int ]()
    var ip = 0
    var cycleNumber = 0
    var opcodes: [ Opcode : ( String, String ) -> Void ]
    public var memory: [Instruction]
    var queue: [Int]
    var state: State
    var receiver: Coprocessor?
    var sendCount: Int
    var cycleTraceStart = Int.max
    var cycleTraceStop = Int.max
    var ipTraceStart = Int.max
    var ipTraceStop = Int.max
    var breakPoints = [ Int : ( ( Coprocessor ) -> Bool ) ]()
    
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
    
    func send( x: String, y: String ) -> Void {
        if let value = Int( x ) {
            receiver?.receive( message: value )
        } else if let value = registers[x] {
            receiver?.receive( message: value )
        } else {
            receiver?.receive( message: 0 )
        }
    }
    
    func set( x: String, y: String ) -> Void {
        if let value = Int( y ) {
            registers[x] = value
        } else if let value = registers[y] {
            registers[x] = value
        } else {
            registers[x] = 0
        }
    }
    
    func add( x: String, y: String ) -> Void {
        var addend2 = 0
        
        if let value = Int( y ) {
            addend2 = value
        } else if let value = registers[y] {
            addend2 = value
        }
        
        if let addend1 = registers[x] {
            registers[x] = addend1 + addend2
        } else {
            registers[x] = addend2
        }
    }
    
    func sub( x: String, y: String ) -> Void {
        var addend2 = 0
        
        if let value = Int( y ) {
            addend2 = value
        } else if let value = registers[y] {
            addend2 = value
        }
        
        if let addend1 = registers[x] {
            registers[x] = addend1 - addend2
        } else {
            registers[x] = -addend2
        }
    }
    
    func multiply( x: String, y: String ) -> Void {
        var multiplier = 0
        
        if let value = Int( y ) {
            multiplier = value
        } else if let value = registers[y] {
            multiplier = value
        }
        
        if let multiplicand = registers[x] {
            registers[x] = multiplicand * multiplier
        }
    }
    
    func modulo( x: String, y: String ) -> Void {
        var divisor = 0
        
        if let value = Int( y ) {
            divisor = value
        } else if let value = registers[y] {
            divisor = value
        }
        
        if let dividend = registers[x] {
            registers[x] = dividend % divisor
        }
    }
    
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

    func jumpGTZero( x: String, y: String ) -> Void {
        var xval = 0
        var yval = 0
        
        if let value = Int( x ) {
            xval = value
        } else if let value = registers[x] {
            xval = value
        }
        
        if let value = Int( y ) {
            yval = value
        } else if let value = registers[y] {
            yval = value
        }
        
        if xval > 0 {
            ip += yval - 1
        }
    }
    
    func jumpNonZero( x: String, y: String ) -> Void {
        var xval = 0
        var yval = 0
        
        if let value = Int( x ) {
            xval = value
        } else if let value = registers[x] {
            xval = value
        }
        
        if let value = Int( y ) {
            yval = value
        } else if let value = registers[y] {
            yval = value
        }
        
        if xval != 0 {
            ip += yval - 1
        }
    }
    
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
    
    func registerValues() -> String {
        let values = [ "a", "b", "c", "d" ].map { "\($0): \(registers[$0]!)" }
        
        return "[" + values.joined( separator: ", " ) + "]"
    }
    
    public func run() -> Void {
        while state == .running && 0 <= ip && ip < memory.count {
            if let action = breakPoints[ip] {
                if !action(self) { return }
            }
            cycle()
        }
        
        if state == .running { state = .halted }
    }
    
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
    
    func setReceiver( receiver: Coprocessor ) -> Void {
        self.receiver = receiver
    }
    
    func receive( message: Int ) -> Void {
        queue.append( message )
        if state == .waiting { state = .running }
    }
    
    func setCycleTrace( start: Int, stop: Int ) -> Void {
        cycleTraceStart = start
        cycleTraceStop = stop
    }
    
    func setIpTrace( start: Int, stop: Int ) -> Void {
        ipTraceStart = start
        ipTraceStop = stop
    }
    
    public func setBreakPoint( address: Int, action: @escaping ( Coprocessor ) -> Bool ) -> Void {
        breakPoints[address] = action
    }
    
    func dump() -> Void {
        for ( index, value ) in memory.enumerated() {
            print( String(format: "%02d:", index), value.mnemonic, value.x, value.y )
        }
    }
}
