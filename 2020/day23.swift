//
//         FILE: main.swift
//  DESCRIPTION: day23 - Crab Cups
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/01/21 10:27:39
//

import Foundation
import Library

// Implemented as a singly linked, circular list with the head pointer stored in element zero of the array.
struct Circle {
    var circle: [Int]
    var current: Int
    
    init( size: Int, input: String ) throws {
        let numbers = input.map { Int( String( $0 ) )! }
        let starters = [ 0 ] + numbers + [ numbers[0] ]
        let biggest = numbers.max()!
        
        guard biggest <= size else {
            throw RuntimeError( "Bad init of Circle, \(biggest) is greater than \(size)." )
        }
        
        circle = ( 0 ... numbers.count ).reduce( into: Array( repeating: 0, count: numbers.count + 1 ) ) {
            array, index in array[ starters[index] ] = starters[ index + 1 ]
        }
        if biggest < size {
            circle += ( biggest + 2 ... size ).map( { $0 } ) + [ circle[0] ]
            circle[ numbers.last! ] = biggest + 1
        }
        current = circle[0]
    }
    
    var normalized: String {
        var last = circle[1]
        var cups: [Int] = []
        
        while last != 1 {
            cups.append( last )
            last = circle[last]
        }
        
        return cups.map { String( $0 ) }.joined()
    }

    mutating func remove( after: Int, count: Int ) -> Int {
        let first = circle[after]
        let last = ( 1 ..< count ).reduce( first, { current, _ in circle[current] } )

        circle[after] = circle[last]
        circle[last] = 0
        
        return first
    }

    mutating func insert( after: Int, head: Int ) -> Void {
        var last = head
        
        while circle[last] != 0 { last = circle[last] }
        circle[last] = circle[after]
        circle[after] = head
    }
    
    func makeSet( head: Int ) -> Set<Int> {
        var set = Set<Int>()
        var last = head
        
        while last != 0 { set.insert(last); last = circle[last] }
        return set
    }
    
    mutating func round( roundNumber: Int ) -> Void {
        let removed = remove( after: current, count: 3 )
        let set = makeSet( head: removed )
        var destination = current == 1 ? circle.count - 1 : current - 1
        
        while set.contains( destination ) {
            destination = destination == 1 ? circle.count - 1 : destination - 1
        }
        
        insert( after: destination, head: removed )
        current = circle[current]
    }
}


func part1( input: AOCinput ) -> String {
    var circle = try! Circle( size: input.line.count, input: input.line )
    
    for roundNumber in 1 ... 100 {
        circle.round( roundNumber: roundNumber )
    }
    
    return circle.normalized
}


func part2( input: AOCinput ) -> String {
    var circle = try! Circle( size: 1000000, input: input.line )
    
    for roundNumber in 1 ... 10000000 {
        circle.round( roundNumber: roundNumber )
    }
    
    let cup1 = circle.circle[1]
    let cup2 = circle.circle[cup1]

    return "\( cup1 * cup2 )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
