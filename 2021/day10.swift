//
//         FILE: main.swift
//  DESCRIPTION: day10 - Syntax Scoring
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/09/21 21:02:43
//

import Foundation

struct Pair {
    let open: Character
    let close: Character
    let corruptScore: Int
    let incompleteScore: Int
}

let pairs = [
    Pair( open: "(", close: ")", corruptScore: 3, incompleteScore: 1 ),
    Pair( open: "[", close: "]", corruptScore: 57, incompleteScore: 2 ),
    Pair( open: "{", close: "}", corruptScore: 1197, incompleteScore: 3 ),
    Pair( open: "<", close: ">", corruptScore: 25137, incompleteScore: 4 ),
]
let close2open = pairs.reduce(into: [ Character : Pair ]() ) { $0[$1.close] = $1 }
let open2close = pairs.reduce(into: [ Character : Pair ]() ) { $0[$1.open] = $1 }


func parse( input: AOCinput ) -> [[Character]] {
    return input.lines.map { Array( $0 ) }
}


func part1( input: AOCinput ) -> String {
    let lines = parse( input: input )
    var score = 0
    
    LINE:
    for line in lines {
        var stack = [ Character ]()
        
        for character in line {
            if let closing = close2open[character] {
                if stack.isEmpty || stack.last! != closing.open {
                    score += closing.corruptScore
                    continue LINE
                } else {
                    stack.removeLast()
                }
            } else {
                stack.append( character )
            }
        }
    }
    return "\(score)"
}


func part2( input: AOCinput ) -> String {
    let lines = parse( input: input )
    var scores = [Int]()
    
    LINE:
    for line in lines {
        var stack = [ Character ]()
        
        for character in line {
            if let closing = close2open[character] {
                if stack.isEmpty || stack.last! != closing.open {
                    continue LINE
                } else {
                    stack.removeLast()
                }
            } else {
                stack.append( character )
            }
        }
        if !stack.isEmpty {
            scores.append( stack.reversed().map { open2close[$0]! }.reduce( 0 ) {
                $0 * 5 + $1.incompleteScore }
            )
        }
    }
    scores.sort()
    if scores.count.isMultiple( of: 2 ) { return "No solution" }
    return "\( scores[ scores.count / 2 ] )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
