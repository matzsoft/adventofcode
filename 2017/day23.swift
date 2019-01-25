//
//  main.swift
//  day23
//
//  Created by Mark Johnson on 1/24/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let input = """
set b 65
set c b
jnz a 2
jnz 1 5
mul b 100
sub b -100000
set c b
sub c -17000
set f 1
set d 2
set e 2
set g d
mul g e
sub g b
jnz g 2
set f 0
sub e -1
set g e
sub g b
jnz g -8
sub d -1
set g d
sub g b
jnz g -13
jnz f 2
sub h -1
set g b
sub g c
jnz g 2
jnz 1 3
sub b -17
jnz 1 -23
"""

enum Opcode: String, CaseIterable {
    case set, sub, mul, jnz
}

class Instruction {
    var mnemonic: Opcode
    let x: String
    let y: String
    
    init( input: Substring ) {
        let instruction = input.split(separator: " ")
        
        mnemonic = Opcode( rawValue: String( instruction[0] ) )!
        x = String( instruction[1] )
        y = String( instruction[2] )
    }
    
    func description() -> String {
        return "\(mnemonic.rawValue) \(x) \(y)"
    }
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
    
    init( input: String, initialP: Int ) {
        let lines = input.split(separator: "\n")
        
        registers = [ "p" : initialP ]
        memory = []
        
        for line in lines {
            memory.append( Instruction(input: line) )
        }
        
        opcodes = [:]
        opcodes = [
            .set : set,
            .sub : sub,
            .mul : multiply,
            .jnz : jumpNonZero
        ]
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
        setCycleTrace( start: Int.max, stop: Int.max )
        setIpTrace( start: Int.max, stop: Int.max )
        breakPoint = nil
    }
    
    func registerValues() -> String {
        let values = [ "a", "b", "c", "d" ].map { "\($0): \(registers[$0]!)" }
        
        return "[" + values.joined( separator: ", " ) + "]"
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



let program = Program(input: input, initialP: 0)

//program.dump()
print( "Part1:", 63 * 63 )


func isPrime( _ number: Int ) -> Bool {
    return number > 1 && !( 2..<number ).contains { number % $0 == 0 }
}


func part2() -> Int {
    var h = 0
    
    for b in stride( from: 106500, through: 123500, by: 17 ) {
        if !isPrime( b ) {
            h += 1
        }
    }
    
    return h
}

print( "Part2:", part2() )
