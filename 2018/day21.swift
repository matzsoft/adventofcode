//
//  main.swift
//  day21
//
//  Created by Mark Johnson on 12/25/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

let input = """
#ip 4
seti 123 0 3
bani 3 456 3
eqri 3 72 3
addr 3 4 4
seti 0 0 4
seti 0 4 3
bori 3 65536 2
seti 1099159 8 3
bani 2 255 1
addr 3 1 3
bani 3 16777215 3
muli 3 65899 3
bani 3 16777215 3
gtir 256 2 1
addr 1 4 4
addi 4 1 4
seti 27 6 4
seti 0 8 1
addi 1 1 5
muli 5 256 5
gtrr 5 2 5
addr 5 4 4
addi 4 1 4
seti 25 5 4
addi 1 1 1
seti 17 1 4
setr 1 2 2
seti 7 0 4
eqrr 3 0 1
addr 1 4 4
seti 5 0 4
"""

class Instruction {
    let mnemonic: String
    let a: Int
    let b: Int
    let c: Int
    
    init( input: Substring ) {
        let instruction = input.split(separator: " ")
        
        mnemonic = String( instruction[0] )
        a = Int( instruction[1] )!
        b = Int( instruction[2] )!
        c = Int( instruction[3] )!
    }
    
    func description() -> String {
        return "\(mnemonic) \(a) \(b) \(c)"
    }
}

struct Trace {
    var lastHit: Int?
    var lastCycle: Int?
    var cycleCount: Int
}

class Program {
    var registers: [Int]
    var ip = 0
    var cycleNumber = 0
    var ipBound: Int
    var opcodes: [String:( Int, Int, Int ) -> Void]
    var memory: [Instruction]
    var cycleTraceStart = Int.max
    var cycleTraceStop = Int.max
    var ipTraceStart = Int.max
    var ipTraceStop = Int.max
    var breakPoint: Int?
    var action: (( Program ) -> Bool)?
    
    init( input: String ) {
        let lines = input.split(separator: "\n")
        
        registers = Array(repeating: 0, count: 6)
        memory = []
        ipBound = Int( lines[0].split(separator: " ")[1] )!
        
        for line in lines[1...] {
            memory.append( Instruction(input: line) )
        }
        
        opcodes = [:]
        opcodes = [
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
    }
    
    func reset() -> Void {
        ( 0 ..< registers.count ).forEach { registers[$0] = 0 }
        ip = 0
        cycleNumber = 0
        setCycleTrace( start: Int.max, stop: Int.max )
    }
    
    func cycle() -> Void {
        let instruction = memory[ip]
        let cycleTracing = cycleTraceStart <= cycleNumber && cycleNumber <= cycleTraceStop
        let ipTracing = ipTraceStart <= ip && ip <= ipTraceStop
        var initial: String = ""
        
        if cycleTracing || ipTracing {
            initial = String( format: "ip=%02d \(registers) \(memory[ip].description())", ip )
        }
        
        registers[ipBound] = ip
        opcodes[instruction.mnemonic]!( instruction.a, instruction.b, instruction.c )
        ip = registers[ipBound] + 1
        cycleNumber += 1
        
        if cycleTracing || ipTracing {
            print( initial, registers )
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
    
    func setBreakPoint( address: Int, action: @escaping ( Program) -> Bool ) -> Void {
        breakPoint = address
        self.action = action
    }
    
    func dump() -> Void {
        for ( index, value ) in program.memory.enumerated() {
            print( String(format: "%02d:", index), value.mnemonic, value.a, value.b, value.c )
        }
    }
}

let program = Program(input: input)
var seen: Set<Int> = []
var first: Int?
var last = 0

func doit( program: Program ) -> Bool {
    if first == nil {
        first = program.registers[3]
        print( "Part1:", first! )
    }
    
    if seen.contains(program.registers[3]) {
        print( "Part2:", last )
        return false
    }
    
    last = program.registers[3]
    seen.insert(last)
    return true
}

//program.dump()

//program.setIpTrace(start: 28, stop: 28)
program.setBreakPoint(address: 28, action: doit)
program.run()


