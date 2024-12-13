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

struct Plot {
    let type: Character
    var region: Int?
}

struct Region {
    let type: Character
    let plots: Set<Point2D>
    let edges: Int
}

struct Garden {
    var plots: [[Plot]]
    let bounds: Rect2D
    
    init( lines: [String] ) {
        plots = lines.map { $0.map { Plot( type: $0, region: nil ) } }
        bounds = Rect2D(
            min: Point2D( x: 0, y: 0 ), width: plots[0].count, height: plots.count
        )!
    }
    
    subscript( point: Point2D ) -> Plot { plots[point.y][point.x] }

    func expensive() -> Int {
        var regions = [Region]()
        var unexamined = Set( bounds.points )
        
        while !unexamined.isEmpty {
            var queue = [unexamined.removeFirst()]
            var region = Set<Point2D>()
            var perimeter = 0
            let type = self[queue[0]].type
            
            while !queue.isEmpty {
                let next = queue.removeFirst()
                unexamined.remove( next )
                if region.insert( next ).inserted {
                    let neighbors = DirectionUDLR.allCases
                        .map { next + $0.vector }
                        .filter {
                            bounds.contains( point: $0 ) && self[$0].type == type
                        }
                    perimeter += 4 - neighbors.count
                    let remaining = neighbors.filter { unexamined.contains( $0 ) }
                    queue.append( contentsOf: remaining )
                }
            }
            regions.append(
                Region( type: type, plots: region, edges: perimeter )
            )
        }
        
        let price = regions.map { $0.plots.count * $0.edges }.reduce( 0, + )

        return price
    }
    
    func discounted() -> Int {
        var regions = [Region]()
        var unexamined = Set( bounds.points )
        
        while !unexamined.isEmpty {
            var queue = [unexamined.removeFirst()]
            var region = Set<Point2D>()
            let type = self[queue[0]].type
            
            while !queue.isEmpty {
                let next = queue.removeFirst()
                unexamined.remove( next )
                if region.insert( next ).inserted {
                    let neighbors = DirectionUDLR.allCases
                        .map { next + $0.vector }
                        .filter {
                            bounds.contains( point: $0 ) && self[$0].type == type
                        }
                    let remaining = neighbors.filter { unexamined.contains( $0 ) }
                    queue.append( contentsOf: remaining )
                }
            }
            regions.append( Region( type: type, plots: region, edges: 0 ) )
        }
        
        var newRegions = [Region]()
        for region in regions {
            var sides = 0
            
            for direction in DirectionUDLR.allCases {
                let left = direction.turn( .left )
                let right = direction.turn( .right )
                var plots = region.plots.filter {
                    !bounds.contains( point: $0 + direction.vector )
                    || self[ $0 + direction.vector ].type != self[$0].type
                }
                
                while !plots.isEmpty {
                    let plot = plots.removeFirst()
                    for next in 1... {
                        let nextPlot = plot + next * left.vector
                        if bounds.contains( point: nextPlot )
                            && plots.contains( nextPlot )
                            /* && self[nextPlot].type == self[plot].type */ {
                            plots.remove( nextPlot )
                        } else {
                            break
                        }
                    }
                    for next in 1... {
                        let nextPlot = plot + next * right.vector
                        if bounds.contains( point: nextPlot )
                            && plots.contains( nextPlot )
                            /* && self[nextPlot].type == self[plot].type */ {
                            plots.remove( nextPlot )
                        } else {
                            break
                        }
                    }
                    sides += 1
                }
            }
            newRegions.append(
                Region( type: region.type, plots: region.plots, edges: sides )
            )
        }
        
        let price = newRegions.map { $0.plots.count * $0.edges }.reduce( 0, + )

        return price
    }
}


func part1( input: AOCinput ) -> String {
    return "\(Garden( lines: input.lines ).expensive())"
}


func part2( input: AOCinput ) -> String {
    return "\(Garden( lines: input.lines ).discounted())"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
