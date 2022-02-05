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
    let autoCompleteScore: Int
}

let pairs = [
    Pair( open: "(", close: ")", corruptScore: 3,     autoCompleteScore: 1 ),
    Pair( open: "[", close: "]", corruptScore: 57,    autoCompleteScore: 2 ),
    Pair( open: "{", close: "}", corruptScore: 1197,  autoCompleteScore: 3 ),
    Pair( open: "<", close: ">", corruptScore: 25137, autoCompleteScore: 4 ),
]
let close2open = pairs.reduce( into: [ Character : Pair ]() ) { $0[$1.close] = $1 }
let open2close = pairs.reduce( into: [ Character : Pair ]() ) { $0[$1.open]  = $1 }

func corruptScore( line: String ) -> Int {
    var stack = [ Character ]()
    
    for character in line {
        if let closing = close2open[character] {
            if stack.isEmpty || stack.removeLast() != closing.open {
                return closing.corruptScore
            }
        } else {
            stack.append( character )
        }
    }
    
    return 0
}

func autoCompleteScore( line: String ) -> Int? {
    var stack = [ Character ]()
    
    for character in line {
        if let closing = close2open[character] {
            if stack.isEmpty || stack.removeLast() != closing.open {
                return nil
            }
        } else {
            stack.append( character )
        }
    }
    if stack.isEmpty { return nil }
    
    return stack.reversed().map { open2close[$0]! }.reduce( 0 ) { $0 * 5 + $1.autoCompleteScore }
}


func part1( input: AOCinput ) -> String {
    return "\( input.lines.reduce( 0 ) { $0 + corruptScore( line: $1 ) } )"
}


func part2( input: AOCinput ) -> String {
    let scores = input.lines.compactMap { autoCompleteScore( line: $0 ) }.sorted()
    
    if scores.count.isMultiple( of: 2 ) { return "No solution" }
    return "\( scores[ scores.count / 2 ] )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
