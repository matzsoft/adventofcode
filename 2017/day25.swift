//
//  main.swift
//  day25
//
//  Created by Mark Johnson on 1/25/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let testInput = """
Begin in state A.
Perform a diagnostic checksum after 6 steps.

In state A:
If the current value is 0:
- Write the value 1.
- Move one slot to the right.
- Continue with state B.
If the current value is 1:
- Write the value 0.
- Move one slot to the left.
- Continue with state B.

In state B:
If the current value is 0:
- Write the value 1.
- Move one slot to the left.
- Continue with state A.
If the current value is 1:
- Write the value 1.
- Move one slot to the right.
- Continue with state A.
"""
let input = """
Begin in state A.
Perform a diagnostic checksum after 12134527 steps.

In state A:
If the current value is 0:
- Write the value 1.
- Move one slot to the right.
- Continue with state B.
If the current value is 1:
- Write the value 0.
- Move one slot to the left.
- Continue with state C.

In state B:
If the current value is 0:
- Write the value 1.
- Move one slot to the left.
- Continue with state A.
If the current value is 1:
- Write the value 1.
- Move one slot to the right.
- Continue with state C.

In state C:
If the current value is 0:
- Write the value 1.
- Move one slot to the right.
- Continue with state A.
If the current value is 1:
- Write the value 0.
- Move one slot to the left.
- Continue with state D.

In state D:
If the current value is 0:
- Write the value 1.
- Move one slot to the left.
- Continue with state E.
If the current value is 1:
- Write the value 1.
- Move one slot to the left.
- Continue with state C.

In state E:
If the current value is 0:
- Write the value 1.
- Move one slot to the right.
- Continue with state F.
If the current value is 1:
- Write the value 1.
- Move one slot to the right.
- Continue with state A.

In state F:
If the current value is 0:
- Write the value 1.
- Move one slot to the right.
- Continue with state A.
If the current value is 1:
- Write the value 1.
- Move one slot to the right.
- Continue with state E.
"""


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
    
    init( input: String ) {
        let lines = input.split(separator: "\n")
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
    
    init( input: String ) {
        let blocks = input.components(separatedBy: "\n\n")
        let words = blocks[0].split( whereSeparator: { " .\n".contains( $0 ) } )
        
        state = String( words[3] )
        goal = Int( words[9] )!
        tape = Array( repeating: false, count: goal )
        current = ( goal + 1 ) / 2
        fsa = Dictionary( uniqueKeysWithValues: blocks[1...].map{
            let state = State( input: $0 )
            
            return ( state.label, state )
        } )
    }
    
    func run() -> Void {
        for step in 0 ..< goal {
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

let machine = TuringMachine( input: input )

machine.run()
print( "Part1:", machine.checksum )
