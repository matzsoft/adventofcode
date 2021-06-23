//
//         FILE: main.swift
//  DESCRIPTION: day23 - Category Six
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/18/21 12:41:43
//

import Foundation

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
    let computer: Intcode
    var inputQueue: [Int]
    var outputQueue: [Int] = []
    
    init( address: Int, memory: [Int] ) {
        computer = Intcode( name: "NIC\(address)", memory: memory )
        inputQueue = [ address ]
    }
    
    func step() throws -> Packet? {
        if computer.nextInstruction.opcode == .input {
            if inputQueue.isEmpty {
                computer.inputs = [ -1 ]
            } else {
                computer.inputs = [ inputQueue.removeFirst() ]
            }
        }
        
        if let output = try computer.step() {
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
    
    mutating func crunch( target: Int ) throws -> Int {
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
                if let packet = try controller.step() {
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


func parse( input: AOCinput ) -> NetworkMasterController {
    let initialMemory = input.line.split( separator: "," ).map { Int( $0 )! }
    return NetworkMasterController( count: 50, memory: initialMemory )
}


func part1( input: AOCinput ) -> String {
    var nat = parse( input: input )
    return "\( try! nat.crunch( target: 255 ) )"
}


func part2( input: AOCinput ) -> String {
    var nat = parse( input: input )
    
    _ = try! nat.crunch( target: 255 )
    return "\( try! nat.crunch( target: 255 ) )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
