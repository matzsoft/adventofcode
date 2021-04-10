//
//         FILE: main.swift
//  DESCRIPTION: day17 - Two Steps Forward
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/08/21 11:24:38
//

import Foundation

let start = Point2D( x: 0, y: 0 )
let vault = Point2D( x: 3, y: 3 )
let extent = Rect2D( min: start, max: vault )

struct Position {
    let point: Point2D
    let path: String
}

func isOpen( hexChar: Character ) -> Bool {
    let value = Int( String( hexChar ), radix: 16 )!
    
    return value > 10
}

func isOpen( direction: DirectionUDLR, hash: String ) -> Bool {
    let hashChars = Array( hash )
    switch direction {
    case .up:
        return isOpen( hexChar: hashChars[0] )
    case .down:
        return isOpen( hexChar: hashChars[1] )
    case .left:
        return isOpen( hexChar: hashChars[2] )
    case .right:
        return isOpen( hexChar: hashChars[3] )
    }
}

func possibleMoves( key: String, point: Point2D, path: String ) -> [Position] {
    let hash = md5Hash( str: "\(key)\(path)" )
    var results: [Position] = []
    
    for direction in DirectionUDLR.allCases {
        let nextPos = point.move( direction: direction )
        
        if extent.contains( point: nextPos ) && isOpen( direction: direction, hash: hash ) {
            results.append( Position( point: nextPos, path: path + direction.rawValue ) )
        }
    }
    
    return results
}

func findDistance( key: String, start: Point2D, end: Point2D ) -> String? {
    var queue: [Position] = [ Position( point: start, path: "" ) ]
    
    while let next = queue.first {
        let possibles = possibleMoves( key: key, point: next.point, path: next.path )
        
        queue.removeFirst()
        for possible in possibles {
            if possible.point == end {
                return possible.path
            }
            
            queue.append( possible )
        }
    }
    
    return nil
}

func findLongest( key: String, start: Point2D, end: Point2D ) -> String? {
    var queue: [Position] = [ Position( point: start, path: "" ) ]
    var last: String?
    
    while let next = queue.first {
        let possibles = possibleMoves( key: key, point: next.point, path: next.path )
        
        queue.removeFirst()
        for possible in possibles {
            if possible.point == end {
                last = possible.path
            } else {
                queue.append( possible )
            }
        }
    }
    
    return last
}




func parse( input: AOCinput ) -> String {
    return input.line
}


func part1( input: AOCinput ) -> String {
    guard let result = findDistance( key: input.line, start: start, end: vault ) else {
        return "Failed!"
    }
    
    return result
}


func part2( input: AOCinput ) -> String {
    guard let result = findLongest( key: input.line, start: start, end: vault ) else {
        return "Failed!"
    }
    
    return "\(result.count)"
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
