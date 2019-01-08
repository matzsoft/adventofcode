//
//  main.swift
//  day23
//
//  Created by Mark Johnson on 1/7/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let input = """
cpy a b
dec b
cpy a d
cpy 0 a
cpy b c
inc a
dec c
jnz c -2
dec d
jnz d -5
dec b
cpy b c
cpy c d
dec d
inc c
jnz d -2
tgl c
cpy -16 c
jnz 1 c
cpy 73 c
jnz 79 d
inc a
inc d
jnz d -2
inc c
jnz c -5
"""

enum Opcode: String, CaseIterable {
    case cpy, inc, dec, jnz, tgl
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
        case .inc, .dec, .tgl:
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
            .tgl : toggle
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
            case .dec, .tgl:
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




let program = Program(input: input)

//program.dump()
//program.setIpTrace(start: 16, stop: 16)
//program.setBreakPoint(address: 17, action: { _ in return false } )
program.registers["a"] = 7
program.run()
print( "Part1:", program.registers["a"]! )

print( "Part1:", part2(a: 7) )
print( "Part2:", part2(a: 12) )
