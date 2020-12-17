//
//  main.swift
//  day17
//
//  Created by Mark Johnson on 12/16/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

struct Coordinate3: Hashable {
    let x: Int, y: Int, z: Int
}

struct Coordinate4: Hashable {
    let x: Int, y: Int, z: Int, w: Int
}

struct Dimension3 {
    let active: Set<Coordinate3>
    
    init( active: [Coordinate3] ) {
        self.active = Set( active )
    }
    
    init( input: String ) {
        var active: [Coordinate3] = []
        
        for ( yindex, row ) in input.split( separator: "\n" ).enumerated() {
            for ( xindex, value ) in row.enumerated() {
                if value == "#" {
                    active.append( Coordinate3( x: xindex, y: yindex, z: 0 ) )
                }
            }
        }
        
        self.init( active: active )
    }
    
    var cycle: Dimension3 {
        let xmin = active.min( by: { $0.x < $1.x } )!.x - 1
        let xmax = active.max( by: { $0.x < $1.x } )!.x + 1
        let ymin = active.min( by: { $0.y < $1.y } )!.y - 1
        let ymax = active.max( by: { $0.y < $1.y } )!.y + 1
        let zmin = active.min( by: { $0.z < $1.z } )!.z - 1
        let zmax = active.max( by: { $0.z < $1.z } )!.z + 1
        var next: [Coordinate3] = []
        
        for x in xmin ... xmax {
            for y in ymin ... ymax {
                for z in zmin ... zmax {
                    let current = Coordinate3( x: x, y: y, z: z )
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
        
        return Dimension3( active: next )
    }
    
    func countNeighbors( coordinate: Coordinate3 ) -> Int {
        var sum = 0
        for x in coordinate.x - 1 ... coordinate.x + 1 {
            for y in coordinate.y - 1 ... coordinate.y + 1 {
                for z in coordinate.z - 1 ... coordinate.z + 1 {
                    sum += active.contains( Coordinate3( x: x, y: y, z: z ) ) ? 1 : 0
                }
            }
        }
        return sum
    }
}


struct Dimension4 {
    let active: Set<Coordinate4>
    
    init( active: [Coordinate4] ) {
        self.active = Set( active )
    }

    init( active: Dimension3 ) {
        self.active = Set( active.active.map { Coordinate4( x: $0.x, y: $0.y, z: $0.z, w: 0 ) } )
    }
    
    var cycle: Dimension4 {
        let xmin = active.min( by: { $0.x < $1.x } )!.x - 1
        let xmax = active.max( by: { $0.x < $1.x } )!.x + 1
        let ymin = active.min( by: { $0.y < $1.y } )!.y - 1
        let ymax = active.max( by: { $0.y < $1.y } )!.y + 1
        let zmin = active.min( by: { $0.z < $1.z } )!.z - 1
        let zmax = active.max( by: { $0.z < $1.z } )!.z + 1
        let wmin = active.min( by: { $0.w < $1.w } )!.w - 1
        let wmax = active.max( by: { $0.w < $1.w } )!.w + 1
        var next: [Coordinate4] = []
        
        for x in xmin ... xmax {
            for y in ymin ... ymax {
                for z in zmin ... zmax {
                    for w in wmin ... wmax {
                        let current = Coordinate4( x: x, y: y, z: z, w: w )
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
        }
        
        return Dimension4( active: next )
    }
    
    func countNeighbors( coordinate: Coordinate4 ) -> Int {
        var sum = 0
        for x in coordinate.x - 1 ... coordinate.x + 1 {
            for y in coordinate.y - 1 ... coordinate.y + 1 {
                for z in coordinate.z - 1 ... coordinate.z + 1 {
                    for w in coordinate.w - 1 ... coordinate.w + 1 {
                        sum += active.contains( Coordinate4( x: x, y: y, z: z, w: w ) ) ? 1 : 0
                    }
                }
            }
        }
        return sum
    }
}


let inputFile = "/Users/markj/Development/adventofcode/2020/input/day17.txt"
var dimension3 = try Dimension3( input: String( contentsOfFile: inputFile ) )
var dimension4 = Dimension4( active: dimension3 )

for _ in 1 ... 6 { dimension3 = dimension3.cycle; dimension4 = dimension4.cycle }

print( "Part 1: \(dimension3.active.count)" )
print( "Part 2: \(dimension4.active.count)" )
