//
//         FILE: main.swift
//  DESCRIPTION: day19 - A Series of Tubes
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/23/21 14:27:33
//

import Foundation

class Network {
    let map: [[Character]]
    var direction = DirectionUDLR.down
    var current = Point2D( x: 0, y: 0 )
    var path: [Character] = []
    var stepCount = 0

    init( lines: [String] ) {
        map = lines.map { Array( $0 ) }

        for x in 0 ..< map[0].count {
            current = Point2D( x: x, y: 0 )
            if self[current] == "|" { break }
        }
    }
    
    subscript( point: Point2D ) -> Character {
        guard 0 <= point.x && point.x < map[point.y].count else { return " " }
        guard 0 <= point.y && point.y < map.count else { return " " }

        return map[point.y][point.x]
    }
    
    func traverse() -> String {
        while self[current] != " " {
            //print( current )
            nextMove()
            stepCount += 1
        }
        
        return String( path )
    }
    
    func nextMove() -> Void {
        if self[current] != " " {
            switch self[current] {
            case "|", "-", "+", " ":
                break
            default:
                path.append( self[current] )
            }

            let next = current.move( direction: direction )
            
            if self[next] != " " {
                current = next
            } else {
                switch direction {
                case .up, .down:
                    let right = current.move( direction: DirectionUDLR.right )
                    let left = current.move( direction: DirectionUDLR.left )
                    
                    if self[right] != " " {
                        current = right
                        direction = .right
                    } else if self[left] != " " {
                        current = left
                        direction = .left
                    } else {
                        current = next
                    }
                case .right, .left:
                    let up = current.move( direction: DirectionUDLR.up )
                    let down = current.move( direction: DirectionUDLR.down )
                    
                    if self[up] != " " {
                        current = up
                        direction = .up
                    } else if self[down] != " " {
                        current = down
                        direction = .down
                    } else {
                        current = next
                    }
                }
            }
        }
    }
}


func parse( input: AOCinput ) -> Network {
    return Network( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    let network = parse( input: input )
    return "\(network.traverse())"
}


func part2( input: AOCinput ) -> String {
    let network = parse( input: input )
    
    _ = network.traverse()
    return "\(network.stepCount)"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
