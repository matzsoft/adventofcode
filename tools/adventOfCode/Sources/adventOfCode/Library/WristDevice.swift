//
//  WristDevice.swift
//  day16
//
//  Created by Mark Johnson on 5/27/21.
//

import Foundation

class WristDevice {
    class Opcode {
        let mnemonic: String
        let action: ( Int, Int, Int ) -> Void
        
        init( mnemonic: String, action: @escaping ( Int, Int, Int ) -> Void ) {
            self.mnemonic = mnemonic
            self.action = action
        }
    }

    class Instruction {
        let opcode: Int
        let a: Int
        let b: Int
        let c: Int
        
        init( input: String ) {
            let instruction = input.split(separator: " ")
            
            opcode = Int( instruction[0] )!
            a = Int( instruction[1] )!
            b = Int( instruction[2] )!
            c = Int( instruction[3] )!
        }
    }

    var registers = [ 0, 0, 0, 0 ]
    let memory: [Instruction]
    var opcodes = [ String: ( Int, Int, Int ) -> Void ]()
    
    init( instructions: [String] ) {
        memory = instructions.map { Instruction( input: $0 ) }
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
    
    func run( opcodeDictionary: [ Int : String ] ) -> Void {
        registers = [ 0, 0, 0, 0 ]
        memory.forEach { opcodes[ opcodeDictionary[ $0.opcode ]! ]!( $0.a, $0.b, $0.c ) }
    }
}
