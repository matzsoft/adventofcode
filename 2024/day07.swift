//
//         FILE: day07.swift
//  DESCRIPTION: Advent of Code 2024 Day 7: Bridge Repair
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/06/24 21:00:02
//

import Foundation
import Library

typealias Operation = ( Int, Int ) -> Int

func add( left: Int, right: Int ) -> Int { left + right }
func multiply( left: Int, right: Int ) -> Int { left * right }
func concatenate( left: Int, right: Int ) -> Int {
    var left = left
    var temp = right
    
    while temp > 0 {
        temp /= 10
        left *= 10
    }
    return left + right
}

struct Equation {
    let solution: Int
    let values: [Int]
    
    init( line: String ) {
        let numbers = line.split( whereSeparator: { ": ".contains( $0 ) } )
            
        solution = Int( numbers[0] )!
        values = numbers[1...].map { Int( $0 )! }
    }
    
    func isValid( opDict: [ Int : [[Operation]] ] ) -> Bool {
        let possibles = opDict[ values.count - 1 ]!

        for opList in possibles {
            var result = values[0]
            for index in values.indices.dropLast() {
                result = opList[index]( result, values[index+1] )
                if result > solution { break }
            }
            if result == solution { return true }
        }
        return false
    }
}


func makeOpDict(
    opList: [Operation], equations: [Equation] ) -> [ Int : [[Operation]] ]
{
    let maxLength = equations.map { $0.values.count }.max()!
    
    return ( 1 ..< maxLength ).reduce( into: [ Int : [[Operation]] ]() ) {
        dict, length in
        
        if length == 1 { dict[1] = opList.map { [$0] } }
        else {
            let next = dict[ length - 1 ]!
            dict[length] = next.flatMap { array in
                opList.map { op -> [Operation] in array + [op] }
            }
        }
    }
}


func part1( input: AOCinput ) -> String {
    let equations = input.lines.map { Equation( line: $0 ) }
    let opDict = makeOpDict( opList: [ add, multiply ], equations: equations )
    let valids = equations.filter { $0.isValid( opDict: opDict ) }
    return "\(valids.reduce( 0, { $0 + $1.solution } ) )"
}


func part2( input: AOCinput ) -> String {
    let equations = input.lines.map { Equation( line: $0 ) }
    let opDict = makeOpDict(
        opList: [ add, multiply, concatenate ], equations: equations )
    let valids = equations.filter { $0.isValid( opDict: opDict ) }
    return "\(valids.reduce( 0, { $0 + $1.solution } ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
