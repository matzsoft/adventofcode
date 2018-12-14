//
//  main.swift
//  day14
//
//  Created by Mark Johnson on 12/13/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

let test1_1 = 5
let test1_2 = 9
let test1_3 = 18
let test1_4 = 2018
let input1 = 681901
let test2_1 = "01245"
let test2_2 = "51589"
let test2_3 = "92510"
let test2_4 = "59414"
let input2 = "681901"
let nextGroup = 10
var scoreboard = [ 3, 7 ]
var elf1 = 0
var elf2 = 1

func printScoreboard() -> Void {
    var unpacked = Array( scoreboard.map { String(format: "%3d", $0) }.joined() + " " )
    let pos1 = 3 * elf1 + 2
    let pos2 = 3 * elf2 + 2
    
    unpacked[ pos1 - 1 ] = "("
    unpacked[ pos1 + 1 ] = ")"
    unpacked[ pos2 - 1 ] = "["
    unpacked[ pos2 + 1 ] = "]"
    unpacked.removeFirst()
    
    print( String( unpacked ) )
}

func indexOf( sequence: [Int] ) -> Int? {
    var startIndex = max( 0, scoreboard.count - sequence.count - 1 )

    while startIndex + sequence.count < scoreboard.count {
        var scoreboardIndex = startIndex
        
        for sequenceIndex in 0 ..< sequence.count {
            if scoreboard[scoreboardIndex] != sequence[sequenceIndex] {
                startIndex += 1
                break
            } else {
                if sequenceIndex == sequence.count - 1 {
                    return startIndex
                }
                
                scoreboardIndex += 1
            }
        }
    }
    
    return nil
}


let limit = input1
let sequence = Array( input2 ).map { Int( String($0) )! }
var part1Pending = true
var part2Pending = true

//printScoreboard()

while part1Pending || part2Pending {
    let sum = scoreboard[elf1] + scoreboard[elf2]
    let digits = Array( String( sum ) ).map { Int( String($0) )! }
    
    scoreboard.append(contentsOf: digits)
    elf1 = ( elf1 + 1 + scoreboard[elf1] ) % scoreboard.count
    elf2 = ( elf2 + 1 + scoreboard[elf2] ) % scoreboard.count
//    printScoreboard()
    
    if part1Pending && scoreboard.count >= limit + nextGroup {
        let part1 = scoreboard[ limit ..< ( limit + nextGroup ) ]

        part1Pending = false
        print( "Part1:", part1.map( { String($0) } ).joined() )
    }
    
    if part2Pending && scoreboard.count > sequence.count {
        if let index = indexOf(sequence: sequence) {
            part2Pending = false
            print( "Part2:", index )
        }
    }
}
