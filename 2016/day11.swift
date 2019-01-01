//
//  main.swift
//  new11
//
//  Created by Mark Johnson on 12/7/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

// Instead of parsing the input, just build a structure for it.
//The first floor contains a promethium generator and a promethium-compatible microchip.
//The second floor contains a cobalt generator, a curium generator, a ruthenium generator, and a plutonium generator.
//The third floor contains a cobalt-compatible microchip, a curium-compatible microchip, a ruthenium-compatible microchip, and a plutonium-compatible microchip.
//The fourth floor contains nothing relevant.

let initialTest1 = 12131
let finalTest1   = 44444
let initialTest2 = 1112323
let finalTest2   = 4444444
let initialPart1  = 11123232323
let finalPart1    = 44444444444
let initialPart2  = 111232323231111
let finalPart2    = 444444444444444

let initial      = initialTest1
let final        = finalTest1

let groundFloor  = 1
let topFloor     = 4

func isSafe( position: Int ) -> Bool {
    let digits = Array( String( position ) ).map { Int( String( $0 ) )! }

    for i in stride(from: 1, to: digits.count, by: 2) {
        if digits[i] != digits[i+1] {
            // Compatible generator and microchip are on different floors.
            for j in stride(from: 1, to: digits.count, by: 2) {
                if digits[j] == digits[i+1] { return false }
            }
        }
    }
    
    return true
}

func indicesToMove( length: Int, indices: [Int] ) -> Int {
    var result = Array(repeating: 0, count: length)
    
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
        
        if i < indices.count - 1 {
            for j in i + 1 ..< indices.count {
                let sameType = indices[i] % 2 == indices[j] % 2
                let compatible = ( indices[i] - 1 ) / 2 == ( indices[j] - 1 ) / 2
                
                if sameType || compatible {
                    let list = [ 0, indices[i], indices[j] ]
                    let move = indicesToMove(length: digits.count, indices: list )
                    let positions = deltaToMoves( floor: digits[0], position: position, delta: move )
                    
                    moves.append( contentsOf: positions )
                }
            }
        }
    }
    
    return moves
}

func solve( initial: Int, final: Int ) -> Int {
    var seen = [ initial: 0 ]
    var queue = [ initial ]
    
    while let position = queue.first {
        let moves = possibleMoves(position: position)
        
        queue.removeFirst()
        for move in moves {
            if move == final {
                return seen[position]! + 1
            }
            if seen[move] == nil {
                seen[move] = seen[position]! + 1
                queue.append(move)
            }
        }
    }
    
    return Int.max
}

//print( possibleMoves(position: initialTest1) )
//print( possibleMoves(position: finalTest1) )
//print( possibleMoves(position: initialTest2) )
//print( possibleMoves(position: finalTest2) )
//print( possibleMoves(position: initialPart1) )
//print( possibleMoves(position: finalPart1) )
//print( possibleMoves(position: 12112) )

print( "Part1:", solve(initial: initialPart1, final: finalPart1) )
print( "Part2:", solve(initial: initialPart2, final: finalPart2) )
