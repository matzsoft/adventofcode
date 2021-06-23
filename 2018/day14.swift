//
//         FILE: main.swift
//  DESCRIPTION: day14 - Chocolate Charts
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/21/21 18:42:23
//

import Foundation

func printScoreboard( scoreboard: [Int], elf1: Int, elf2: Int ) -> Void {
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


func indexOf( scoreboard: [Int], sequence: [Int] ) -> Int? {
    let startIndex = scoreboard.count - sequence.count - 1

    if startIndex >= 0 && sequence[0...] == scoreboard[startIndex..<(startIndex+sequence.count)] {
        return startIndex
    }

    if startIndex + 1 >= 0 && sequence[0...] == scoreboard[(startIndex+1)...] {
        return startIndex + 1
    }

    return nil
}

func combineRecipes( completed: ( [Int] ) -> String? ) -> String {
    var scoreboard = [ 3, 7 ]
    var elf1 = 0
    var elf2 = 1
    
    while true {
        let sum = scoreboard[elf1] + scoreboard[elf2]
        let digits = Array( String( sum ) ).map { Int( String($0) )! }
        
        scoreboard.append( contentsOf: digits )
        elf1 = ( elf1 + 1 + scoreboard[elf1] ) % scoreboard.count
        elf2 = ( elf2 + 1 + scoreboard[elf2] ) % scoreboard.count
        //printScoreboard( scoreboard: scoreboard, elf1: elf1, elf2: elf2 )
        
        if let result = completed( scoreboard ) {
            return result
        }
    }
}


func part1( input: AOCinput ) -> String {
    let limit = Int( input.line )!
    let nextGroup = 10
    
    return combineRecipes { scoreboard in
        if scoreboard.count >= limit + nextGroup {
            return scoreboard[ limit ..< ( limit + nextGroup ) ].map( { String( $0 ) } ).joined()
        }

        return nil
    }
}


func part2( input: AOCinput ) -> String {
    let sequence = Array( input.line ).map { Int( String( $0 ) )! }
    
    return combineRecipes { scoreboard in
        if let index = indexOf( scoreboard: scoreboard, sequence: sequence ) {
            return String( index )
        }

        return nil
    }
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
