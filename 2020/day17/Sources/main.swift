//
//         FILE: main.swift
//  DESCRIPTION: day17 - Conway Cubes
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/28/21 14:19:08
//

import Foundation
import Library

struct Pocket3D {
    let active: Set<Point3D>
    
    init( active: [Point3D] ) {
        self.active = Set( active )
    }
    
    init( lines: [String] ) {
        var active: [Point3D] = []
        
        for ( yindex, row ) in lines.enumerated() {
            for ( xindex, value ) in row.enumerated() {
                if value == "#" {
                    active.append( Point3D( x: xindex, y: yindex, z: 0 ) )
                }
            }
        }
        
        self.init( active: active )
    }
    
    var cycle: Pocket3D {
        let bounds = Rect3D( points: Array( active ) ).pad( by: 1 )
        var next: [Point3D] = []
        
        for x in bounds.min.x ... bounds.max.x {
            for y in bounds.min.y ... bounds.max.y {
                for z in bounds.min.z ... bounds.max.z {
                    let current = Point3D( x: x, y: y, z: z )
                    let neighbors = countNeighbors( coordinate: current )
                    
                    if neighbors == 3 || active.contains( current ) && neighbors == 4 {
                        next.append( current )
                    }
                }
            }
        }
        
        return Pocket3D( active: next )
    }
    
    func countNeighbors( coordinate: Point3D ) -> Int {
        var sum = 0
        for x in coordinate.x - 1 ... coordinate.x + 1 {
            for y in coordinate.y - 1 ... coordinate.y + 1 {
                for z in coordinate.z - 1 ... coordinate.z + 1 {
                    sum += active.contains( Point3D( x: x, y: y, z: z ) ) ? 1 : 0
                }
            }
        }
        return sum
    }
}


struct Pocket4D {
    let active: Set<Point4D>
    
    init( active: [Point4D] ) {
        self.active = Set( active )
    }

    init( lines: [String] ) {
        var active: [Point4D] = []
        
        for ( yindex, row ) in lines.enumerated() {
            for ( xindex, value ) in row.enumerated() {
                if value == "#" {
                    active.append( Point4D( x: xindex, y: yindex, z: 0, t: 0 ) )
                }
            }
        }
        
        self.init( active: active )
    }

    var cycle: Pocket4D {
        let bounds = Rect4D( points: Array( active ) ).pad( by: 1 )
        var next: [Point4D] = []
        
        for x in bounds.min.x ... bounds.max.x {
            for y in bounds.min.y ... bounds.max.y {
                for z in bounds.min.z ... bounds.max.z {
                    for t in bounds.min.t ... bounds.max.t {
                        let current = Point4D( x: x, y: y, z: z, t: t )
                        let neighbors = countNeighbors( coordinate: current )
                        
                        if neighbors == 3 || active.contains( current ) && neighbors == 4 {
                            next.append( current )
                        }
                    }
                }
            }
        }
        
        return Pocket4D( active: next )
    }
    
    func countNeighbors( coordinate: Point4D ) -> Int {
        var sum = 0
        for x in coordinate.x - 1 ... coordinate.x + 1 {
            for y in coordinate.y - 1 ... coordinate.y + 1 {
                for z in coordinate.z - 1 ... coordinate.z + 1 {
                    for t in coordinate.t - 1 ... coordinate.t + 1 {
                        sum += active.contains( Point4D( x: x, y: y, z: z, t: t ) ) ? 1 : 0
                    }
                }
            }
        }
        return sum
    }
}

func part1( input: AOCinput ) -> String {
    var pocket3D = Pocket3D( lines: input.lines )
    
    for _ in 1 ... 6 { pocket3D = pocket3D.cycle }
    return "\( pocket3D.active.count )"
}


func part2( input: AOCinput ) -> String {
    var pocket4D = Pocket4D( lines: input.lines )

    for _ in 1 ... 6 { pocket4D = pocket4D.cycle }
    return "\( pocket4D.active.count )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
