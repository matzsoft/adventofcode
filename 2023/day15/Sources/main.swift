//
//         FILE: day15.swift
//  DESCRIPTION: Advent of Code 2023 Day 15: Lens Library
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/14/23 21:00:02
//

import Foundation
import Library

struct Step {
    let box: Int
    let label: String
    let operation: Character
    let focalLength: Int

    init( step: String ) {
        let words = step.split( whereSeparator: { "=-".contains( $0 ) } ).map { String( $0 ) }
        
        box = hash( string: words[0] )
        label = words[0]
        operation = step.contains( "=" ) ? "=" : "-"
        focalLength = operation == "-" ? 0 : Int( words[1] )!
    }
}


struct Lens {
    let label: String
    let focalLength: Int
}


struct Box {
    var lenses: [Lens]
    
    var power: Int {
        lenses.indices.reduce( 0, { $0 + ( $1 + 1 ) * lenses[$1].focalLength } )
    }
}


func hash( string: String ) -> Int {
    string.reduce( 0 ) { ( $0 + Int( $1.asciiValue! ) ) * 17 % 256 }
}

func part1( input: AOCinput ) -> String {
    return "\( input.line.split( separator: "," ).map { hash( string: String( $0 ) ) }.reduce( 0, + ) )"
}


func part2( input: AOCinput ) -> String {
    var boxes = Array( repeating: Box( lenses: [] ), count: 256 )
    let steps = input.line.split( separator: "," ).map { Step(step: String( $0 ) ) }
    
    for step in steps {
        if step.operation == "-" {
            if let index = boxes[step.box].lenses.firstIndex( where: { $0.label == step.label } ) {
                boxes[step.box].lenses.remove( at: index )
            }
        } else {
            let lens = Lens( label: step.label, focalLength: step.focalLength )
            if let index = boxes[step.box].lenses.firstIndex( where: { $0.label == step.label } ) {
                boxes[step.box].lenses.replaceSubrange( index ... index, with: [lens] )
            } else {
                boxes[step.box].lenses.append( lens )
            }
        }
    }
    
    let powers = boxes.indices.map { ( $0 + 1 ) * boxes[$0].power }
    return "\( powers.reduce( 0, + ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
