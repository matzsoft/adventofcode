//
//         FILE: main.swift
//  DESCRIPTION: day20 - Grove Positioning System
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/19/22 23:32:28
//

import Foundation

struct Entry {
    let value: Int
    var left: Int
    var right: Int
}


struct List {
    var entries: [Entry]
    
    init( lines: [String] ) {
        entries = lines.enumerated().map {
            let left = ( $0.offset - 1 + lines.count ) % lines.count
            let right = ( $0.offset + 1 ) % lines.count
            return Entry( value: Int( $0.element )!, left: left, right: right )
        }
    }
    
    mutating func mix() -> Void {
        for index in entries.indices {
            if entries[index].value < 0 {
                let onLeft = ( entries[index].value ..< 1 ).reduce( index ) { old, _ in entries[old].left }
                
                move( at: index, to: onLeft )
            } else if entries[index].value > 0 {
                let onLeft = ( 0 ..< entries[index].value ).reduce( index ) { old, _ in entries[old].right }
                
                move( at: index, to: onLeft )
            }
        }
    }
    
    mutating func move( at index: Int, to onLeft: Int ) -> Void {
        let onRight = entries[onLeft].right
        
        entries[entries[index].left].right = entries[index].right
        entries[entries[index].right].left = entries[index].left
        
        entries[onLeft].right = index
        entries[onRight].left = index
        entries[index].left = onLeft
        entries[index].right = onRight
    }
    
    func nextRight( entry: Entry, by: Int ) -> Entry {
        ( 1 ... by ).reduce( entry ) { old, _ in entries[old.right] }
    }
}


func parse( input: AOCinput ) -> List {
    return List( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    var initial = parse( input: input )

    initial.mix()
    let zero = initial.entries.first( where: { $0.value == 0 } )!
    let first = initial.nextRight( entry: zero, by: 1000 )
    let second = initial.nextRight( entry: first, by: 1000 )
    let third = initial.nextRight( entry: second, by: 1000 )
    return "\( first.value + second.value + third.value )"
}


func part2( input: AOCinput ) -> String {
    let something = parse( input: input )
    return ""
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
