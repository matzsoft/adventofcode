//
//         FILE: main.swift
//  DESCRIPTION: day25 - Cryostasis
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/22/21 12:36:05
//

import Foundation

struct Game {
    let computer: Intcode
    var inputQueue: [String] = []
    var outputQueue = ""
    var lastOutput = ""
    
    init( memory: [Int] ) {
        computer = Intcode( name: "AOC-Advent", memory: memory )
    }

    func command( value: String ) -> Void {
        computer.inputs.append( contentsOf: value.map { Int( $0.asciiValue! ) } )
        computer.inputs.append( Int( Character( "\n" ).asciiValue! ) )
    }
    
    mutating func trial() throws -> Void {
        var outputQueue = ""
        
        while true {
            if computer.nextInstruction.opcode == .input {
                if computer.inputs.isEmpty {
                    if inputQueue.isEmpty {
                        let line = readLine( strippingNewline: true ) ?? ""
                        
                        command( value: line )
                    } else {
                        let line = inputQueue.removeFirst()
                        
                        command( value: line )
                        print( line )
                    }
                }
            }

            if let output = try computer.step() {
                if let code = UnicodeScalar( output ) {
                    let char = Character( code )
                    
                    if char.isASCII {
                        if char != "\n" {
                            outputQueue.append( char )
                        } else {
                            print( outputQueue )
                            lastOutput = outputQueue
                            outputQueue = ""
                        }
                    }
                }
            }
            
            if computer.nextInstruction.opcode == .halt { break }
        }
        
        print( outputQueue )
    }
}


func parse( input: AOCinput ) -> Game {
    let initialMemory = input.line.split( separator: "," ).map { Int( $0 )! }

    return Game( memory: initialMemory )
}


func part1( input: AOCinput ) -> String {
    var game = parse( input: input )
    let initialCommands = """
    south
    take mouse
    north
    west
    north
    north
    west
    take semiconductor
    east
    south
    west
    south
    take hypercube
    north
    east
    south
    west
    take antenna
    west
    south
    south
    south
    """

    game.inputQueue = initialCommands.split( separator: "\n" ).map { String( $0 ) }
    try! game.trial()
    
    let words = game.lastOutput.split( separator: " " )
    return "\( words[11] )"
}


func part2( input: AOCinput ) -> String {
    return "None"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
