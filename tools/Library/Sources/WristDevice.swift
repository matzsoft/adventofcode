//
//  WristDevice.swift
//  day16
//
//  Created by Mark Johnson on 5/27/21.
//

import Foundation

class WristDevice {
    class Instruction {
        let opcode: Int
        let a: Int
        let b: Int
        let c: Int
        
        init( machineCode: String ) {
            let instruction = machineCode.split(separator: " ")
            
            opcode = Int( instruction[0] )!
            a = Int( instruction[1] )!
            b = Int( instruction[2] )!
            c = Int( instruction[3] )!
        }
        
        init( assembly: String, mnemonicOpcodes: [ String: Int ] ) {
            let instruction = assembly.split(separator: " ")
            
            opcode = mnemonicOpcodes[ String( instruction[0] ) ]!
            a = Int( instruction[1] )!
            b = Int( instruction[2] )!
            c = Int( instruction[3] )!
        }
        
        func description( opcodeMnemonics: [ Int : String ] ) -> String {
            return "\(opcodeMnemonics[opcode]!) \(a) \(b) \(c)"
        }
    }

    let initialRegisters: [Int]
    var registers: [Int]
    var ip = 0
    var ipBound: Int?
    var cycleNumber = 0
    var memory = [Instruction]()
    
    var mnemonicActions = [ String : ( Int, Int, Int ) -> Void ]()
    var opcodeActions   = [ Int : ( Int, Int, Int ) -> Void ]()
    var mnemonicOpcodes = [ String : Int ]()
    var opcodeMnemonics = [ Int : String ]()

    var breakpoint: Int?
    var action:     () -> Bool = { return true }
    
    var cycleTraceStart = Int.max
    var cycleTraceStop  = Int.max
    var ipTraceStart    = Int.max
    var ipTraceStop     = Int.max

    init( machineCode: [String] ) {
        initialRegisters = [ 0, 0, 0, 0 ]
        registers = initialRegisters
        memory = machineCode.map { Instruction( machineCode: $0 ) }
        setupOpcodes()
    }
    
    init( assembly: [String] ) {
        initialRegisters = [ 0, 0, 0, 0, 0, 0 ]
        registers = initialRegisters
        ipBound = Int( assembly[0].split( separator: " " )[1] )!
        setupOpcodes()
        memory = assembly[1...].map { Instruction( assembly: $0, mnemonicOpcodes: mnemonicOpcodes ) }
    }
    
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
    
    func reset() -> Void {
        registers = initialRegisters
        ip = 0
    }
    
    func setBreakpoint( address: Int, action: @escaping () -> Bool ) -> Void {
        breakpoint = address
        self.action = action
    }
    
    func setIpTrace( start: Int, stop: Int ) -> Void {
        ipTraceStart = start
        ipTraceStop = stop
    }
    
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
    
    func run() -> Void {
        while 0 <= ip && ip < memory.count {
            if let breakpoint = breakpoint {
                if ip == breakpoint && !action() { return }
            }
            
            cycle()
        }
    }
    
    var dump: String {
        return ( ipBound == nil ? "" : "#ip \(ipBound!)\n" ) + memory.enumerated().map {
            let description = $0.element.description( opcodeMnemonics: opcodeMnemonics )
            return String( format: "%03d \(description)", $0.offset )
        }.joined( separator: "\n" )
    }
}
