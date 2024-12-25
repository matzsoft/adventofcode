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

extension DirectionUDLR {
    static func breakdown( vector: Point2D ) -> [ ( Int, DirectionUDLR ) ] {
        [
            ( abs( vector.x ), vector.x < 0 ? .left : .right ),
            ( abs( vector.y ), vector.y < 0 ? .up : .down )
        ]
    }
}


func point( _ x: Int, _ y: Int ) -> Point2D {
    Point2D( x: x, y: y )
}



func xDirection( _ xVector: Point2D ) -> String {
    let magnitude = abs( xVector.x )
    
    if xVector.x < 0 {
        return String( repeating: DirectionUDLR.left.toArrow, count: magnitude )
    }
    return String( repeating: DirectionUDLR.right.toArrow, count: magnitude )
}


func yDirection( _ yVector: Point2D ) -> String {
    let magnitude = abs( yVector.y )
    
    if yVector.y < 0 {
        return String( repeating: DirectionUDLR.up.toArrow, count: magnitude )
    }
    return String( repeating: DirectionUDLR.down.toArrow, count: magnitude )
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
    
    func directions( target: String ) -> [String] {
        var position = buttons["A"]!
        let vectors = target.reduce( into: [[Point2D]]() ) { vectors, button in
            var result = [Point2D]()
            let vector = buttons[button]! - position
            let xVector = Point2D( x: vector.x, y: 0 )
            let yVector = Point2D( x: 0, y: vector.y )

            if vector.x == 0 {
                if vector.y != 0 {
                    result.append( yVector )
                }
            } else if vector.y == 0 {
                result.append( xVector )
            } else if position + xVector == gap {
                result.append( contentsOf: [ yVector, xVector ] )
            } else if position + yVector == gap {
                result.append( contentsOf: [ xVector, yVector ] )
            } else {
                result.append( contentsOf: [ xVector, yVector, yVector, xVector ] )
            }
            
            vectors.append( result )
            position = buttons[button]!
        }
        let strings = vectors.reduce( into: [""] ) { strings, vectors in
            switch vectors.count {
            case 0:
                strings = strings.map { $0 + "A" }
            case 1:
                if vectors[0].y == 0 {
                    strings = strings.map { $0 + xDirection( vectors[0] ) + "A" }
                } else {
                    strings = strings.map { $0 + yDirection( vectors[0] ) + "A" }
                }
            case 2:
                if vectors[0].y == 0 {
                    strings = strings.map {
                        $0 + xDirection( vectors[0] ) + yDirection( vectors[1] ) + "A"
                    }
                } else {
                    strings = strings.map {
                        $0 + yDirection( vectors[0] ) + xDirection( vectors[1] ) + "A"
                    }
                }
            case 4:
                let front = strings.map {
                    $0 + xDirection( vectors[0] ) + yDirection( vectors[1] ) + "A"
                }
                let back  = strings.map {
                    $0 + yDirection( vectors[1] ) + xDirection( vectors[0] ) + "A"
                }
                strings = front + back
            default:
                fatalError( "Oingo Boingo" )
            }
        }
        
        return strings
    }
}


func parse( input: AOCinput ) -> Any? {
    return nil
}


func part1( input: AOCinput ) -> String {
    let something = parse( input: input )
    let keypad0 = Keypad( .numeric )
    let keypad1 = Keypad( .directional )
    let keypad2 = Keypad( .directional )
    
    let first = input.lines.map { keypad0.directions( target: $0 ) }
    let second = first.map { $0.flatMap { keypad1.directions( target: $0 ) } }
    let third = second.map { $0.flatMap { keypad2.directions( target: $0 ) } }
    let shortests = third.map { $0.map { $0.count }.min()! }
    let numericParts = input.lines.map {
        Int( String( $0.filter { $0.isNumber } ) )!
    }
    let total = shortests.indices.reduce( 0 ) {
        $0 + shortests[$1] * numericParts[$1]
    }
    return "\(total)"
}


func part2( input: AOCinput ) -> String {
    let something = parse( input: input )
    let numeric = Keypad( .numeric )
    let directional = Keypad( .directional )
    
    let first = input.lines.map { numeric.directions( target: $0 ) }
    let robots = ( 1 ... 25 ).reduce( into: [first] ) { robots, _ in
        robots.append( robots.last!.map {
            $0.flatMap { directional.directions( target: $0 ) }
        } )
    }
    let shortests = robots.last!.map { $0.map { $0.count }.min()! }
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
