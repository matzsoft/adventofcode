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

typealias Move        = [Int]
typealias Position    = [Int]
typealias Eligibles   = [Int]
typealias PositionKey = Int

let groundFloor  = FloorName.first.intValue
let topFloor     = FloorName.fourth.intValue

enum PartType: String {  case generator, microchip }
enum FloorName: String, CaseIterable {
    case first, second, third, fourth
    
    var intValue: Int {
        return FloorName.allCases.enumerated().first( where: { $0.element == self } )!.offset + 1
    }
}


func transform( key: PositionKey) -> Position {
    Array( String( key ) ).map { Int( String( $0 ) )! }
}


func transform( position: Position ) -> PositionKey {
    return Int( position.map { String($0) }.joined() )!
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


func indicesToMoves( position: Position, indices: [Int] ) -> [Move] {
    var eligibles = Array( repeating: 0, count: position.count )
    var moves: [Move] = []

    indices.forEach { eligibles[$0] = 1 }

    if position[0] < topFloor {
        let newPosition = zip( position, eligibles ).map(+)
        
        if isSafe( position: newPosition ) { moves.append( eligibles ) }
    }
    
    if position[0] > groundFloor {
        let newPosition = zip( position, eligibles ).map(-)

        if isSafe( position: newPosition ) { moves.append( eligibles.map { -$0 } ) }
    }
    
    return moves
}


func removingEquivalents( moves: [Move] ) -> [Move] {
    guard moves.count > 0 else { return [] }
    
    enum MoveType: Int, CaseIterable {
        case oneGenerator, oneMicrochip, oneEach, twoGenerators, twoMicrochips
    }
    var buckets = Array( repeating: [Move](), count: MoveType.allCases.count )
    var singles = 0
    var doubles = 0
    
    for move in moves {
        let indices = move.enumerated().filter { $0.element != 0 }.map { $0.offset }
        
        switch indices.count {
        case 2 where !indices[1].isMultiple( of: 2 ):
            buckets[MoveType.oneGenerator.rawValue].append( move )
            singles += 1
        case 2 where indices[1].isMultiple( of: 2 ):
            buckets[MoveType.oneMicrochip.rawValue].append( move )
            singles += 1
        case 3 where indices[1].isMultiple( of: 2 ) != indices[2].isMultiple( of: 2 ):
            buckets[MoveType.oneEach.rawValue].append( move )
            doubles += 1
        case 3 where !indices[1].isMultiple( of: 2 ) && !indices[2].isMultiple( of: 2 ):
            buckets[MoveType.twoGenerators.rawValue].append( move )
            doubles += 1
        case 3 where indices[1].isMultiple( of: 2 ) && indices[2].isMultiple( of: 2 ):
            buckets[MoveType.twoMicrochips.rawValue].append( move )
            doubles += 1
        default:
            print( "Invalid move detected" )
            exit( 1 )
        }
    }
    
    if moves[0][0] > 0 {
        if doubles > 0 {
            doubles += 1
            buckets[MoveType.oneGenerator.rawValue] = []
            buckets[MoveType.oneMicrochip.rawValue] = []
        }
    } else {
        if singles > 0 {
            buckets[MoveType.oneEach.rawValue] = []
            buckets[MoveType.twoGenerators.rawValue] = []
            buckets[MoveType.twoMicrochips.rawValue] = []
        }
    }
    
    return buckets.compactMap { $0.first }
}


func elimianteEquivalents( position: Position, moves: [Move] ) -> [Move] {
    let upMoves = moves.filter { $0[0] > 0 }
    let isEmptyBelow = position.allSatisfy { $0 >= position[0] }
    let downMoves = isEmptyBelow ? [] : moves.filter { $0[0] < 0 }

    return removingEquivalents( moves: upMoves ) + removingEquivalents( moves: downMoves )
}


func possibleNextPositions( positionKey: PositionKey ) -> [PositionKey] {
    let position = transform( key: positionKey )
    let indices = position.enumerated().filter { $0.element == position[0] }.map { $0.offset }
    var moves: [Position] = []

    for i in 1 ..< indices.count {
        moves.append( contentsOf: indicesToMoves( position: position, indices: [ 0, indices[i] ] ) )
        
        for j in i + 1 ..< indices.count {
            let sameType = indices[i] % 2 == indices[j] % 2
            let compatible = ( indices[i] - 1 ) / 2 == ( indices[j] - 1 ) / 2
            
            if sameType || compatible {
                let list = [ 0, indices[i], indices[j] ]
                
                moves.append( contentsOf: indicesToMoves( position: position, indices: list ) )
            }
        }
    }
    
    
    let possibles = elimianteEquivalents( position: position, moves: moves ).map {
        zip( position, $0 ).map(+)
    }
    return possibles.map { transform( position: $0 ) }
}


struct Seen {
    var seen: [ PositionKey: Int ] = [:]
    
    init( positionKey: PositionKey, distance: Int ) {
        self[positionKey] = distance
    }
    
    subscript( positionKey: PositionKey ) -> Int? {
        get { return seen[positionKey] }
        set( newDistance ) {
            let position = transform( key: positionKey )
            
            seen[positionKey] = newDistance
            for i in stride( from: 1, to: position.count - 2, by: 2 ) {
                for j in stride(from: i + 2, to: position.count, by: 2 ) {
                    var newPosition = position
                    
                    ( newPosition[i], newPosition[j] ) = ( newPosition[j], newPosition[i] )
                    ( newPosition[i+1], newPosition[j+1] ) = ( newPosition[j+1], newPosition[i+1] )
                    seen[ transform( position: newPosition ) ] = newDistance
                }
            }
        }
    }
}


func solve( initial: PositionKey, final: PositionKey ) -> Int {
    var seen = Seen( positionKey: initial, distance: 0 )
    var queue = [ initial ]
    
    while let position = queue.first {
        let nextPositions = possibleNextPositions( positionKey: position )
        
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
