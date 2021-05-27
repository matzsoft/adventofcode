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
