//
//         FILE: main.swift
//  DESCRIPTION: day13 - Mine Cart Madness
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/21/21 12:38:53
//

import Foundation
import Library

extension Turn {
    var next: Turn {
        switch self {
        case .left:
            return .straight
        case .straight:
            return .right
        case .right:
            return .left
        case .back:
            return .back
        }
    }
}

enum Location: Character {
    case horizontal      = "-"
    case vertical        = "|"
    case slashCorner     = "/"
    case backSlashCorner = "\\"
    case intersection    = "+"
    case empty           = " "
}

class Cart {
    var position: Point2D
    var points: DirectionUDLR
    var nextTurn: Turn
    var nextPosition: Point2D

    init( position: Point2D, points: DirectionUDLR ) {
        self.position = position
        self.points = points
        self.nextTurn = .left
        self.nextPosition = position
    }
    
    func intersectionTurn() -> Void {
        points = points.turn( nextTurn )
        nextTurn = nextTurn.next
    }
    
    func slashTurn() -> Void {
        switch points {
        case .up, .down:
            points = points.turn( Turn.right )
        case .left, .right:
            points = points.turn( Turn.left )
        }
    }
    
    func backSlashTurn() -> Void {
        switch points {
        case .up, .down:
            points = points.turn( Turn.left )
        case .left, .right:
            points = points.turn( Turn.right )
        }
    }
    
    func move() -> Point2D {
        return position.move( direction: points )
    }
    
    func predictMove( cave: [[Location]] ) -> Void {
        switch cave[position.y][position.x] {
        case .horizontal, .vertical:
            nextPosition = move()
        case .slashCorner:
            slashTurn()
            nextPosition = move()
        case .backSlashCorner:
            backSlashTurn()
            nextPosition = move()
        case .intersection:
            intersectionTurn()
            nextPosition = move()
        default:
            print( "Off the rails at \(position.x),\(position.y)" )
        }
    }
}


func parse( input: AOCinput ) -> ( [[Location]], [Cart] ) {
    var carts = [Cart]()
    let inputChars = input.lines.map { Array( $0 ) }
    let cave = ( 0 ..< inputChars.count ).map { y in
        ( 0 ..< inputChars[y].count ).map { x -> Location in
            switch inputChars[y][x] {
            case "/", "\\", "-", "|", "+", " ":
                return Location( rawValue: inputChars[y][x] )!
            case "^":
                carts.append( Cart( position: Point2D( x: x, y: y ), points: .up ) )
                return .vertical
            case "v":
                carts.append( Cart( position: Point2D( x: x, y: y ), points: .down ) )
                return .vertical
            case "<":
                carts.append( Cart( position: Point2D( x: x, y: y ), points: .left ) )
                return .horizontal
            case ">":
                carts.append( Cart( position: Point2D( x: x, y: y ), points: .right ) )
                return .horizontal
            default:
                print( "Bad input: '\(inputChars[y][x])'" )
                return .empty
            }
        }
    }
    return ( cave, carts )
}


func crashCarts( cave: [[Location]], carts: [Cart], firstCrash: Bool ) -> Point2D {
    var carts = carts

    while carts.count > 1 {
        carts.forEach { $0.predictMove( cave: cave ) }
        
        FIRSTCRASHLOOP:
        while true {
            for i in 0 ..< carts.count - 1 {
                for j in i + 1 ..< carts.count {
                    if carts[i].nextPosition == carts[j].position {
                        if firstCrash { return carts[i].nextPosition }
                        carts.remove( at: j )
                        carts.remove( at: i )
                        continue FIRSTCRASHLOOP
                    }
                }
            }
            break
        }

        SECONDCRASHLOOP:
        while true {
            for i in 0 ..< carts.count - 1 {
                for j in i + 1 ..< carts.count {
                    if carts[i].nextPosition == carts[j].nextPosition {
                        if firstCrash { return carts[i].nextPosition }
                        carts.remove( at: j )
                        carts.remove( at: i )
                        continue SECONDCRASHLOOP
                    }
                }
            }
            break
        }

        carts.forEach { $0.position = $0.nextPosition }
        carts.sort( by: {
            $0.position.y < $1.position.y || $0.position.y == $1.position.y && $0.position.x < $1.position.x
        } )
    }
    
    return carts[0].position
}


func part1( input: AOCinput ) -> String {
    let ( cave, carts ) = parse( input: input )
    let position = crashCarts( cave: cave, carts: carts, firstCrash: true )

    return "\(position.x),\(position.y)"
}


func part2( input: AOCinput ) -> String {
    let ( cave, carts ) = parse( input: input )
    let position = crashCarts( cave: cave, carts: carts, firstCrash: false )

    return "\(position.x),\(position.y)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
