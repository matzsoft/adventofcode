//
//         FILE: main.swift
//  DESCRIPTION: day25 - The Halting Problem
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/25/21 20:14:05
//

import Foundation

struct Transition {
    let input: Bool
    let output: Bool
    let move: Int
    let state: String
    
    init( block: String ) {
        let words = block.split( whereSeparator: { " :-.".contains( $0 ) } )
        
        input = String( words[5] ) == "1"
        output = String( words[9] ) == "1"
        move = String( words[15] )  == "right" ? 1 : -1
        state = String( words[19] )
    }
}

struct State {
    let label: String
    let transitions: [Transition]
    
    init( lines: [String] ) {
        let words = lines[0].split( whereSeparator: { " :".contains( $0 ) } )
        
        label = String( words[2] )
        
        let zero = String( lines[1...4].joined() )
        let one = String( lines[5...8].joined() )
        
        transitions = [ Transition( block: zero ), Transition( block: one ) ]
    }
}

class TuringMachine {
    let fsa: [ String: State ]
    let goal: Int
    var state: String
    var tape: [Bool]
    var current: Int
    
    var checksum: Int { return tape.reduce( 0, { $0 + ( $1 ? 1 : 0 ) } ) }
    
    init( blocks: [[String]] ) {
        let words = blocks[0].map { $0.split( whereSeparator: { " .".contains( $0 ) } ) }
        
        state = String( words[0][3] )
        goal = Int( words[1][5] )!
        tape = Array( repeating: false, count: goal )
        current = ( goal + 1 ) / 2
        fsa = Dictionary( uniqueKeysWithValues: blocks[1...].map{
            let state = State( lines: $0 )
            
            return ( state.label, state )
        } )
    }
    
    func run() -> Void {
        var step = 0
        
        while step < goal {
            step += 1
            for transition in fsa[state]!.transitions {
                if transition.input == tape[current] {
                    tape[current] = transition.output
                    state = transition.state
                    current += transition.move
                    if current < 0 || current >= goal {
                        print( "Insufficient tape at", step + 1 )
                        exit(1)
                    }
                    break
                }
            }
        }
    }
}



func parse( input: AOCinput ) -> TuringMachine {
    return TuringMachine( blocks: input.paragraphs )
}


func part1( input: AOCinput ) -> String {
    let machine = parse( input: input )
    
    machine.run()
    return "\(machine.checksum)"
}


func part2( input: AOCinput ) -> String {
    return "None"
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
