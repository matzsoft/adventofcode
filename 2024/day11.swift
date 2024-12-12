//
//         FILE: day11.swift
//  DESCRIPTION: Advent of Code 2024 Day 11: Plutonian Pebbles
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/10/24 21:02:22
//

import Foundation
import Library

extension Int {
    var digitCount: Int {
        if self == 0 { return 1 }
        
        var num = self
        var count = 0
        
        while num != 0 { num /= 10 ; count += 1 }
        return count
    }
}


struct Stone: Hashable {
    let label: Int
    let level: Int
    
    var increment: Stone {
        Stone( label: label, level: level + 1 )
    }
}


struct StoneInfo {
    let blinksTo: [Int]
    var counts: [Int?]
    
    init( label: Int, blinks: Int ) {
        switch label {
        case 0:
            blinksTo = [ 1 ]
        case let n where n.digitCount.isMultiple( of: 2 ):
            let string = String( label )
            let left = string.startIndex ..< string.index( string.startIndex, offsetBy: string.count / 2 )
            let right = string.index( string.startIndex, offsetBy: string.count / 2 ) ..< string.endIndex
            blinksTo = [ Int( string[left] )!, Int( string[right] )! ]
        default:
            blinksTo = [ label * 2024 ]
        }
        counts = [ 1, blinksTo.count ] + Array( repeating: nil, count: blinks - 1 )
    }
}


struct Line: Hashable {
    var stones: [Stone]
    
    init() {
        stones = []
    }

    init( stones: [Stone] ) {
        self.stones = stones
    }
    
    init( line: String ) {
        stones = line.split( separator: " " ).map {
            Stone( label: Int( $0 )!, level: 0 )
        }
    }
    
    mutating func add( stone: Stone ) -> Void {
        stones.append( stone )
    }
}


func blink( stones: [Int], blinks: Int ) -> Int {
    var total = 0
    
    for stone in stones {
        var stones = [ stone ]
        
        for _ in 1 ... blinks {
            var newStones = [Int]()
            
            for stone in stones {
                switch stone {
                case 0:
                    newStones.append( 1 )
                case let n where n.digitCount.isMultiple( of: 2 ):
                    let string = String( stone )
                    let left = string.startIndex ..< string.index( string.startIndex, offsetBy: string.count / 2 )
                    let right = string.index( string.startIndex, offsetBy: string.count / 2 ) ..< string.endIndex
                    newStones.append( Int( string[left] )! )
                    newStones.append( Int( string[right] )! )
                default:
                    newStones.append( stone * 2024 )
                }
            }
            stones = newStones
        }
        total += stones.count
    }
    
    return total
}

func dontBlink( stones: [Int], blinks: Int ) -> Int {
    var stones = stones
    
    for step in 1 ... blinks {
        var newStones = [Int]()
        
        for stone in stones {
            switch stone {
            case 0:
                newStones.append( 1 )
            case let n where n.digitCount.isMultiple( of: 2 ):
                let string = String( stone )
                let left = string.startIndex ..< string.index( string.startIndex, offsetBy: string.count / 2 )
                let right = string.index( string.startIndex, offsetBy: string.count / 2 ) ..< string.endIndex
                newStones.append( Int( string[left] )! )
                newStones.append( Int( string[right] )! )
            default:
                newStones.append( stone * 2024 )
            }
        }
        stones = newStones
    }
    
    return stones.count
}


func build( line: Line, blinks: Int ) -> Int {
    var lines = [ line ]
    var dict = [ Int : StoneInfo ]()
    
    for step in 1 ... blinks {
        var newLine = Line()
        
        for stone in lines[step-1].stones {
            if dict[stone.label] != nil {
                newLine.add( stone: stone.increment )
            } else {
                let info = StoneInfo( label: stone.label, blinks: blinks )
                dict[stone.label] = info
                info.blinksTo.forEach {
                    newLine.add( stone: Stone( label: $0, level: 0 ) )
                }
            }
        }
        lines.append( newLine )
    }
    
    func expansion( stone: Stone ) -> Int {
        guard let info = dict[stone.label] else { return 0 }
        if let count = info.counts[stone.level] { return count }
        
        let count = info.blinksTo.reduce( 0 ) {
            $0 + expansion( stone: Stone( label: $1, level: stone.level - 1 ) )
        }
        
        dict[stone.label]!.counts[stone.level] = count
        return count
    }
    
    return lines[blinks].stones.reduce( 0 ) { $0 + expansion( stone: $1 ) }
}


func wildOne( input: AOCinput ) -> String {
    let line = Line( line: input.line )
    return "\( build( line: line, blinks: 25 ) )"
}


func part1( input: AOCinput ) -> String {
    var stones = input.line.split( separator: " " ).map { Int( $0 )! }
    return "\( dontBlink( stones: stones, blinks: 25 ) )"
}


func part2( input: AOCinput ) -> String {
    var stones = input.line.split( separator: " " ).map { Int( $0 )! }
    return "\( blink( stones: stones, blinks: 75 ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part1: wildOne, label: "trial" )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part1: wildOne, label: "trial" )
try solve( part2: part2 )
