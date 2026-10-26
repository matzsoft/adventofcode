//
//         FILE: main.swift
//  DESCRIPTION: day20 - Trench Map
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/19/21 22:09:25
//

import Foundation
import Library

struct Image: CustomStringConvertible {
    let lit: Set<Point2D>
    let inverted: Bool
    
    subscript( position: Point2D ) -> Int { lit.contains( position ) != inverted ? 1 : 0 }
    
    var description: String {
        let bounds = Rect2D( points: Array( lit ) )
        
        return ( bounds.min.y ... bounds.max.y ).map { y in
            ( bounds.min.x ... bounds.max.x ).map {
                x in self[ Point2D( x: x, y: y ) ] == 0 ? "." : "#"
            }.joined()
        }.joined( separator: "\n" )
    }
    
    init( lit: Set<Point2D>, inverted: Bool ) {
        self.lit = lit
        self.inverted = inverted
    }
    
    init( lines: [String] ) {
        let image = lines.map { $0.map { $0 == "." ? 0 : 1 } }
        
        inverted = false
        lit = ( 0 ..< image.count ).reduce( into: Set<Point2D>() ) { set, row in
            ( 0 ..< image[row].count ).forEach { col in
                if image[row][col] == 1 { set.insert( Point2D( x: col, y: row ) ) }
            }
        }
    }
    
    func index( position: Point2D ) -> Int {
        let bounds = Rect2D( min: position, max: position ).pad( by: 1 )
        return bounds.points.reduce( 0 ) { $0 << 1 + self[$1] }
    }
    
    func enhance( algorithm: [Bool] ) -> Image {
        let bounds = Rect2D( points: Array( lit ) ).pad( by: 1 )
        var newSet = Set<Point2D>()
        let newInverted = !inverted && algorithm[0] || inverted && algorithm[511]
        
        for position in bounds.points {
            if algorithm[ index( position: position ) ] != newInverted { newSet.insert( position ) }
        }
        
        return Image( lit: newSet, inverted: newInverted )
    }
}


func parse( input: AOCinput ) -> ( [Bool], Image ) {
    let algorithm = input.paragraphs[0].joined().map { $0 == "." ? false : true }

    return ( algorithm, Image( lines: input.paragraphs[1] ) )
}


func part1( input: AOCinput ) -> String {
    let ( algorithm, image ) = parse( input: input )
    let image1 = image.enhance( algorithm: algorithm )
    let image2 = image1.enhance( algorithm: algorithm )
    
    return "\(image2.lit.count)"
}


func part2( input: AOCinput ) -> String {
    let ( algorithm, image ) = parse( input: input )
    let enhanced = ( 1 ... 50 ).reduce( image ) { image, _ in image.enhance( algorithm: algorithm ) }
    
    return "\(enhanced.lit.count)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
