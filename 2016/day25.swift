//
//  main.swift
//  day25
//
//  Created by Mark Johnson on 1/9/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let input = """
cpy a d
cpy 14 c
cpy 182 b
inc d
dec b
jnz b -2
dec c
jnz c -5
cpy d a
jnz 0 0
cpy a b
cpy 0 a
cpy 2 c
jnz b 2
jnz 1 6
dec b
dec c
jnz c -4
inc a
jnz 1 -7
cpy 2 b
jnz c 2
jnz 1 4
dec b
dec c
jnz 1 -4
jnz 0 0
out b
jnz a -19
jnz 1 -21
"""

enum Opcode: String, CaseIterable {
    case cpy, inc, dec, jnz, tgl, out
}

class Instruction {
    var mnemonic: Opcode
    let x: String
    let y: String
    
    init( input: Substring ) {
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

class Program {
    var registers: [ String : Int ]
    var ip = 0
    var cycleNumber = 0
    var opcodes: [ Opcode : ( String, String ) -> Void ]
    var memory: [Instruction]
    var cycleTraceStart = Int.max
    var cycleTraceStop = Int.max
    var ipTraceStart = Int.max
    var ipTraceStop = Int.max
    var breakPoint: Int?
    var action: (( Program ) -> Bool)?
    
    init( input: String ) {
        let lines = input.split(separator: "\n")
        
        registers = [ "a" : 0, "b" : 0, "c" : 0, "d" : 0 ]
        memory = []
        
        for line in lines {
            memory.append( Instruction(input: line) )
        }
        
        opcodes = [:]
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
    
    func out( x: String, y: String ) -> Void {
        if let value = Int( x ) {
            print( "Output =", value )
        } else {
            print( "Output =", registers[x]! )
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
    
    func setBreakPoint( address: Int, action: @escaping ( Program ) -> Bool ) -> Void {
        breakPoint = address
        self.action = action
    }
    
    func dump() -> Void {
        for ( index, value ) in memory.enumerated() {
            print( String(format: "%02d:", index), value.mnemonic, value.x, value.y )
        }
    }
}

func part2( a: Int ) -> Int {
    var factorial = a
    
    for number in 2 ..< a {
        factorial *= number
    }
    
    return factorial + 73 * 79
}


func decompiled( a: Int ) -> Void {
    var a = a
    var b = 0
    let d = a + 14 * 182
    
    while true {
        a = d
        while a != 0 {
            b = a % 2
            a /= 2
        }
        print( "Output = ", b )
    }
}

func part1() -> Int {
    let minimum = 14 * 182
    var current = 1
    var count = 1
    
    while current < minimum || count % 2 == 1 {
        current *= 2
        count += 1
        if count % 2 == 1 { current += 1 }
    }
    
    return current - minimum
}




let program = Program(input: input)

//program.dump()
//program.setIpTrace(start: 8, stop: 10)
//program.registers["a"] = 0
//program.run()

print( "Part1:", part1() )

