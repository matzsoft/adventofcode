//
//  main.swift
//  day17
//
//  Created by Mark Johnson on 12/16/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

struct Coordinate: Hashable {
    let x: Int, y: Int, z: Int
}

struct Dimension {
    let active: Set<Coordinate>
    
    init( active: [Coordinate] ) {
        self.active = Set( active )
    }
    
    init( input: String ) {
        var active: [Coordinate] = []
        
        for ( yindex, row ) in input.split( separator: "\n" ).enumerated() {
            for ( xindex, value ) in row.enumerated() {
                if value == "#" {
                    active.append( Coordinate( x: xindex, y: yindex, z: 0 ) )
                }
            }
        }
        
        self.init( active: active )
    }
    
    var cycle: Dimension {
        let xmin = active.min( by: { $0.x < $1.x } )!.x - 1
        let xmax = active.max( by: { $0.x < $1.x } )!.x + 1
        let ymin = active.min( by: { $0.y < $1.y } )!.y - 1
        let ymax = active.max( by: { $0.y < $1.y } )!.y + 1
        let zmin = active.min( by: { $0.z < $1.z } )!.z - 1
        let zmax = active.max( by: { $0.z < $1.z } )!.z + 1
        var next: [Coordinate] = []
        
        for x in xmin ... xmax {
            for y in ymin ... ymax {
                for z in zmin ... zmax {
                    let current = Coordinate( x: x, y: y, z: z )
                    let neighbors = countNeighbors( coordinate: current )
                    
                    if active.contains( current ) {
                        if neighbors == 3 || neighbors == 4 {
                            next.append( current )
                        }
                    } else {
                        if neighbors == 3 {
                            next.append( current )
                        }
                    }
                }
            }
        }
        
        return Dimension( active: next )
    }
    
    func countNeighbors( coordinate: Coordinate ) -> Int {
        var sum = 0
        for x in coordinate.x - 1 ... coordinate.x + 1 {
            for y in coordinate.y - 1 ... coordinate.y + 1 {
                for z in coordinate.z - 1 ... coordinate.z + 1 {
                    sum += active.contains( Coordinate( x: x, y: y, z: z ) ) ? 1 : 0
                }
            }
        }
        return sum
    }
}


let inputFile = "/Users/markj/Development/adventofcode/2020/input/day17.txt"
var dimension = try Dimension( input: String( contentsOfFile: inputFile ) )

for _ in 1 ... 6 { dimension = dimension.cycle }

print( "Part 1: \(dimension.active.count)" )
//print( "Part 2: \(spoken[part2Limit-1])" )
