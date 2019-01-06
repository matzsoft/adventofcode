//
//  main.swift
//  day21
//
//  Created by Mark Johnson on 1/5/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

typealias TestStep = ( start: String, operation: String, result: String )
let test = [
    ( start: "abcde", operation: "swap position 4 with position 0",      result: "ebcda" ),
    ( start: "ebcda", operation: "swap letter d with letter b",          result: "edcba" ),
    ( start: "edcba", operation: "reverse positions 0 through 4",        result: "abcde" ),
    ( start: "abcde", operation: "rotate left 1",                        result: "bcdea" ),
    ( start: "bcdea", operation: "move position 1 to position 4",        result: "bdeac" ),
    ( start: "bdeac", operation: "move position 3 to position 0",        result: "abdec" ),
    ( start: "abdec", operation: "rotate based on position of letter b", result: "ecabd" ),
    ( start: "ecabd", operation: "rotate based on position of letter d", result: "decab" ),
]
let unscrambled = "abcdefgh"
let scrambled = "fbgdceah"
let input = """
rotate based on position of letter d
move position 1 to position 6
swap position 3 with position 6
rotate based on position of letter c
swap position 0 with position 1
rotate right 5 steps
rotate left 3 steps
rotate based on position of letter b
swap position 0 with position 2
rotate based on position of letter g
rotate left 0 steps
reverse positions 0 through 3
rotate based on position of letter a
rotate based on position of letter h
rotate based on position of letter a
rotate based on position of letter g
rotate left 5 steps
move position 3 to position 7
rotate right 5 steps
rotate based on position of letter f
rotate right 7 steps
rotate based on position of letter a
rotate right 6 steps
rotate based on position of letter a
swap letter c with letter f
reverse positions 2 through 6
rotate left 1 step
reverse positions 3 through 5
rotate based on position of letter f
swap position 6 with position 5
swap letter h with letter e
move position 1 to position 3
swap letter c with letter h
reverse positions 4 through 7
swap letter f with letter h
rotate based on position of letter f
rotate based on position of letter g
reverse positions 3 through 4
rotate left 7 steps
swap letter h with letter a
rotate based on position of letter e
rotate based on position of letter f
rotate based on position of letter g
move position 5 to position 0
rotate based on position of letter c
reverse positions 3 through 6
rotate right 4 steps
move position 1 to position 2
reverse positions 3 through 6
swap letter g with letter a
rotate based on position of letter d
rotate based on position of letter a
swap position 0 with position 7
rotate left 7 steps
rotate right 2 steps
rotate right 6 steps
rotate based on position of letter b
rotate right 2 steps
swap position 7 with position 4
rotate left 4 steps
rotate left 3 steps
swap position 2 with position 7
move position 5 to position 4
rotate right 3 steps
rotate based on position of letter g
move position 1 to position 2
swap position 7 with position 0
move position 4 to position 6
move position 3 to position 0
rotate based on position of letter f
swap letter g with letter d
swap position 1 with position 5
reverse positions 0 through 2
swap position 7 with position 3
rotate based on position of letter g
swap letter c with letter a
rotate based on position of letter g
reverse positions 3 through 5
move position 6 to position 3
swap letter b with letter e
reverse positions 5 through 6
move position 6 to position 7
swap letter a with letter e
swap position 6 with position 2
move position 4 to position 5
rotate left 5 steps
swap letter a with letter d
swap letter e with letter g
swap position 3 with position 7
reverse positions 0 through 5
swap position 5 with position 7
swap position 1 with position 7
swap position 1 with position 7
rotate right 7 steps
swap letter f with letter a
reverse positions 0 through 7
rotate based on position of letter d
reverse positions 2 through 4
swap position 7 with position 1
swap letter a with letter h
"""

func swapPosition( start: String, offset1: Int, offset2: Int ) -> String {
    var result = start
    
    let firstOffset = min( offset1, offset2 )
    let lastOffset = max( offset1, offset2 )
    let firstIndex = result.index( result.startIndex, offsetBy: firstOffset )
    let lastIndex = result.index( result.startIndex, offsetBy: lastOffset )
    let lastChar = result.remove( at: lastIndex )
    let firstChar = result.remove( at: firstIndex )
    
    result.insert( lastChar, at: firstIndex )
    result.insert( firstChar, at: lastIndex )
    return result
}

func swapLetter( start: String, letter1: Substring, letter2: Substring ) -> String {
    var result = start
    let char1 = Character( String( letter1 ) )
    let char2 = Character( String( letter2 ) )
    let index1 = result.firstIndex { $0 == char1 }!
    let index2 = result.firstIndex { $0 == char2 }!

    result.remove( at: index1 )
    result.insert( char2, at: index1 )
    result.remove( at: index2 )
    result.insert( char1, at: index2 )
    return result
}

func rotateLeft( start: String, steps: Int ) -> String {
    let offset = steps % start.count
    let index = start.index( start.startIndex, offsetBy: offset )
    let result = start[index...] + start[..<index]
    
    return String( result )
}

func rotateRight( start: String, steps: Int ) -> String {
    let offset = steps % start.count
    let index = start.index( start.endIndex, offsetBy: -offset )
    let result = start[index...] + start[..<index]
    
    return String( result )
}

func rotateBased( start: String, letter: Substring ) -> String {
    let char = Character( String( letter ) )
    let index = start.firstIndex { $0 == char }!
    let offset = start.distance( from: start.startIndex, to: index )
    
    return rotateRight( start: start, steps: offset < 4 ? offset + 1 : offset + 2 )
}

