//
//  main.swift
//  day23
//
//  Created by Mark Johnson on 12/22/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

extension String: Error {}

enum Opcode: Int {
    case add                = 1
    case multiply           = 2
    case input              = 3
    case output             = 4
    case jumpIfTrue         = 5
    case jumpIfFalse        = 6
    case lessThan           = 7
    case equals             = 8
    case relativeBaseOffset = 9
    case halt               = 99
}

enum ParameterMode: Int {
    case position  = 0
    case immediate = 1
    case relative  = 2
}

struct Instruction {
    let opcode: Opcode
    let modes: [ParameterMode]

    init( instruction: Int ) {
        opcode = Opcode( rawValue: instruction % 100 )!
        modes = [
            ParameterMode( rawValue: instruction /   100 % 10 )!,
            ParameterMode( rawValue: instruction /  1000 % 10 )!,
            ParameterMode( rawValue: instruction / 10000 % 10 )!,
        ]
    }
    
    func mode( operand: Int ) -> ParameterMode {
        return modes[ operand - 1 ]
    }
}

class IntcodeComputer {
    let name: String
    var memory: [Int]
    var inputs: [Int]
    var pc = 0
    var relativeBase = 0
    var halted = true
    var debug = false
    
    var nextInstruction: Instruction {
        return Instruction( instruction: memory[pc] )
    }
    
    init( name: String, memory: [Int], inputs: [Int] ) {
        self.name = name
        self.memory = memory
        self.inputs = inputs
    }

    func fetch( _ instruction: Instruction, operand: Int ) throws -> Int {
        var location = memory[ pc + operand ]
        
        switch instruction.mode( operand: operand ) {
        case .position:
            break
        case .immediate:
            return location
        case .relative:
            location += relativeBase
        }

        if location < 0 {
            throw "Negative memory fetch (\(location)) at address \(pc)"
        } else if location >= memory.count {
            return 0
        }
        return memory[location]
    }
    
    func store( _ instruction: Instruction, operand: Int, value: Int ) throws -> Void {
        var location = memory[ pc + operand ]
        
        switch instruction.mode( operand: operand ) {
        case .position:
            break
        case .immediate:
            throw "Immediate mode invalid for address \(pc)"
        case .relative:
            location += relativeBase
        }

        if location < 0 {
            throw "Negative memory store (\(location)) at address \(pc)"
        } else if location >= memory.count {
            memory.append( contentsOf: Array( repeating: 0, count: location - memory.count + 1 ) )
        }
        memory[location] = value
    }
    
    func step() -> Int? {
        let instruction = nextInstruction
        
        halted = false
        switch instruction.opcode {
        case .add:
            let operand1 = try! fetch( instruction, operand: 1 )
            let operand2 = try! fetch( instruction, operand: 2 )
            
            try! store( instruction, operand: 3, value: operand1 + operand2 )
            pc += 4
        case .multiply:
            let operand1 = try! fetch( instruction, operand: 1 )
            let operand2 = try! fetch( instruction, operand: 2 )

            try! store( instruction, operand: 3, value: operand1 * operand2 )
            pc += 4
        case .input:
            if debug { print( "\(name): inputs \(inputs.first!)" ) }
            try! store( instruction, operand: 1, value: inputs.removeFirst() )
            pc += 2
        case .output:
            let operand1 = try! fetch( instruction, operand: 1 )

            pc += 2
            if debug { print( "\(name): outputs \(operand1)" ) }
            return operand1
        case .jumpIfTrue:
            let operand1 = try! fetch( instruction, operand: 1 )
            let operand2 = try! fetch( instruction, operand: 2 )

            if operand1 != 0 {
                pc = operand2
            } else {
                pc += 3
            }
        case .jumpIfFalse:
            let operand1 = try! fetch( instruction, operand: 1 )
            let operand2 = try! fetch( instruction, operand: 2 )

            if operand1 == 0 {
                pc = operand2
            } else {
                pc += 3
            }
        case .lessThan:
            let operand1 = try! fetch( instruction, operand: 1 )
            let operand2 = try! fetch( instruction, operand: 2 )

            if operand1 < operand2 {
                try! store( instruction, operand: 3, value: 1 )
            } else {
                try! store( instruction, operand: 3, value: 0 )
            }
            pc += 4
        case .equals:
            let operand1 = try! fetch( instruction, operand: 1 )
            let operand2 = try! fetch( instruction, operand: 2 )

            if operand1 == operand2 {
                try! store( instruction, operand: 3, value: 1 )
            } else {
                try! store( instruction, operand: 3, value: 0 )
            }
            pc += 4
        case .relativeBaseOffset:
            let operand1 = try! fetch( instruction, operand: 1 )

            relativeBase += operand1
            pc += 2
        case .halt:
            if debug { print( "\(name): halts" ) }
            halted = true
        }

        return nil
    }

