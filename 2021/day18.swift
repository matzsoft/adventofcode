//
//         FILE: main.swift
//  DESCRIPTION: day18 - Snailfish
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/17/21 21:12:12
//

import Foundation

enum RunType: String { case parse, explode, reduce, add, magnitude, homework }

enum SnailfishElement: CustomStringConvertible {
    case leftBracket, rightBracket, comma, number( Int )
    
    var description: String {
        switch self {
        case .leftBracket:
            return "["
        case .rightBracket:
            return "]"
        case .comma:
            return ","
        case .number(let int):
            return "\(int)"
        }
    }
}

class SnailfishNumber: CustomStringConvertible {
    enum ParseState { case initial, lhs, needComma, rhs, needClose, final }
    var contents: [SnailfishElement]
    
    var description: String { contents.map { "\($0)" }.joined() }
    var magnitude: Int {
        let tree = try! SnailfishTree( number: self )
        return tree.magnitude
    }
    
    init( contents: [SnailfishElement] ) {
        self.contents = contents
    }
    
    init( line: String ) throws {
        var state = ParseState.initial
        var depth = 0
        var depthStack = [Int]()
        
        contents = []
        for ( index, character ) in line.enumerated() {
            switch state {
            case .initial:
                guard character == "[" else {
                    throw RuntimeError( "Invalid initial character \(character)." ) }
                contents.append( .leftBracket )
                state = .lhs
                depth += 1
            case .lhs:
                switch character {
                case "[":
                    contents.append( .leftBracket )
                    depth += 1
                case "0" ... "9":
                    contents.append( .number( Int( String( character ) )! ) )
                    state = .needComma
                default:
                    throw RuntimeError( "Unexpected character \(character) at index \(index)." )
                }
            case .needComma:
                guard character == "," else {
                    throw RuntimeError( "Missing comma \(character) at index \(index)." ) }
                contents.append( .comma )
                state = .rhs
            case .rhs:
                switch character {
                case "[":
                    contents.append( .leftBracket )
                    state = .lhs
                    depthStack.append( depth )
                    depth += 1
                case "0" ... "9":
                    contents.append( .number( Int( String( character ) )! ) )
                    state = .needClose
                default:
                    throw RuntimeError( "Unexpected character \(character) at index \(index)." )
                }
            case .needClose:
                guard character == "]" else {
                    throw RuntimeError( "Missing close \(character) at index \(index)." ) }
                contents.append( .rightBracket )
                depth -= 1
                if depth == 0 {
                    state = .final
                } else if let last = depthStack.last {
                    if depth > last {
                        state = .needComma
                    } else {
                        depthStack.removeLast()
                    }
                } else {
                    state = .needComma
                }
            case .final:
                throw RuntimeError( "Excess character(s) \(character) at index \(index)." )
            }
        }
        if state != .final {
            throw RuntimeError( "Unbalanced brackets." )
        }
    }
    
    func explode() -> Bool {
        var leftNumber: Int?
        var depth = 0
        var explodeIndex: Int?
        var rightSide: Int?
        
        LOOP:
        for index in contents.indices {
            switch contents[index] {
            case .leftBracket:
                depth += 1
                if depth > 4 {
                    // explode here
                    if case let .number(left) = contents[index+1] {
                        if let leftNumber = leftNumber {
                            if case let .number(number) = contents[leftNumber] {
                                contents[leftNumber] = .number( number + left )
                            }
                        }
                    }
                    if case let .number(right) = contents[index+3] {
                        rightSide = right
                    }
                    contents[index] = SnailfishElement.number( 0 )
                    contents.removeSubrange( index + 1 ... index + 4 )
                    explodeIndex = index + 1
                    break LOOP
                }
            case .number( _ ):
                leftNumber = index
            case .comma:
                break
            case .rightBracket:
                depth -= 1
            }
        }
        
        if let explodeIndex = explodeIndex, let rightSide = rightSide {
            for index in explodeIndex ..< contents.count {
                if case let .number(number) = contents[index] {
                    contents[index] = .number( rightSide + number )
                    break
                }
            }
        }
        
        return explodeIndex != nil
    }
    
