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
    let input:  Bool
    let output: Bool
    let move:   Int
    let state:  String
    
    init( lines: [String] ) {
        let words = lines.map { $0.split( whereSeparator: { " :-.".contains( $0 ) } ) }
        
        input =  String( words[0][5] ) == "1"
        output = String( words[1][3] ) == "1"
        move =   String( words[2][5] ) == "right" ? 1 : -1
        state =  String( words[3][3] )
    }
}

struct State {
    let label: String
    let transitions: [Transition]
    
    init( lines: [String] ) {
        let words = lines[0].split( whereSeparator: { " :".contains( $0 ) } )
        
        label = String( words[2] )
        transitions = [
            Transition( lines: Array( lines[1...4] ) ),
            Transition( lines: Array( lines[5...8] ) )
        ]
    }
}

class TuringMachine {
    var tape    = Set<Int>()
    var current = 0
    let fsa:    [ String: State ]
    let goal:   Int
    var state:  String
    
    var checksum: Int { return tape.count }
    
    init( blocks: [[String]] ) {
        let words = blocks[0].map { $0.split( whereSeparator: { " .".contains( $0 ) } ) }
        
        fsa = Dictionary( uniqueKeysWithValues: blocks[1...].map{
            let state = State( lines: $0 )
            
            return ( state.label, state )
        } )
        goal = Int( words[1][5] )!
        state = String( words[0][3] )
    }
    
    func run() -> Void {
        var step = 0
        
        while step < goal {
            step += 1
            if tape.contains( current ) {
                let transition = fsa[state]!.transitions[1]
                if !transition.output { tape.remove( current ) }
                current += transition.move
                state = transition.state
            } else {
                let transition = fsa[state]!.transitions[0]
                if transition.output { tape.insert( current ) }
                current += transition.move
                state = transition.state
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


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
