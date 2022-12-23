//
//         FILE: main.swift
//  DESCRIPTION: day23 - Unstable Diffusion
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/22/22 23:21:14
//

import Foundation

func spread( elf: Point2D, direction: Direction8 ) -> [Point2D] {
    let vector = direction.vector
    let candidate = elf + vector
    
    if vector.x == 0 {
        return [ candidate + Direction8.W.vector, candidate, candidate + Direction8.E.vector ]
    } else if vector.y == 0 {
        return [ candidate + Direction8.N.vector, candidate, candidate + Direction8.S.vector ]
    }
    fatalError( "Can't spread a diagonal" )
}


class Elves {
    struct Proposal {
        let elf: Point2D
        let move: Point2D
    }
    
    var elves: Set<Point2D>
    var directions: [Direction8] = [ .N, .S, .W, .E ]
    
    init( lines: [String] ) {
        let list = lines.enumerated().reduce( into: [Point2D]() ) { array, tuple in
            let ( row, line ) = tuple
            line.enumerated().forEach { col, character in
                if character == "#" { array.append( Point2D( x: col, y: -row ) ) }
            }
        }
        elves = Set( list )
    }
    
    var emptyCount: Int {
        Rect2D( points: Array( elves ) ).area - elves.count
    }
    
    @discardableResult func round() -> Int {
        let proposals = elves.compactMap { elf -> Proposal? in
            if Direction8.allCases.allSatisfy( { !elves.contains( elf + $0.vector ) } ) { return nil }
            for check in directions {
                let zone = spread( elf: elf, direction: check )
                if zone.allSatisfy( { !elves.contains( $0 ) } ) {
                    return Proposal( elf: elf, move: zone[1] )
                }
            }
            return nil
        }
        let histogram = proposals.map { $0.move }.reduce(into: [ Point2D : Int ]() ) { dict, point in
            dict[ point, default: 0 ] += 1
        }
        let successful = proposals.filter { histogram[$0.move] == 1 }
        
        successful.forEach { elves.remove( $0.elf ); elves.insert( $0.move ) }
        directions.append( directions.removeFirst() )
        return successful.count
    }
    
    func rounds( count: Int ) -> Void {
        for _ in 1 ... count { round() }
    }
    
    func roundsUntilDone() -> Int {
        for roundNumber in 1 ... Int.max {
            if round() == 0 { return roundNumber }
        }
        return 0
    }
}


func parse( input: AOCinput ) -> Set<Point2D> {
    let list = input.lines.enumerated().reduce(into: [Point2D]() ) { array, tuple in
        let ( row, line ) = tuple
        line.enumerated().forEach { col, character in
            if character == "#" { array.append( Point2D( x: col, y: -row ) ) }
        }
    }
    return Set( list )
}


func part1( input: AOCinput ) -> String {
    let elves = Elves( lines: input.lines )

    elves.rounds( count: 10 )
    return "\(elves.emptyCount)"
}


func part2( input: AOCinput ) -> String {
    let elves = Elves( lines: input.lines )

    return "\(elves.roundsUntilDone())"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
