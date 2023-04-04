//
//  Assembunny.swift
//  Introduced in 2016 for day12.  Also used by day23 and day25.
//
//  Created by Mark Johnson on 4/1/21.
//

import Foundation

class Assembunny {
    enum Opcode: String, CaseIterable {
        case cpy, inc, dec, jnz, tgl, out
    }

    class Instruction {
        var mnemonic: Opcode
        let x: String
        let y: String
        
        init( input: String ) {
            let instruction = input.split(separator: " ")
            
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

    struct Trace {
        var lastHit: Int?
        var lastCycle: Int?
        var cycleCount: Int
    }

    var registers: [ String : Int ]
    var ip = 0
    var cycleNumber = 0
    var opcodes: [ Opcode : ( String, String ) -> Void ] = [:]
    var memory: [Instruction]
    var cycleTraceStart = Int.max
    var cycleTraceStop = Int.max
    var ipTraceStart = Int.max
    var ipTraceStop = Int.max
    var breakPoint: Int?
    var action: (( Assembunny ) -> Bool)?
    
    init( lines: [String] ) {
        registers = [ "a" : 0, "b" : 0, "c" : 0, "d" : 0 ]
        memory = []
        
        for line in lines {
            memory.append( Instruction( input: line ) )
        }
        
        opcodes = [
            .cpy : copy,
            .inc : increment,
            .dec : decrement,
            .jnz : jumpNonZero,
            .tgl : toggle,
            .out : out
        ]
    }
    
    func copy( x: String, y: String ) -> Void {
        guard registers[y] != nil else { return }
        
        if let value = Int( x ) {
            registers[y] = value
        } else {
            registers[y] = registers[x]
        }
    }
    
    func increment( x: String, y: String ) -> Void {
        if let value = registers[x] {
            registers[x] = value + 1
        }
    }
    
    func decrement( x: String, y: String ) -> Void {
        if let value = registers[x] {
            registers[x] = value - 1
        }
    }
    
    func jumpNonZero( x: String, y: String ) -> Void {
        var xval: Int
        var yval: Int
        
        if let value = Int( x ) {
            xval = value
        } else {
            xval = registers[x]!
        }
        
        if let value = Int( y ) {
            yval = value
        } else {
            yval = registers[y]!
        }
        
        if xval != 0 {
            ip += yval - 1
        }
    }
    
    func toggle( x: String, y: String ) -> Void {
        var address = ip
        
        if let value = Int( x ) {
            address += value
        } else {
            address += registers[x]!
        }
        
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
    
    func out( x: String, y: String ) -> Void {
        if let value = Int( x ) {
            print( "Output =", value )
        } else {
            print( "Output =", registers[x]! )
        }
    }
    
    func reset() -> Void {
        registers = [ "a" : 0, "b" : 0, "c" : 0, "d" : 0 ]
        ip = 0
        cycleNumber = 0
        setCycleTrace( start: Int.max, stop: Int.max )
    }
    
    func registerValues() -> String {
        let values = [ "a", "b", "c", "d" ].map { "\($0): \(registers[$0]!)" }
        
        return "[" + values.joined( separator: ", " ) + "]"
    }
    
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
    
    func setCycleTrace( start: Int, stop: Int ) -> Void {
        cycleTraceStart = start
        cycleTraceStop = stop
    }
    
    func setIpTrace( start: Int, stop: Int ) -> Void {
        ipTraceStart = start
        ipTraceStop = stop
    }
    
    func run() -> Void {
        while 0 <= ip && ip < memory.count {
            if let bp = breakPoint {
                if ip == bp {
                    if !action!(self) { return }
                }
            }
            cycle()
        }
    }
    
    func setBreakPoint( address: Int, action: @escaping ( Assembunny ) -> Bool ) -> Void {
        breakPoint = address
        self.action = action
    }
    
    func dump() -> Void {
        for ( index, value ) in memory.enumerated() {
            print( String(format: "%02d:", index), value.mnemonic, value.x, value.y )
        }
    }
}
