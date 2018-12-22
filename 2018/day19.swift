//
//  main.swift
//  day19
//
//  Created by Mark Johnson on 12/18/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

let input = """
#ip 4
addi 4 16 4
seti 1 5 1
seti 1 2 2
mulr 1 2 3
eqrr 3 5 3
addr 3 4 4
addi 4 1 4
addr 1 0 0
addi 2 1 2
gtrr 2 5 3
addr 4 3 4
seti 2 7 4
addi 1 1 1
gtrr 1 5 3
addr 3 4 4
seti 1 9 4
mulr 4 4 4
addi 5 2 5
mulr 5 5 5
mulr 4 5 5
muli 5 11 5
addi 3 1 3
mulr 3 4 3
addi 3 18 3
addr 5 3 5
addr 4 0 4
seti 0 3 4
setr 4 2 3
mulr 3 4 3
addr 4 3 3
mulr 4 3 3
muli 3 14 3
mulr 3 4 3
addr 5 3 5
seti 0 4 0
seti 0 5 4
"""

class Opcode {
    let mnemonic: String
    let action: ( Int, Int, Int ) -> Void
    
    init( mnemonic: String, action: @escaping ( Int, Int, Int ) -> Void ) {
        self.mnemonic = mnemonic
        self.action = action
    }
}

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
            cycle()
        }
    }
}

let program = Program(input: input)

//program.setIpTrace(start: 1, stop: 16)
program.run()
print( "Part1: \(program.registers[0]), cycle number \(program.cycleNumber)" )

//for ( index, instruction ) in program.memory.enumerated() {
//    print( String(format: "%02d:", index), instruction.mnemonic, instruction.a, instruction.b, instruction.c )
//}

// Brute force solution to Part 2, runs for a LONG time
//program.reset()
//program.registers[0] = 1
//print( "Part2:", program.registers[0] )


// Reverse engineer the program and implement what it does efficiently yields the following.

func sumFactors( target: Int ) -> Int {
    let limit = Int( sqrt( Double( target ) ) )
    var sum = 0
    
    for candidate in 1 ... limit {
        if target % candidate == 0 {
            sum += candidate + target / candidate
        }
    }
    
    return sum
}


let part1 = 876
let part2 = 10551276

print( "Part1:", sumFactors( target: part1 ) )
print( "Part2:", sumFactors( target: part2 ) )
