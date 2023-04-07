//
//         FILE: main.swift
//  DESCRIPTION: day13 - Distress Signal
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/12/22 21:00:13
//

import Foundation
import Library

infix operator <=> : ComparisonPrecedence
func <=><T: Comparable> (left: T, right: T) -> Int {
  if left < right { return -1 }
  if left > right { return  1 }
  return 0
}

enum Element {
    case number( Int )
    case list( List )
    
    static func <=>( left: Element, right: Element ) -> Int {
        switch left {
        case let .number( leftNumber ):
            switch right {
            case let .number( rightNumber ):
                return leftNumber <=> rightNumber
            case let .list( rightList ):
                return List( element: left ) <=> rightList
            }
        case let .list( leftList ):
            switch right {
            case .number:
                return leftList <=> List( element: right )
            case let .list( rightList ):
                return leftList <=> rightList
            }
        }
    }
}

struct List {
    let endIndex: String.Index?
    let elements: [Element]
    
    init( line: String, index startIndex: String.Index ) {
        guard line[startIndex] == "[" else { fatalError( "List improper start" ) }
        var index = line.index( startIndex, offsetBy: 1 )
        var elements = [Element]()
        
        while index < line.endIndex {
            switch line[index] {
            case "[":
                let list = List( line: line, index: index )
                elements.append( Element.list( list ) )
                index = list.endIndex!
            case "]":
                endIndex = line.index( index, offsetBy: 1 )
                self.elements = elements
                return
            case ",":
                index = line.index( index, offsetBy: 1 )
            default:
                let nextIndex = line[index...].firstIndex( where: { ",]".contains( $0 ) } )!
                let number = Int( String( line[index..<nextIndex] ) )!
                elements.append( Element.number( number ) )
                index = nextIndex
            }
        }
        fatalError( "No end bracket")
    }
    
    init( element: Element ) {
        endIndex = nil
        elements = [ element ]
    }
    
    static func <=>( left: List, right: List ) -> Int {
        let zipped = zip( left.elements, right.elements )
        for ( right, left ) in zipped {
            let order = right <=> left
            if order != 0 { return order }
        }
        return left.elements.count <=> right.elements.count
    }
}

struct Pair {
    let left: List
    let right: List
    
    init( lines: [String] ) {
        left = List( line: lines[0], index: lines[0].startIndex )
        right = List( line: lines[1], index: lines[1].startIndex )
    }
    
    var isRightOrder: Bool {
        ( left <=> right ) < 1
    }
}


func part1( input: AOCinput ) -> String {
    let pairs = input.paragraphs.map { Pair( lines: $0 ) }
    let rightOrder = ( 0 ..< pairs.count ).filter { pairs[$0].isRightOrder }
    return "\( rightOrder.reduce( 0, + ) + rightOrder.count )"
}


func part2( input: AOCinput ) -> String {
    let inputPackets = input.lines.filter { $0 != "" }.map { List( line: $0, index: $0.startIndex ) }
    let dividerStrings = [ "[[2]]", "[[6]]" ]
    let dividerPackets = dividerStrings.map { List( line: $0, index: $0.startIndex ) }
    let packets = ( inputPackets + dividerPackets ).sorted { ( $0 <=> $1 ) < 0 }
    let first = packets.firstIndex { ( $0 <=> dividerPackets[0] ) == 0 }! + 1
    let second = packets.firstIndex { ( $0 <=> dividerPackets[1] ) == 0 }! + 1

    return "\( first * second )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