    func split() -> Bool {
        for index in contents.indices {
            if case let .number(number) = contents[index], number > 9 {
                let pair = [
                    SnailfishElement.leftBracket,
                    .number( number / 2 ),
                    .comma,
                    .number( ( number + 1 ) / 2 ),
                    .rightBracket
                ]
                contents.remove( at: index )
                contents.insert( contentsOf: pair, at: index )
                return true
            }
        }
        
        return false
    }
    
    func reduce() -> Void {
        while true {
            if explode() { continue }
            if !split()  { break }
        }
    }
    
    func add( rhs: SnailfishNumber ) -> SnailfishNumber {
        let result = SnailfishNumber(
            contents: [ .leftBracket ] + contents + [ .comma ] + rhs.contents + [ .rightBracket ]
        )
        result.reduce()
        return result
    }
}

struct SnailfishTree: CustomStringConvertible {
    let left: SnailfishNode
    let right: SnailfishNode
    
    var description: String { "[\(left),\(right)]" }
    var magnitude: Int { 3 * left.magnitude + 2 * right.magnitude }

    init( number: SnailfishNumber ) throws {
        var index = 0
        try self.init( elements: number.contents, index: &index )
    }
    
    init( elements: [SnailfishElement], index: inout Int ) throws {
        guard case .leftBracket = elements[index] else { throw RuntimeError( "Unexpected parse error 1." ) }
        
        index += 1
        switch elements[index] {
        case .leftBracket:
            left = SnailfishNode.Snailfish( try SnailfishTree( elements: elements, index: &index ) )
        case .number( let int ):
            left = SnailfishNode.regular( int )
            index += 1
        default:
            throw RuntimeError( "Unexpected parse error 2." )
        }
        
        guard case .comma = elements[index] else { throw RuntimeError( "Unexpected parse error 3." ) }

        index += 1
        switch elements[index] {
        case .leftBracket:
            right = SnailfishNode.Snailfish( try SnailfishTree( elements: elements, index: &index ) )
        case .number( let int ):
            right = SnailfishNode.regular( int )
            index += 1
        default:
            throw RuntimeError( "Unexpected parse error 4." )
        }

        guard case .rightBracket = elements[index] else { throw RuntimeError( "Unexpected parse error 1." ) }
        index += 1
    }
}

indirect enum SnailfishNode: CustomStringConvertible {
    case regular( Int )
    case Snailfish( SnailfishTree )

    var description: String {
        switch self {
        case .regular( let regular ):
            return "\(regular)"
        case .Snailfish( let snailfishNumber ):
            return "\(snailfishNumber)"
        }
    }
    
    var magnitude: Int {
        switch self {
        case .regular( let int ):
            return int
        case .Snailfish( let snailfishTree ):
            return snailfishTree.magnitude
        }
    }
}


func parse( input: AOCinput ) -> ( RunType, [SnailfishNumber] ) {
    let runtype = RunType( rawValue: input.extras[0] )!
    
    return ( runtype, input.lines.map { try! SnailfishNumber( line: $0 ) } )
}


func part1( input: AOCinput ) -> String {
    let ( runtype, numbers ) = parse( input: input )
    
    switch runtype {
    case .parse:
        let strings = numbers.map { "\($0)" }
        let zipped = zip( input.lines, strings )
        var count = 0
        
        for ( original, parsed ) in zipped {
            if original == parsed { count += 1 }
        }
//        let correctCount = zipped.reduce( 0 ) { $0 += ( $1.0 != $1.1 ? 0 : 1 ) }
        return "\(count)"
    case .explode:
        if numbers[0].explode() {
            return "\(numbers[0])"
        }
        return "No explosion required"
    case .reduce:
        numbers[0].reduce()
        return "\(numbers[0])"
    case .add:
        var sum: SnailfishNumber?
        
        for number in numbers {
            if sum == nil {
                sum = number
            } else {
                sum = sum!.add( rhs: number )
            }
        }
        return "\(sum!)"
    case .magnitude:
        return "\( numbers[0].magnitude )"
    case .homework:
        var sum: SnailfishNumber?
        
        for number in numbers {
            if sum == nil {
                sum = number
            } else {
                sum = sum!.add( rhs: number )
            }
        }
        return "\(sum!.magnitude)"
    }
}


func part2( input: AOCinput ) -> String {
    let something = parse( input: input )
    return "Not yet implemented"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
