//
//  main.swift
//  day23
//
//  Created by Mark Johnson on 12/27/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

struct Position {
    var x: Int
    var y: Int
    var z: Int
    
    static func ==( left: Position, right: Position ) -> Bool {
        return left.x == right.x && left.y == right.y && left.z == right.z
    }
    
    static func +( left: Position, right: Position ) -> Position {
        return Position(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
    }
    
    func distance( other: Position ) -> Int {
        return abs( other.x - x ) + abs( other.y - y ) + abs( other.z - z )
    }
}

struct Nanobot {
    let position: Position
    let radius: Int
    
    init( input: Substring ) {
        let words = input.split( whereSeparator: { "<>,=".contains($0) } )
        
        position = Position( x: Int( words[1] )!, y: Int( words[2] )!, z: Int( words[3] )! )
        radius = Int( words[5] )!
    }
    
    func intersect( other: Nanobot ) -> Bool {
        let distance = position.distance(other: other.position)
        
        return distance <= radius + other.radius
    }
}

func parse( input: String ) throws -> [Nanobot] {
    return try String( contentsOfFile: input ).split( separator: "\n" ).map { Nanobot( input: $0 ) }
}

func part1( bots: [Nanobot] ) -> Int {
    let strongest = bots.max( by: { $0.radius < $1.radius } )!
    let inRange = bots.filter { strongest.position.distance(other: $0.position) <= strongest.radius }
    
    return inRange.count
}

// Somewhat of a cheat - adapted from a Python program in the subreddit.
// Also will probably not work for all inputs.
func part2( bots: [Nanobot] ) -> Int {
    var queue: [ ( d:Int, e: Int ) ] = []
    
    for bot in bots {
        let distance = bot.position.distance(other: Position(x: 0, y: 0, z: 0))
        
        queue.append( ( d: max( 0, distance - bot.radius ), e: 1 ) )
        queue.append( ( d: distance + bot.radius + 1, e: -1 ) )
    }
    
    var count = 0
    var maxCount = 0
    var result = 0
    
    queue.sort(by: { $0.d < $1.d } )
    while let entry = queue.first {
        queue.removeFirst()
        count += entry.e
        if count > maxCount {
            result = entry.d
            maxCount = count
        }
    }
    
    return result
}


let test1Bots = try parse( input: "/Users/markj/Development/adventofcode/2018/input/day23T1.txt" )
let test2Bots = try parse( input: "/Users/markj/Development/adventofcode/2018/input/day23T2.txt" )
let inputBots = try parse( input: "/Users/markj/Development/adventofcode/2018/input/day23.txt" )

print( "Test1:", part1( bots: test1Bots ) )
print( "Test2:", part1( bots: test2Bots ) )
print( "Part1:", part1( bots: inputBots ) )

print( "Test1:", part2( bots: test1Bots ) )
print( "Test2:", part2( bots: test2Bots ) )
print( "Part2:", part2( bots: inputBots ) )

/*
var pairs = Array(repeating: Set<Int>(), count: inputBots.count)

for i in 0 ..< inputBots.count - 1 {
    pairs[i].insert(i)
    for j in i ..< inputBots.count {
        if inputBots[i].intersect(other: inputBots[j]) {
            pairs[i].insert(j)
            pairs[j].insert(i)
        }
    }
}

pairs.enumerated().forEach { print( "\($0.offset): \($0.element.count)" ) }
*/
