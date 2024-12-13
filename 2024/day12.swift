//
//         FILE: day12.swift
//  DESCRIPTION: Advent of Code 2024 Day 12: Garden Groups
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/11/24 21:36:35
//

import Foundation
import Library

struct Region {
    let plots: Set<Point2D>
    let edges: Int
}

struct Garden {
    var plots: [[Character]]
    let bounds: Rect2D
    
    init( lines: [String] ) {
        plots = lines.map { $0.map { $0 } }
        bounds = Rect2D(
            min: Point2D( x: 0, y: 0 ), width: plots[0].count, height: plots.count
        )!
    }
    
    subscript( point: Point2D ) -> Character { plots[point.y][point.x] }

    var regions: [Region] {
        var regions = [Region]()
        var unexamined = Set( bounds.points )
        
        while !unexamined.isEmpty {
            var queue = [unexamined.removeFirst()]
            var region = Set<Point2D>()
            var perimeter = 0
            let type = self[queue[0]]
            
            while !queue.isEmpty {
                let next = queue.removeFirst()
                unexamined.remove( next )
                if region.insert( next ).inserted {
                    let neighbors = DirectionUDLR.allCases
                        .map { next + $0.vector }
                        .filter {
                            bounds.contains( point: $0 ) && self[$0] == type
                        }
                    perimeter += 4 - neighbors.count
                    let remaining = neighbors.filter { unexamined.contains( $0 ) }
                    queue.append( contentsOf: remaining )
                }
            }
            regions.append( Region( plots: region, edges: perimeter ) )
        }
        
        return regions
    }
    
    var expensive: Int {
        regions.map { $0.plots.count * $0.edges }.reduce( 0, + )
    }
    
    var discounted: Int {
        var newRegions = [Region]()
        for region in regions {
            var sides = 0
            
            for direction in DirectionUDLR.allCases {
                let left = direction.turn( .left )
                let right = direction.turn( .right )
                var plots = region.plots.filter {
                    !bounds.contains( point: $0 + direction.vector )
                    || self[ $0 + direction.vector ] != self[$0]
                }
                
                while !plots.isEmpty {
                    let plot = plots.removeFirst()
                    
                    func scan( direction: DirectionUDLR ) -> Void {
                        for next in 1... {
                            let nextPlot = plot + next * direction.vector
                            if plots.contains( nextPlot ) {
                                plots.remove( nextPlot )
                            } else {
                                return
                            }
                        }
                    }
                    scan( direction: left )
                    scan( direction: right )
                    sides += 1
                }
            }
            newRegions.append( Region( plots: region.plots, edges: sides ) )
        }
        
        let price = newRegions.map { $0.plots.count * $0.edges }.reduce( 0, + )

        return price
    }
}


func part1( input: AOCinput ) -> String {
    return "\(Garden( lines: input.lines ).expensive)"
}


func part2( input: AOCinput ) -> String {
    return "\(Garden( lines: input.lines ).discounted)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
