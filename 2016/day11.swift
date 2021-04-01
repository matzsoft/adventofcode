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

typealias Move = [Int]
typealias Position = [Int]
typealias Eligibles = [Int]
typealias PositionKey = Int

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
        self.type = PartType( rawValue: type )!
        element = ( self.type == .generator ) ? compatible :
            String( compatible.dropLast( "-compatible".count ) )
    }
    
    var offset: Int {
        return type == .generator ? 1 : 0
    }
}


let groundFloor  = FloorName.first.intValue
let topFloor     = FloorName.fourth.intValue

func isSafe( position: Position ) -> Bool {
    for i in stride( from: 1, to: position.count, by: 2 ) {
        if position[i] != position[i+1] {
            // Compatible generator and microchip are on different floors.
            for j in stride( from: 1, to: position.count, by: 2 ) {
                if position[j] == position[i+1] { return false }
            }
        }
    }
    
    return true
}


func indicesToPositions( position: Position, indices: [Int] ) -> [Position] {
    var eligibles = Array( repeating: 0, count: position.count )
    var positions: [Position] = []

    indices.forEach { eligibles[$0] = 1 }

    if position[0] < topFloor {
        let newPosition = zip( position, eligibles ).map(+)
        
        if isSafe( position: newPosition ) { positions.append( newPosition ) }
    }
    
    if position[0] > groundFloor {
        let newPosition = zip( position, eligibles ).map(-)

        if isSafe( position: newPosition ) { positions.append( newPosition ) }
    }
    
    return positions
}


func possibleNextPositions( position: PositionKey ) -> [PositionKey] {
    let digits = Array( String( position ) ).map { Int( String( $0 ) )! }
    let indices = digits.enumerated().filter { $0.element == digits[0] }.map { $0.offset }
    var possibles: [Position] = []

    for i in 1 ..< indices.count {
        possibles.append( contentsOf: indicesToPositions( position: digits, indices: [ 0, indices[i] ] ) )
        
        for j in i + 1 ..< indices.count {
            let sameType = indices[i] % 2 == indices[j] % 2
            let compatible = ( indices[i] - 1 ) / 2 == ( indices[j] - 1 ) / 2
            
            if sameType || compatible {
                let list = [ 0, indices[i], indices[j] ]
                
                possibles.append( contentsOf: indicesToPositions( position: digits, indices: list ) )
            }
        }
    }
    
    return possibles.map { Int( $0.map { String($0) }.joined() )! }
}


func solve( initial: PositionKey, final: PositionKey ) -> Int {
    var seen = [ initial: 0 ]
    var queue = [ initial ]
    
    while let position = queue.first {
        let nextPositions = possibleNextPositions( position: position )
        
        queue.removeFirst()
        for nextPosition in nextPositions {
            if nextPosition == final {
                return seen[position]! + 1
            }
            if seen[nextPosition] == nil {
                seen[nextPosition] = seen[position]! + 1
                queue.append( nextPosition )
            }
        }
    }
    
    return Int.max
}


func parse( input: AOCinput ) -> PositionKey {
    var elements = [ String : Int ]()
    var result = 1                      // first digit is the elevator that always start on floor 1
    
    for line in input.lines {
        let words = line.split { " ,.".contains( $0 ) }.filter { $0 != "and" }
        let floor = FloorName( rawValue: String( words[1] ) )!.intValue
        
        if words[4] != "nothing" {
            let parts = stride( from: 4, to: words.count, by: 3 ).map {
                Part( compatible: String( words[$0+1] ), type: String( words[$0+2] ) )
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