func unrotateBased( start: String, letter: Substring ) -> String {
    let char = Character( String( letter ) )
    let index = start.firstIndex { $0 == char }!
    let newOffset = start.distance( from: start.startIndex, to: index )
    
    if newOffset & 1 == 1 {
        return rotateLeft( start: start, steps: ( newOffset + 1 ) / 2 )
    }
    
    if newOffset - 2 < 0 {
        return rotateLeft( start: start, steps: ( newOffset + 2 ) / 2 )
    }
    
    return rotateLeft( start: start, steps: ( newOffset + start.count + 3 ) / 2 )
}

func reverse( start: String, firstOffset: Int, lastOffset: Int ) -> String {
    let first = start.index( start.startIndex, offsetBy: firstOffset )
    let last = start.index( start.startIndex, offsetBy: lastOffset )
    let prefix = String( start.prefix( firstOffset ) )
    let middle = String( start[ first ... last ].reversed() )
    let suffix = String( start.suffix( start.count - lastOffset - 1 ) )
    
    return prefix + middle + suffix
}

func move( start: String, firstOffset: Int, lastOffset: Int ) -> String {
    var result = start
    let char = result.remove( at: result.index( result.startIndex, offsetBy: firstOffset ) )
    
    result.insert( char, at: result.index( result.startIndex, offsetBy: lastOffset ) )
    return result
}

func scrambleStep( start: String, operation: String ) -> String {
    let words = operation.split(separator: " ")

    switch words[0] {
    case "swap":
        switch words[1] {
        case "position":
            return swapPosition( start: start, offset1: Int( words[2] )!, offset2: Int( words[5] )! )
        case "letter":
            return swapLetter( start: start, letter1: words[2], letter2: words[5] )
        default:
            print( "Swap parse error on:", operation )
            exit(1)
        }
        
    case "rotate":
        switch words[1] {
        case "left":
            return rotateLeft( start: start, steps: Int( words[2] )! )
        case "right":
            return rotateRight( start: start, steps: Int( words[2] )! )
        case "based":
            return rotateBased( start: start, letter: words[6] )
        default:
            print( "Rotate parse error on:", operation )
            exit(1)
        }
        
    case "reverse":
        return reverse( start: start, firstOffset: Int( words[2] )!, lastOffset: Int( words[4] )! )

    case "move":
        return move( start: start, firstOffset: Int( words[2] )!, lastOffset: Int( words[5] )! )
        
    default:
        print( "First word parse error on:", operation )
        exit(1)
    }
}

func scrambleStep( start: String, operation: Substring ) -> String {
    return scrambleStep(start: start, operation: String( operation ) )
}

func unscrambleStep( start: String, operation: String ) -> String {
    let words = operation.split(separator: " ")

    switch words[0] {
    case "swap":
        switch words[1] {
        case "position":
            return swapPosition( start: start, offset1: Int( words[2] )!, offset2: Int( words[5] )! )
        case "letter":
            return swapLetter( start: start, letter1: words[2], letter2: words[5] )
        default:
            print( "Swap parse error on:", operation )
            exit(1)
        }
        
    case "rotate":
        switch words[1] {
        case "left":
            return rotateRight( start: start, steps: Int( words[2] )! )
        case "right":
            return rotateLeft( start: start, steps: Int( words[2] )! )
        case "based":
            return unrotateBased( start: start, letter: words[6] )
        default:
            print( "Rotate parse error on:", operation )
            exit(1)
        }
        
    case "reverse":
        return reverse( start: start, firstOffset: Int( words[2] )!, lastOffset: Int( words[4] )! )

    case "move":
        return move( start: start, firstOffset: Int( words[5] )!, lastOffset: Int( words[2] )! )

    default:
        print( "First word parse error on:", operation )
        exit(1)
    }
}

func unscrambleStep( start: String, operation: Substring ) -> String {
    return unscrambleStep(start: start, operation: String( operation ) )
}



for step in test {
    let next = scrambleStep(start: step.start, operation: step.operation )
    
    if next != step.result {
        print( "Test scramble failure on:", step.operation )
        print( "Started with \(step.start), expected \(step.result), got \(next)" )
        exit(1)
    }
}

for step in test.reversed() {
    let next = unscrambleStep(start: step.result, operation: step.operation )
    
    if next != step.start {
        print( "Test unscramble failure on:", step.operation )
        print( "Started with \(step.result), expected \(step.start), got \(next)" )
        exit(1)
    }
}


let part1 = input.split(separator: "\n").reduce( unscrambled, { scrambleStep(start: $0, operation: $1 ) } )

print( "Part1:", part1 )

let part2 = input.split(separator: "\n").reversed().reduce( scrambled, {
    unscrambleStep(start: $0, operation: $1 )
} )

print( "Part2:", part2 )


var history: [ TestStep ] = []
var start = unscrambled

for line in input.split(separator: "\n") {
    let next = scrambleStep( start: start, operation: line )
    
    history.append( ( start: start, operation: String(line), result: next ) )
}

for step in history.reversed() {
    let next = unscrambleStep(start: step.result, operation: step.operation )
    
    if next != step.start {
        print( "History unscramble failure on:", step.operation )
        print( "Started with \(step.result), expected \(step.start), got \(next)" )
        exit(1)
    }
}
