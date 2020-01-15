//
//  main.swift
//  day24
//
//  Created by Mark Johnson on 12/23/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

struct Bugs {
    let grid: [[Int]]
    
    init<T: StringProtocol>( input: T ) {
        grid = input.split( separator: "\n" ).map { $0.map { $0 == "#" ? 1 : 0 } }
    }
    
    init( grid: [[Int]] ) {
        self.grid = grid
    }
    
    var width: Int { return grid[0].count }
    var height: Int { return grid.count }

    var asString: String {
        return grid.map { $0.map { $0 == 0 ? "." : "#" }.joined() }.joined( separator: "\n" )
    }
    var biodiversity: Int {
        grid.reversed().reduce( 0, { $0 << 5 + $1.reversed().reduce( 0, { $0 << 1 | $1 } ) } )
    }
    
    func neighborCount( x: Int, y: Int ) -> Int {
        var sum = 0
        
        if x > 0 { sum += grid[y][x-1] }
        if x < width - 1 { sum += grid[y][x+1] }
        if y > 0 { sum += grid[y-1][x] }
        if y < height - 1 { sum += grid[y+1][x] }
        
        return sum
    }
    
    var nextMinute: Bugs {
        let grid = ( 0 ..< height ).map { y in ( 0 ..< width).map { x -> Int in
            let neighbors = neighborCount( x: x, y: y )
            if self.grid[y][x] == 1 {
                if neighbors != 1 { return 0 }
            } else {
                if neighbors == 1 || neighbors == 2 { return 1 }
            }
            return self.grid[y][x]
            } }
        return Bugs( grid: grid )
    }
}

struct BugsLevel {
    let grid: [[Int]]

    init<T: StringProtocol>( input: T ) {
        grid = input.split( separator: "\n" ).map { $0.map { $0 == "#" ? 1 : 0 } }
    }
    
    init( grid: [[Int]] ) {
        self.grid = grid
    }
    
    init( width: Int, height: Int ) {
        grid = Array( repeating: Array( repeating: 0, count: width ), count: height )
    }
    
    var width: Int { return grid[0].count }
    var height: Int { return grid.count }
    var midX: Int { width / 2 }
    var midY: Int { height / 2 }

    var asString: String {
        return grid.map { $0.map { $0 == 0 ? "." : "#" }.joined() }.joined( separator: "\n" )
    }
    var biodiversity: Int {
        grid.reversed().reduce( 0, { $0 << 5 + $1.reversed().reduce( 0, { $0 << 1 | $1 } ) } )
    }
    var bugCount: Int {
        grid.reduce( 0, { $0 + $1.reduce( 0, { $0 + $1 } ) } )
    }
    
    func rowCount( row: Int ) -> Int {
        return grid[row].reduce( 0, { $0 + $1 } )
    }
    
    func colCount( col: Int ) -> Int {
        return grid.reduce( 0, { $0 + $1[col] } )
    }
    
    func neighborCount( x: Int, y: Int, upLevel: BugsLevel, downLevel: BugsLevel ) -> Int {
        guard x != midX || y != midY else { return 0 }      // Center square warps to higher level
        var sum = 0
        
        // Left neighbor
        if x == 0 { sum += downLevel.grid[midY][midX-1] }
        else if x == midX + 1 && y == midY { sum += upLevel.colCount( col: width - 1 ) }
        else { sum += grid[y][x-1] }
        
        // Right neighbor
        if x == width - 1 { sum += downLevel.grid[midY][midX+1] }
        else if x == midX - 1 && y == midY { sum += upLevel.colCount( col: 0 ) }
        else { sum += grid[y][x+1] }
        
        // Top neighbor
        if y == 0 { sum += downLevel.grid[midY-1][midX] }
        else if x == midX && y == midY + 1 { sum += upLevel.rowCount( row: height - 1 ) }
        else { sum += grid[y-1][x] }
        
        // Bottom neighbor
        if y == height - 1 { sum += downLevel.grid[midY+1][midX] }
        else if x == midX && y == midY - 1 { sum += upLevel.rowCount( row: 0 ) }
        else { sum += grid[y+1][x] }
        
        return sum
    }
    
    func nextMinute( upLevel: BugsLevel, downLevel: BugsLevel ) -> BugsLevel {
        let grid = ( 0 ..< height ).map { y in ( 0 ..< width).map { x -> Int in
            let neighbors = neighborCount( x: x, y: y, upLevel: upLevel, downLevel: downLevel )
            if self.grid[y][x] == 1 {
                if neighbors != 1 { return 0 }
            } else {
                if neighbors == 1 || neighbors == 2 { return 1 }
            }
            return self.grid[y][x]
            } }
        return BugsLevel( grid: grid )
    }
}

func BugsMultiverse<T: StringProtocol>( input: T, minutes: Int ) -> Int {
    let offset = ( minutes + 3 ) / 2
    let level0 = BugsLevel( input: input )
    let empty = BugsLevel( width: level0.width, height: level0.height )
    var verse = Array( repeating: empty, count: 2 * offset + 1 )
    
    verse[offset] = level0
    for _ in 1 ... minutes {
        var nextVerse = [ empty ]
        
        for index in 1 ... 2 * offset - 1 {
            let evolution = verse[index].nextMinute( upLevel: verse[index+1], downLevel: verse[index-1] )
            
            nextVerse.append( evolution )
        }
        nextVerse.append( empty )
        verse = nextVerse
    }
    
    return verse.reduce( 0, { $0 + $1.bugCount } )
}


guard CommandLine.arguments.count > 1 else {
    print( "No input file specified" )
    exit( 1 )
}

let input = try String( contentsOfFile: CommandLine.arguments[1] ).dropLast( 1 )
let bugs = Bugs( input: input )

print( bugs.asString )

var evolution = bugs
var seen = Set<Int>( [ evolution.biodiversity ] )

while true {
    evolution = evolution.nextMinute
    if seen.contains( evolution.biodiversity ) {
        break
    }
    seen.insert( evolution.biodiversity )
}

print( "Part 1: \( evolution.biodiversity )" )
print( "Part 2: \( BugsMultiverse( input: input, minutes: 200 ) )" )
