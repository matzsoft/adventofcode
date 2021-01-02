//
//  main.swift
//  day23
//
//  Created by Mark Johnson on 12/23/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

struct Circle {
    struct Cup {
        let clockwise: Int
    }
    
    var circle: [Cup]
    var current: Int
    
    init( size: Int, input: String ) {
        let numbers = input.map { Int( String( $0 ) )! }
        let biggest = numbers.max()!
        var lastCup = 0
        
        guard biggest <= size else {
            print( "Bad init of Circle, \(biggest) is greater than \(size)." )
            exit( 0 )
        }
        
        circle = Array( repeating: Cup( clockwise: 0 ), count: size + 1 )
        for number in numbers {
            circle[number] = circle[lastCup]
            circle[lastCup] = Cup( clockwise: number )
            lastCup = number
        }
        
        if biggest == size {
            circle[lastCup] = circle[0]
        } else {
            circle[lastCup] = Cup( clockwise: biggest + 1 )
            for number in ( biggest + 1 ) ..< size {
                circle[number] = Cup( clockwise: number + 1 )
            }
            circle[size] = circle[0]
        }
        current = circle[0].clockwise
    }
    
    var normalized: String {
        var last = circle[1].clockwise
        var cups: [Int] = []
        
        while last != 1 {
            cups.append( last )
            last = circle[last].clockwise
        }
        
        return cups.map { String( $0 ) }.joined()
    }

    mutating func remove( after: Int, count: Int ) -> Int {
        let first = circle[after].clockwise
        let last = ( 1 ..< count ).reduce( first, { current, _ in circle[current].clockwise } )

        circle[after] = circle[last]
        circle[last] = Cup( clockwise: 0 )
        
        return first
    }

    mutating func insert( after: Int, head: Int ) -> Void {
        var last = head
        
        while circle[last].clockwise != 0 { last = circle[last].clockwise }
        circle[last] = circle[after]
        circle[after] = Cup( clockwise: head )
    }
    
    func makeSet( head: Int ) -> Set<Int> {
        var set = Set<Int>()
        var last = head
        
        while last != 0 { set.insert(last); last = circle[last].clockwise }
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
        current = circle[current].clockwise
    }
}


func part1( circle: Circle ) -> String {
    var circle = circle
    
    for roundNumber in 1 ... 100 {
        circle.round( roundNumber: roundNumber )
    }
    return circle.normalized
}


func part2( circle: Circle ) -> Int {
    var circle = circle
    
    for roundNumber in 1 ... 10000000 {
        circle.round( roundNumber: roundNumber )
    }
    
    let cup1 = circle.circle[1].clockwise
    let cup2 = circle.circle[cup1].clockwise
    return cup1 * cup2
}


let inputFile = "/Users/markj/Development/adventofcode/2020/input/day23.txt"
let input = try String( contentsOfFile: inputFile ).replacingOccurrences( of: "\n", with: "" )
//let input = "389125467"

print( "Part 1: \( part1( circle: Circle( size: 9, input: input ) ) )" )
print( "Part 2: \( part2( circle: Circle( size: 1000000, input: input ) ) )" )
