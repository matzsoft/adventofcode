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

class Sample {
    let before: [Int]
    let instruction: WristDevice.Instruction
    let after: [Int]
    
    init( lines: [String] ) {
        let before = lines[0].split( whereSeparator: { " [],".contains($0) } )
        let after = lines[2].split( whereSeparator: { " [],".contains($0) } )
        
        self.before = before[1...4].map { Int($0)! }
        self.after = after[1...4].map { Int($0)! }
        
        instruction = WristDevice.Instruction( input: lines[1] )
    }
}

extension WristDevice {
    func findMatches( sample: Sample ) -> Set<String> {
        Set( opcodes.filter { mnemonic, action in
            registers = sample.before
            action( sample.instruction.a, sample.instruction.b, sample.instruction.c )
            return registers == sample.after
        }.map { $0.key } )
    }
    
    func createOpcodeDictionary( samples: [Sample] ) -> [ Int : String ] {
        var opcodeDictionary = [ Int : String ]()
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
                
                opcodeDictionary[single.key] = mnemonic
                working = working.mapValues { $0.subtracting( [ mnemonic ] ) }
            }
        }

        return opcodeDictionary
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
