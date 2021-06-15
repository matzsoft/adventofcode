//
//         FILE: main.swift
//  DESCRIPTION: day21 - Scrambled Letters and Hash
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/08/21 23:39:58
//

import Foundation

protocol Operation {
    func forward( unscrambled: String ) -> String
    func reverse( scrambled: String ) -> String
}

struct Swap: Operation {
    enum SwapType { case position, letter }
    let type:      SwapType
    let argumentX: String
    let argumentY: String
    
    init<T: StringProtocol>( words: [T] ) {
        switch words[1] {
        case "position":
            type = .position
        case "letter":
            type = .letter
        default:
            print( "Swap parse error on:", words.joined( separator: " " ) )
            exit(1)
        }
        argumentX = String( words[2] )
        argumentY = String( words[5] )
    }

    func forward( unscrambled: String ) -> String {
        switch type {
        case .position:
            let positionX = Int( argumentX )!
            let positionY = Int( argumentY )!
            
            return swapPosition( unscrambled: unscrambled, offset1: positionX, offset2: positionY )
        case .letter:
            return swapLetter( unscrambled: unscrambled, letter1: argumentX, letter2: argumentY )
        }
    }
    
    func reverse( scrambled: String ) -> String {
        return forward( unscrambled: scrambled )
    }
    
    func swapPosition( unscrambled: String, offset1: Int, offset2: Int ) -> String {
        var result = unscrambled
        let firstIndex = result.index( result.startIndex, offsetBy: min( offset1, offset2 ) )
        let lastIndex = result.index( result.startIndex, offsetBy: max( offset1, offset2 ) )
        let lastChar = result.remove( at: lastIndex )
        let firstChar = result.remove( at: firstIndex )
        
        result.insert( lastChar, at: firstIndex )
        result.insert( firstChar, at: lastIndex )
        return result
    }

    func swapLetter( unscrambled: String, letter1: String, letter2: String ) -> String {
        var result = unscrambled
        let char1 = Character( letter1 )
        let char2 = Character( letter2 )
        let index1 = result.firstIndex { $0 == char1 }!
        let index2 = result.firstIndex { $0 == char2 }!

        result.remove( at: index1 )
        result.insert( char2, at: index1 )
        result.remove( at: index2 )
        result.insert( char1, at: index2 )
        return result
    }
}

struct Rotate: Operation {
    enum RotateType { case left, right, based }
    let type:     RotateType
    let argument: String
    
    init<T: StringProtocol>( words: [T] ) {
        switch words[1] {
        case "left":
            type = .left
            argument = String( words[2] )
        case "right":
            type = .right
            argument = String( words[2] )
        case "based":
            type = .based
            argument = String( words[6] )
        default:
            print( "Rotate parse error on:", words.joined( separator: " " ) )
            exit(1)
        }
    }

    func forward( unscrambled: String ) -> String {
        switch type {
        case .left:
            let steps = Int( argument )!
            
            return rotateLeft( start: unscrambled, steps: steps )
        case .right:
            let steps = Int( argument )!
            
            return rotateRight( start: unscrambled, steps: steps )
        case .based:
            let char = Character( argument )
            let index = unscrambled.firstIndex { $0 == char }!
            let offset = unscrambled.distance( from: unscrambled.startIndex, to: index )
            
            return rotateRight( start: unscrambled, steps: offset < 4 ? offset + 1 : offset + 2 )
        }
    }
    
    func reverse( scrambled: String ) -> String {
        switch type {
        case .left:
            let steps = Int( argument )!
            
            return rotateRight( start: scrambled, steps: steps )
        case .right:
            let steps = Int( argument )!
            
            return rotateLeft( start: scrambled, steps: steps )
        case .based:
            let char = Character( argument )
            let index = scrambled.firstIndex { $0 == char }!
            let newOffset = scrambled.distance( from: scrambled.startIndex, to: index )
            
            if newOffset & 1 == 1 {
                return rotateLeft( start: scrambled, steps: ( newOffset + 1 ) / 2 )
            }
            
            if newOffset - 2 < 0 {
                return rotateLeft( start: scrambled, steps: ( newOffset + 2 ) / 2 )
            }
            
            return rotateLeft( start: scrambled, steps: ( newOffset + scrambled.count + 3 ) / 2 )
        }
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
}

struct Reverse: Operation {
    let positionX: Int
    let positionY: Int
    
    init<T: StringProtocol>( words: [T] ) {
        positionX = Int( words[2] )!
        positionY = Int( words[4] )!
    }

    func forward( unscrambled: String ) -> String {
        return reverse( start: unscrambled, firstOffset: positionX, lastOffset: positionY )
    }
    
    func reverse( scrambled: String ) -> String {
        return reverse( start: scrambled, firstOffset: positionX, lastOffset: positionY )
    }
    
    func reverse( start: String, firstOffset: Int, lastOffset: Int ) -> String {
        let first = start.index( start.startIndex, offsetBy: firstOffset )
        let last = start.index( start.startIndex, offsetBy: lastOffset )
        let prefix = String( start.prefix( firstOffset ) )
        let middle = String( start[ first ... last ].reversed() )
        let suffix = String( start.suffix( start.count - lastOffset - 1 ) )
        
        return prefix + middle + suffix
    }
}

struct Move: Operation {
    let positionX: Int
    let positionY: Int
    
    init<T: StringProtocol>( words: [T] ) {
        positionX = Int( words[2] )!
        positionY = Int( words[5] )!
    }

    func forward( unscrambled: String ) -> String {
        return move( start: unscrambled, firstOffset: positionX, lastOffset: positionY )
    }
    
    func reverse( scrambled: String ) -> String {
        return move( start: scrambled, firstOffset: positionY, lastOffset: positionX )
    }

    func move( start: String, firstOffset: Int, lastOffset: Int ) -> String {
        var result = start
        let char = result.remove( at: result.index( result.startIndex, offsetBy: firstOffset ) )
        
        result.insert( char, at: result.index( result.startIndex, offsetBy: lastOffset ) )
        return result
    }
}


func parse( input: AOCinput ) -> [Operation] {
    return input.lines.map { ( line ) -> Operation in
        let words = line.split( separator: " " )
        
        switch words[0] {
        case "swap":
            return Swap( words: words )
        case "rotate":
            return Rotate( words: words )
        case "reverse":
            return Reverse( words: words )
        case "move":
            return Move( words: words )
        default:
            print( "First word parse error on:", line )
            exit(1)
        }
    }
}


func part1( input: AOCinput ) -> String {
    let operations = parse( input: input )
    let result = operations.reduce( "abcdefgh", { $1.forward( unscrambled: $0 ) } )
    return "\(result)"
}


func part2( input: AOCinput ) -> String {
    let operations = parse( input: input ).reversed()
    let result = operations.reduce( "fbgdceah", { $1.reverse( scrambled: $0 ) } )
    return "\(result)"
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
