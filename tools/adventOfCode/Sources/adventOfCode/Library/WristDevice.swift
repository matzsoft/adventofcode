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
    var opcodes = [ String: Opcode ]()
    
    init( instructions: [String] ) {
        memory = instructions.map { Instruction( input: $0 ) }
        opcodes = [
            Opcode( mnemonic: "addr", action: { self.registers[$2] = self.registers[$0] + self.registers[$1] } ),
            Opcode( mnemonic: "addi", action: { self.registers[$2] = self.registers[$0] + $1 } ),
            Opcode( mnemonic: "mulr", action: { self.registers[$2] = self.registers[$0] * self.registers[$1] } ),
            Opcode( mnemonic: "muli", action: { self.registers[$2] = self.registers[$0] * $1 } ),
            Opcode( mnemonic: "banr", action: { self.registers[$2] = self.registers[$0] & self.registers[$1] } ),
            Opcode( mnemonic: "bani", action: { self.registers[$2] = self.registers[$0] & $1 } ),
            Opcode( mnemonic: "borr", action: { self.registers[$2] = self.registers[$0] | self.registers[$1] } ),
            Opcode( mnemonic: "bori", action: { self.registers[$2] = self.registers[$0] | $1 } ),
            Opcode( mnemonic: "setr", action: { self.registers[$2] = self.registers[$0] } ),
            Opcode( mnemonic: "seti", action: { self.registers[$2] = $0 } ),
            Opcode( mnemonic: "gtir", action: { self.registers[$2] = $0 > self.registers[$1] ? 1 : 0 } ),
            Opcode( mnemonic: "gtri", action: { self.registers[$2] = self.registers[$0] > $1 ? 1 : 0 } ),
            Opcode( mnemonic: "gtrr", action: { self.registers[$2] = self.registers[$0] > self.registers[$1] ? 1 : 0 } ),
            Opcode( mnemonic: "eqir", action: { self.registers[$2] = $0 == self.registers[$1] ? 1 : 0 } ),
            Opcode( mnemonic: "eqri", action: { self.registers[$2] = self.registers[$0] == $1 ? 1 : 0 } ),
            Opcode( mnemonic: "eqrr", action: { self.registers[$2] = self.registers[$0] == self.registers[$1] ? 1 : 0 } ),
        ].reduce( into: [ String : Opcode ]() ) { $0[$1.mnemonic] = $1 }
    }
    
    func findMatches( sample: Sample ) -> Set<String> {
        Set( opcodes.values.filter { opcode in
            registers = sample.before
            opcode.action( sample.instruction.a, sample.instruction.b, sample.instruction.c )
            return registers == sample.after
        }.map { $0.mnemonic } )
    }
    
    func createOpcodeDictionary( samples: [Sample] ) -> [ Int : Opcode ] {
        var opcodeDictionary = [ Int : Opcode ]()
        var working = samples.reduce( into: [ Int: Set<String> ]() ) { dict, sample in
            let matching = findMatches( sample: sample )
            if let existing = dict[ sample.instruction.opcode ] {
                dict[ sample.instruction.opcode ] = existing.intersection( matching )
            } else {
                dict[ sample.instruction.opcode ] = matching
            }
        }
        
        while working.reduce( 0, { $0 + $1.value.count } ) > 0 {
            let singles = working.filter { $0.value.count == 1 }
            
            for single in singles {
                let mnemonic = single.value.first!
                
                opcodeDictionary[single.key] = opcodes[mnemonic]
                working = working.mapValues { $0.subtracting( [ mnemonic ] ) }
            }
        }

        return opcodeDictionary
    }
    
    func run( opcodeDictionary: [ Int : Opcode ] ) -> Void {
        registers = [ 0, 0, 0, 0 ]
        memory.forEach { opcodeDictionary[ $0.opcode ]!.action( $0.a, $0.b, $0.c ) }
    }
}
