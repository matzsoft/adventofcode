//
//         FILE: main.swift
//  DESCRIPTION: day16 - Chronal Classification
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/24/21 15:08:05
//

import Foundation

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

class Sample {
    let before: [Int]
    let instruction: Instruction
    let after: [Int]
    
    init( lines: [String] ) {
        let before = lines[0].split( whereSeparator: { " [],".contains($0) } )
        let after = lines[2].split( whereSeparator: { " [],".contains($0) } )
        
        self.before = before[1...4].map { Int($0)! }
        self.after = after[1...4].map { Int($0)! }
        
        instruction = Instruction( input: lines[1] )
    }
}

class WristDevice {
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


func parse( input: AOCinput ) -> ( [Sample], WristDevice ) {
    let samples = input.paragraphs[ ...( input.paragraphs.count-4 ) ].map { Sample( lines: $0 ) }
    let device = WristDevice( instructions: input.paragraphs.last! )
    
    return ( samples, device )
}


func part1( input: AOCinput ) -> String {
    let ( samples, device ) = parse( input: input )

    return "\(samples.filter { device.findMatches( sample: $0 ).count >= 3 }.count)"
}


func part2( input: AOCinput ) -> String {
    let ( samples, device ) = parse( input: input )
    let opcodeDictionary = device.createOpcodeDictionary( samples: samples )
    
    device.run( opcodeDictionary: opcodeDictionary )
    return "\(device.registers[0])"
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
