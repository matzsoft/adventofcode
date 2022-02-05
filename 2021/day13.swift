//
//         FILE: main.swift
//  DESCRIPTION: day13 - Transparent Origami
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/12/21 21:06:24
//

import Foundation

struct Paper {
    let dots: Set<Point2D>
    
    init( lines: [String] ) {
        dots = lines.reduce( into: Set<Point2D>() ) {
            let words = $1.split( separator: "," )
            $0.insert( Point2D( x: Int( words[0] )!, y: Int( words[1] )! ) )
        }
    }
    
    init( original: Paper, fold: Instruction ) {
        switch fold.fold {
        case .x:
            dots = Set( original.dots.map {
                if $0.x < fold.value {
                    return $0
                } else {
                    return Point2D( x: 2 * fold.value - $0.x, y: $0.y )
                }
            } )
        case .y:
            dots = Set( original.dots.map {
                if $0.y < fold.value {
                    return $0
                } else {
                    return Point2D( x: $0.x, y: 2 * fold.value - $0.y )
                }
            } )
        }
    }
}


struct Instruction {
    enum Fold: String { case x, y }
    
    let fold: Fold
    let value: Int
    
    init( line: String ) {
        let words = line.split( whereSeparator: { " =".contains( $0 ) } ).map { String( $0 ) }
        
        fold = Fold( rawValue: words[2] )!
        value = Int( words[3] )!
    }
}


func parse( input: AOCinput ) -> ( Paper, [Instruction] ) {
    return ( Paper( lines: input.paragraphs[0] ), input.paragraphs[1].map { Instruction( line: $0 ) } )
}


func part1( input: AOCinput ) -> String {
    let ( paper, instructions ) = parse( input: input )
    let oneFold = Paper( original: paper, fold: instructions[0] )
    return "\( oneFold.dots.count )"
}


func part2( input: AOCinput ) -> String {
    let ( paper, instructions ) = parse( input: input )
    let final = instructions.reduce( paper ) { Paper( original: $0, fold: $1 ) }
    let blockLetters = try! BlockLetterDictionary( from: "5x6+0.txt" )
    let realBounds = Rect2D( points: Array( final.dots ) )
    let bounds = realBounds.expand(with: Point2D( x: realBounds.max.x + 1, y: realBounds.min.y ) )

    var screen = Array( repeating: Array( repeating: false, count: bounds.width ), count: bounds.height )
    
    for location in final.dots {
        screen[ location.y - bounds.min.y ][ location.x - bounds.min.x ] = true
    }

    return blockLetters.makeString( screen: screen )
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
