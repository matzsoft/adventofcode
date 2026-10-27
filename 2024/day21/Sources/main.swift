//
//         FILE: day21.swift
//  DESCRIPTION: Advent of Code 2024 Day 21: Keypad Conundrum
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/20/24 22:18:10
//

import Foundation
import Library

func point( _ x: Int, _ y: Int ) -> Point2D {
    Point2D( x: x, y: y )
}

struct Keypad {
    enum KeypadType { case numeric, directional }
    
    let type: KeypadType
    let buttons: [ Character : Point2D ]
    let gap: Point2D
    
    init( _ type: KeypadType ) {
        self.type = type
        switch type {
        case .directional:
            buttons = [
                                  "^" : point(1,0), "A" : point(2,0),
                "<" : point(0,1), "v" : point(1,1), ">" : point(2,1)
            ]
            gap = point(0,0)
        case .numeric:
            buttons = [
                "7" : point(0,0), "8" : point(1,0), "9" : point(2,0),
                "4" : point(0,1), "5" : point(1,1), "6" : point(2,1),
                "1" : point(0,2), "2" : point(1,2), "3" : point(2,2),
                                  "0" : point(1,3), "A" : point(2,3),
            ]
            gap = point(0,3)
        }
    }
    
    func shortestPath( button1: Character, button2: Character ) -> String {
        let position1 = buttons[button1]!
        let position2 = buttons[button2]!
        let vector = position2 - position1
        let ud = vector.y < 0
            ? String( repeating: "^", count: -vector.y )
            : String( repeating: "v", count:  vector.y )
        let lr = vector.x < 0
            ? String( repeating: "<", count: -vector.x )
            : String( repeating: ">", count:  vector.x )
        
        if vector.x > 0 && Point2D( x: position1.x, y: position2.y ) != gap {
            // Safe to move vertically first if heading right and
            // corner point isn't the gap
            return "\(ud)\(lr)A"
        }
        if Point2D( x: position2.x, y: position1.y ) != gap {
            // Safe to move horizontally first if corner point isn't the gap
            return "\(lr)\(ud)A"
        }
        // Must be safe to move vertically first because
        // we can't be in same column as gap.
        return "\(ud)\(lr)A"
    }
    
    func directions( target: String ) -> [String] {
        var previous: Character = "A"
        return target.reduce( into: [String]() ) { strings, button in
            strings.append( shortestPath( button1: previous, button2: button ) )
            previous = button
        }
    }
    
    func frequencies( target: String ) -> [ String : Int ] {
        let directions = directions( target: target )
        return directions.reduce( into: [ String : Int ]() ) {
            $0[ $1, default: 0 ] += 1
        }
    }
    
    func update( previous: [ String : Int ] ) -> [ String : Int ] {
        previous.reduce( into: [ String : Int ]() ) { newDict, entry in
            let directions = frequencies( target: entry.key )
            directions.forEach {
                newDict[ $0.key, default: 0 ] += entry.value * $0.value
            }
        }
    }
}


func part1( input: AOCinput ) -> String {
    let numeric = Keypad( .numeric )
    let directional = Keypad( .directional )

    let first = input.lines.map { numeric.directions( target: $0 ) }
    let second = first.map { directional.directions( target: $0.joined() ) }
    let third = second.map { directional.directions( target: $0.joined() ) }
    let shortests = third.map { $0.joined().count }
    let numericParts = input.lines.map {
        Int( String( $0.filter { $0.isNumber } ) )!
    }
    let total = shortests.indices.reduce( 0 ) {
        $0 + shortests[$1] * numericParts[$1]
    }
    return "\(total)"
}


func part2( input: AOCinput ) -> String {
    let numeric = Keypad( .numeric )
    let directional = Keypad( .directional )
    
    let first = input.lines.map { numeric.frequencies( target: $0 ) }
    let robots = ( 1 ... 25 ).reduce( into: [first] ) { robots, _ in
        let level = robots.last!
        let nextLevel = level.reduce( into: [[ String : Int ]]() ) {
            nextLevel, dict in
            nextLevel.append( directional.update( previous: dict ) )
        }
        robots.append( nextLevel )
    }

    let shortests = robots.last!
        .map { $0.reduce( 0 ) { $0 + $1.key.count * $1.value } }
    let numericParts = input.lines.map {
        Int( String( $0.filter { $0.isNumber } ) )!
    }
    let total = shortests.indices.reduce( 0 ) {
        $0 + shortests[$1] * numericParts[$1]
    }
    return "\(total)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