    func grind() -> Int? {
        while true {
            if let output = step() {
                return output
            }
            
            if halted {
                return nil
            }
        }
    }
}

struct Packet {
    let address: Int
    let X: Int
    let Y: Int
    
    static func ==( lhs: Packet, rhs: Packet ) -> Bool {
        guard lhs.address == rhs.address else { return false }
        guard lhs.X == rhs.X else { return false }
        guard lhs.Y == rhs.Y else { return false }
        
        return true
    }
}

class NetworkInterfaceController {
    let computer: IntcodeComputer
    var inputQueue: [Int]
    var outputQueue: [Int] = []
    
    init( address: Int, memory: [Int] ) {
        computer = IntcodeComputer( name: "NIC\(address)", memory: memory, inputs: [] )
        inputQueue = [ address ]
    }
    
    func step() -> Packet? {
        if computer.nextInstruction.opcode == .input {
            if inputQueue.isEmpty {
                computer.inputs = [ -1 ]
            } else {
                computer.inputs = [ inputQueue.removeFirst() ]
            }
        }
        
        if let output = computer.step() {
            outputQueue.append( output )
            if outputQueue.count > 2 {
                let packet = Packet( address: outputQueue[0], X: outputQueue[1], Y: outputQueue[2] )
                
                outputQueue.removeFirst( 3 )
                return packet
            }
        }
        
        return nil
    }
    
    func receivePacket( packet: Packet ) -> Void {
        inputQueue.append( contentsOf: [ packet.X, packet.Y ] )
    }
}

struct NetworkMasterController {
    var nic: [ NetworkInterfaceController ]
    var packetCount = 0
    var lastReceived: Packet?
    var lastDelivered: Packet?

    init( count: Int, memory: [Int] ) {
        nic = ( 0 ..< count ).map { NetworkInterfaceController( address: $0, memory: memory ) }
    }
    
    mutating func crunch( target: Int ) -> Int {
        for stepNum in 1 ..< Int.max {
            if stepNum % 10000 == 0 {
                if packetCount == 0 {
                    if let last = lastDelivered {
                        if last == lastReceived! {
                            return last.Y
                        }
                    }
                    lastDelivered = lastReceived
                    nic[0].receivePacket( packet: lastReceived! )
                }
                packetCount = 0
            }
            
            for controller in nic {
                if let packet = controller.step() {
                    packetCount += 1
                    if packet.address < nic.count {
                        nic[packet.address].receivePacket( packet: packet )
                    } else {
                        //print(packet)
                        if packet.address == target {
                            if lastReceived == nil {
                                lastReceived = packet
                                return packet.Y
                            }
                            lastReceived = packet
                        }
                    }
                }
            }
        }
        
        return 0
    }
}


guard CommandLine.arguments.count > 1 else {
    print( "No input file specified" )
    exit( 1 )
}

let input = try String( contentsOfFile: CommandLine.arguments[1] ).dropLast( 1 )
let initialMemory = input.split( separator: "," ).map { Int($0)! }
var nat = NetworkMasterController( count: 50, memory: initialMemory )

print( "Part 1: \( nat.crunch( target: 255 ) )" )
print( "Part 2: \( nat.crunch( target: 255 ) )" )
