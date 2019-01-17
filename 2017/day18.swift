//
//  main.swift
//  day18
//
//  Created by Mark Johnson on 1/15/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let input = """
set i 31
set a 1
mul p 17
jgz p p
mul a 2
add i -1
jgz i -2
add a -1
set i 127
set p 618
mul p 8505
mod p a
mul p 129749
add p 12345
mod p a
set b p
mod b 10000
snd b
add i -1
jgz i -9
jgz a 3
rcv b
jgz b -1
set f 0
set i 126
rcv a
rcv b
set p a
mul p -1
add p b
jgz p 4
snd a
set a b
jgz 1 3
snd b
set f 1
add i -1
jgz i -11
snd a
jgz f -16
jgz a -19
"""

enum Opcode: String, CaseIterable {
    case snd, set, add, mul, mod, rcv, jgz
}

enum State {
    case running, waiting, halted
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
        case .set, .add, .mul, .mod, .jgz:
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

class Program {
    var registers: [ String : Int ]
    var ip = 0
    var cycleNumber = 0
    var opcodes: [ Opcode : ( String, String ) -> Void ]
    var memory: [Instruction]
    var queue: [Int]
    var state: State
    var receiver: Program?
    var sendCount: Int
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
        
        queue = []
        state = .running
        sendCount = 0
        opcodes = [:]
        opcodes = [
            .snd : send,
            .set : set,
            .add : add,
            .mul : multiply,
            .mod : modulo,
            .rcv : receive,
            .jgz : jumpNonZero
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
        if let value = queue.first {
            queue.removeFirst()
            registers[x] = value
        } else {
            state = .waiting
            ip -= 1
            cycleNumber -= 1
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
        breakPoint = nil
    }
    
    func registerValues() -> String {
        let values = [ "a", "b", "c", "d" ].map { "\($0): \(registers[$0]!)" }
        
        return "[" + values.joined( separator: ", " ) + "]"
    }
    
    func run() -> Void {
        while state == .running && 0 <= ip && ip < memory.count {
            if let bp = breakPoint {
                if ip == bp {
                    if !action!(self) { return }
                }
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
    
    func setReceiver( receiver: Program ) -> Void {
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




func initialize() -> [Int] {
    let a = Int( pow( 2.0, 31.0 ) ) - 1
    var p = 618
    var results: [Int] = []
    
    for _ in 1 ... 127 {
        p = ( ( p * 8505 ) % a * 129749 + 12345 ) % a
        results.append( p % 10000 )
    }
    
    return results
}

func bubbleSort( numbers: [Int] ) -> Int {
    var results = numbers
    var passes = 0
    var f = false
    
    repeat {
        passes += 1
        f = false
        for index in 0 ..< results.count - 1 {
            if results[index] < results[ index + 1 ] {
                ( results[index], results[ index + 1 ] ) = ( results[ index + 1 ], results[index] )
                f = true
            }
        }
    } while f
    
    return passes
}



let numbers = initialize()
let passes = bubbleSort( numbers: numbers )

print( "Part1:", numbers.last! )
print( "Part2:", ( passes + 1 ) / 2 * numbers.count )




// The following brute force, interpretive solution requires days (or more) to run.
// I only save because of the interpreter enhancements.

//let program0 = Program( input: input, initialP: 0 )
//let program1 = Program( input: input, initialP: 1 )
//
//program0.setReceiver( receiver: program1 )
//program1.setReceiver( receiver: program0 )
//
////program0.dump()
//
//while program0.state == .running || program1.state == .running {
//    program0.run()
//    program1.run()
//}
//
//print( "Part2:", program1.sendCount )
