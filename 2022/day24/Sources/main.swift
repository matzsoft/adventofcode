//
//         FILE: main.swift
//  DESCRIPTION: day24 - Blizzard Basin
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/23/22 22:43:17
//

import Foundation
import Library

extension Int {
    func mod( _ by: Int ) -> Int {
        let trial = self % by
        return trial < 0 ? trial + by : trial
    }
}


struct Blizzard {
    let symbol: String
    let position: (Int) -> Point2D
}


struct Blizzards {
    let blizzards: [Blizzard]
    let bounds: Rect2D
    
    init( lines: [String] ) {
        let rows = lines.count - 2
        let cols = lines[0].count - 2
        blizzards = lines.dropFirst().dropLast().enumerated().reduce( into: [Blizzard]() ) {
            array, tuple in
            let ( y, line ) = tuple
            line.dropFirst().dropLast().enumerated().forEach { x, character in
                if let direction = DirectionUDLR.fromArrows( char: String( character ) ) {
                    switch direction {
                    case .up:
                        array.append( Blizzard( symbol: direction.toArrow, position:
                            { ( time: Int ) -> Point2D in Point2D( x: x, y: ( y - time ).mod( rows ) ) }
                        ) )
                    case .down:
                        array.append( Blizzard( symbol: direction.toArrow, position:
                            { ( time: Int ) -> Point2D in Point2D( x: x, y: ( y + time ).mod( rows ) ) }
                        ) )
                    case .left:
                        array.append( Blizzard( symbol: direction.toArrow, position:
                            { ( time: Int ) -> Point2D in Point2D( x: ( x - time ).mod( cols ), y: y ) }
                        ) )
                    case .right:
                        array.append( Blizzard( symbol: direction.toArrow, position:
                            { ( time: Int ) -> Point2D in Point2D( x: ( x + time ).mod( cols ), y: y ) }
                        ) )
                    }
                }
            }
        }
        bounds = Rect2D( min: Point2D( x: 0, y: 0 ), width: cols, height: rows )!
    }
    
    func dump( time: Int ) -> String {
        let prefix = "#." + String( repeating: "#", count: bounds.width ) + "\n"
        let suffix = "\n" + String( repeating: "#", count: bounds.width ) + ".#"
        let lines = Array( repeating: Array( repeating: ".", count: bounds.width ), count: bounds.height )
        let revised = blizzards.reduce( into: lines ) { lines, blizzard in
            let point = blizzard.position( time )
            lines[point.y][point.x] = blizzard.symbol
        }.map { "#" + $0.joined() + "#" }

        return prefix + revised.joined( separator: "\n" ) + suffix
    }
    
    func strike( time: Int, potential: Set<Point2D> ) -> Set<Point2D> {
        var potential = potential
        
        for blizzard in blizzards {
            let test = blizzard.position( time )
            if potential.contains( test ) {
                potential.remove( test )
                if potential.isEmpty { break }
            }
        }
        return potential
    }
    
    func traverse( entry: Point2D, exit: Point2D, time: Int ) -> Int? {
        var possibles = [ Elf( position: entry, time: time ) ]
        
        while true {
            var candidatesSet = Set<Elf>()
            for elf in possibles {
                let next = elf.options( blizzards: self )

                if let solution = next.first( where: { $0.position == exit } ) { return solution.time + 1 }
                candidatesSet.formUnion( next )
            }
            let candidates = candidatesSet
                .sorted { $0.position.distance( other: exit ) < $1.position.distance( other: exit ) }
            guard let bestDistance = candidates.first?.position.distance( other: exit ) else { return nil }
            
            possibles = candidates.filter { $0.position.distance( other: exit ) < bestDistance + 35 }
        }
    }
}

struct Elf: Hashable {
    let position: Point2D
    let time: Int
    
    func options( blizzards: Blizzards ) -> Set<Elf> {
        let potential = DirectionUDLR.allCases
            .map { position + $0.vector }
            .filter { blizzards.bounds.contains( point: $0 ) }
        let actual = blizzards.strike( time: time + 1, potential: Set( potential ).union( [ position ] ) )
        
        return Set( actual.map { Elf( position: $0, time: time + 1 ) } )
    }
}


func part1( input: AOCinput ) -> String {
    let blizzards = Blizzards( lines: input.lines )
    
    guard let time = blizzards.traverse(
        entry: blizzards.bounds.min + DirectionUDLR.up.vector,
        exit: blizzards.bounds.max, time: 0
    ) else { return "No solution" }
    
    return "\(time)"
}


func part2( input: AOCinput ) -> String {
    let blizzards = Blizzards( lines: input.lines )
    
    guard let first = blizzards.traverse(
        entry: blizzards.bounds.min + DirectionUDLR.up.vector,
        exit: blizzards.bounds.max, time: 0
    ) else { return "No solution" }
    
    guard let second = blizzards.traverse(
        entry: blizzards.bounds.max + DirectionUDLR.down.vector,
        exit: blizzards.bounds.min, time: first
    ) else { return "No solution" }
    
    guard let third = blizzards.traverse(
        entry: blizzards.bounds.min + DirectionUDLR.up.vector,
        exit: blizzards.bounds.max, time: second
    ) else { return "No solution" }
    
    return "\(third)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
