//
//         FILE: main.swift
//  DESCRIPTION: day11 - Radioisotope Thermoelectric Generators
//        NOTES: The parse function generates an Int in order to make an easy key for the seen dictionary.
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 03/29/21 18:59:28
//

import Foundation

enum PartType: String {  case generator, microchip }
enum FloorName: String, CaseIterable {
    case first, second, third, fourth
    
    var intValue: Int {
        return FloorName.allCases.enumerated().first( where: { $0.element == self } )!.offset + 1
    }
}


func pow( _ base: Int, _ power: Int ) -> Int {
    return Int( pow( Double( base), Double( power) ) )
}


struct Part {
    let type: PartType
    let element: String
    
    init( compatible: String, type: String ) {
        self.type = PartType( rawValue: String( type ) )!
        element = ( self.type == .generator ) ? compatible : String( compatible.dropLast( "-compatible".count ) )
    }
    
    var offset: Int {
        return type == .generator ? 1 : 0
    }
}


let groundFloor  = FloorName.first.intValue
let topFloor     = FloorName.fourth.intValue

func isSafe( position: Int ) -> Bool {
    let digits = Array( String( position ) ).map { Int( String( $0 ) )! }

    for i in stride( from: 1, to: digits.count, by: 2 ) {
        if digits[i] != digits[i+1] {
            // Compatible generator and microchip are on different floors.
            for j in stride( from: 1, to: digits.count, by: 2 ) {
                if digits[j] == digits[i+1] { return false }
            }
        }
    }
    
    return true
}


func indicesToMove( length: Int, indices: [Int] ) -> Int {
    var result = Array( repeating: 0, count: length )
    
    indices.forEach { result[$0] = 1 }
    return Int( result.map { String($0) }.joined() )!
}


func deltaToMoves( floor: Int, position: Int, delta: Int ) -> [Int] {
    var moves: [Int] = []

    if floor < topFloor {
        let move = position + delta
        
        if isSafe( position: move ) { moves.append( move ) }
    }
    
    if floor > groundFloor {
        let move = position - delta
        
        if isSafe( position: move ) { moves.append( move ) }
    }
    
    return moves
}


func possibleMoves( position: Int ) -> [Int] {
    let digits = Array( String( position ) ).map { Int( String( $0 ) )! }
    let indices = digits.enumerated().filter { $0.element == digits[0] }.map { $0.offset }
    var moves: [Int] = []

    for i in 1 ..< indices.count {
        let move = indicesToMove( length: digits.count, indices: [ 0, indices[i] ] )
        
        moves.append( contentsOf: deltaToMoves( floor: digits[0], position: position, delta: move ) )
        
        for j in i + 1 ..< indices.count {
            let sameType = indices[i] % 2 == indices[j] % 2
            let compatible = ( indices[i] - 1 ) / 2 == ( indices[j] - 1 ) / 2
            
            if sameType || compatible {
                let list = [ 0, indices[i], indices[j] ]
                let move = indicesToMove( length: digits.count, indices: list )
                let positions = deltaToMoves( floor: digits[0], position: position, delta: move )
                
                moves.append( contentsOf: positions )
            }
        }
    }
    
    return moves
}


func solve( initial: Int, final: Int ) -> Int {
    var seen = [ initial: 0 ]
    var queue = [ initial ]
    
    while let position = queue.first {
        let moves = possibleMoves( position: position )
        
        queue.removeFirst()
        for move in moves {
            if move == final {
                return seen[position]! + 1
            }
            if seen[move] == nil {
                seen[move] = seen[position]! + 1
                queue.append( move )
            }
        }
    }
    
    return Int.max
}


func parse( input: AOCinput ) -> Int {
    var elements = [ String : Int ]()
    var result = 1                      // first digit is me and I always start on floor 1
    
    for line in input.lines {
        let words = line.split { " ,.".contains( $0 ) }
        let floor = FloorName( rawValue: String( words[1] ) )!.intValue
        
        if words[4] != "nothing" {
            let reduced = words.filter { $0 != "and" }
            let parts = stride( from: 4, to: reduced.count, by: 3 ).map {
                Part( compatible: String( reduced[$0+1] ), type: String( reduced[$0+2] ) )
            }
            
            for part in parts {
                if let index = elements[part.element] {
                    let power = ( elements.count - index ) * 2 + part.offset
                    
                    result += floor * pow( 10, power )
                } else {
                    result *= 100
                    result += floor * pow( 10, part.offset )
                    elements[part.element]  = elements.count + 1
                }
            }
        }
    }
    return result
}


func part1( input: AOCinput ) -> String {
    let initial = parse( input: input )
    let final = Int( Array( repeating: "4", count: String( initial ).count ).joined() )!

    return "\(solve( initial: initial, final: final ))"
}


func part2( input: AOCinput ) -> String {
    let initial = parse( input: input ) * 10000 + 1111
    let final = Int( Array( repeating: "4", count: String( initial ).count ).joined() )!

    return "\(solve( initial: initial, final: final ))"
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
