//
//  main.swift
//  day10
//
//  Created by Mark Johnson on 12/9/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

func gcd( _ m: Int, _ n: Int ) -> Int {
    var a: Int = 0
    var b: Int = max( m, n )
    var r: Int = min( m, n )

    while r != 0 {
        a = b
        b = r
        r = a % b
    }
    
    return b
}

struct Point {
    let x: Int
    let y: Int
    
    static func +( lhs: Point, rhs: Point ) -> Point {
        return Point( x: lhs.x + rhs.x, y: lhs.y + rhs.y )
    }
    
    static func +( lhs: Point, rhs: Slope ) -> Point {
        return Point( x: lhs.x + rhs.deltaX, y: lhs.y + rhs.deltaY )
    }
}

struct Slope: Hashable {
    let deltaX: Int
    let deltaY: Int
    
    init( deltaX: Int, deltaY: Int ) {
        self.deltaX = deltaX
        self.deltaY = deltaY
    }
    
    init( _ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int ) {
        let deltaX = x2 - x1
        let deltaY = y2 - y1
        let factor = abs( gcd( deltaX, deltaY ) )
        
        self.deltaX = deltaX / factor
        self.deltaY = deltaY / factor
    }
    
    func hash( into hasher: inout Hasher ) {
        hasher.combine( deltaX )
        hasher.combine( deltaY )
    }
}

struct Map {
    let map: [[Int]]
    let width: Int
    let height: Int
    
    init( input: String ) {
        map = input.split( separator: "\n" ).map { $0.map { $0 == "." ? 0 : 1 } }
        width = map[0].count
        height = map.count
    }
    
    func isOccupied( _ x: Int, _ y: Int ) -> Bool {
        return map[y][x] == 1
    }
    
    func isOccupied( point: Point ) -> Bool {
        return map[point.y][point.x] == 1
    }
    
    func inBounds( point: Point ) -> Bool {
        return 0 <= point.x && point.x < width && 0 <= point.y && point.y < height
    }
    
    func visibleCounts() -> [[Int]] {
        var counts = map
        
        for y in 0 ..< height {
            for x in 0 ..< width {
                if isOccupied( x, y ) {
                    counts[y][x] -= 1           // An asteroid cannot see itself
                    
                    // Scan the rest of this row for the first visisble asteroid
                    for x1 in x + 1 ..< width {
                        if isOccupied( x1, y ) {
                            counts[y][x] += 1
                            counts[y][x1] += 1
                            break
                        }
                    }
                    
                    // Scan the remaining rows for all visible asteroids
                    for y1 in y + 1 ..< height {
                        for x1 in 0 ..< width {
                            if isOccupied( x1, y1 ) {
                                let deltaX = x1 - x
                                let deltaY = y1 - y
                                let factor = abs( gcd( deltaX, deltaY ) )
                                
                                if factor == 1 {
                                    counts[y][x] += 1
                                    counts[y1][x1] += 1
                                } else {
                                    let stepX = deltaX / factor
                                    let stepY = deltaY / factor
                                    var visible = true
                                    
                                    for step in 1 ..< factor {
                                        let x2 = x + step * stepX
                                        let y2 = y + step * stepY
                                        
                                        if isOccupied( x2, y2 ) {
                                            visible = false
                                            break
                                        }
                                    }
                                    if visible {
                                        counts[y][x] += 1
                                        counts[y1][x1] += 1
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return counts
    }
    
    func maxVisible() -> Int {
        let counts = visibleCounts()
        var maxVisible = 0
        
        for y in 0 ..< height {
            for x in 0 ..< width {
                maxVisible = max( maxVisible, counts[y][x] )
            }
        }
        
        return maxVisible
    }
    
    func stationLocation() -> Point {
        let counts = visibleCounts()
        var maxVisible = 0
        var xs = 0
        var ys = 0
        
        for y in 0 ..< height {
            for x in 0 ..< width {
                if counts[y][x] > maxVisible {
                    maxVisible = counts[y][x]
                    xs = x
                    ys = y
                }
            }
        }
        
        return Point( x: xs, y: ys )
    }
    
    func quadrant( tether: Point, xRange: Range<Int>, yRange: Range<Int> ) -> [ [ Point ] ] {
        var dict: [ Slope : [Point] ] = [:]
        
        for y in yRange {
            for x in xRange {
                if isOccupied( x, y ) {
                    let slope = Slope( tether.x, tether.y, x, y )
                    
                    if dict[slope] == nil {
                        dict[slope] = beamList( tether: tether, slope: slope )
                    }
                }
            }
        }
        
        return dict.sorted( by: {
            let slope0 = Double( $0.key.deltaX ) / Double( $0.key.deltaY )
            return slope0 > Double( $1.key.deltaX ) / Double( $1.key.deltaY )
        } ).map { $0.value }
    }
    
    func beamList( tether: Point, slope: Slope ) -> [Point] {
        var list: [Point] = []
        var next = tether + slope
        
        while inBounds( point: next ) {
            if isOccupied( point: next ) {
                list.append( next )
            }
            next = next + slope
        }
        
        return list
    }
    
    func getCandidates( station: Point ) -> [ [ Point ] ] {
        var asteroids: [ [ Point ] ] = []
        
        // North axis
        asteroids.append( beamList( tether: station, slope: Slope( deltaX: 0, deltaY: -1 ) ) )
        
        // Northeast quadrant
        asteroids.append( contentsOf: quadrant( tether: station, xRange: station.x + 1 ..< width, yRange: 0 ..< station.y ) )

        // East axis
        asteroids.append( beamList( tether: station, slope: Slope( deltaX: 1, deltaY: 0 ) ) )
        
        // Southeast quadrant
        asteroids.append( contentsOf: quadrant( tether: station, xRange: station.x + 1 ..< width, yRange: station.y + 1 ..< height ) )

        // South axis
        asteroids.append( beamList( tether: station, slope: Slope( deltaX: 0, deltaY: 1 ) ) )

        // Southwest quadrant
        asteroids.append( contentsOf: quadrant( tether: station, xRange: 0 ..< station.x, yRange: station.y + 1 ..< height ) )

        // West axis
        asteroids.append( beamList( tether: station, slope: Slope( deltaX: -1, deltaY: 0 ) ) )
        
        // Northwest quadrant
        asteroids.append( contentsOf: quadrant( tether: station, xRange: 0 ..< station.x, yRange: 0 ..< station.y ) )

        return asteroids
    }
    
    func vaporize() -> [ Point ] {
        let station = stationLocation()
        var candidates = getCandidates( station: station )
        var hits: [ Point ] = []

        while !candidates.isEmpty {
            var index = 0
            while index < candidates.count {
                if candidates[index].isEmpty {
                    candidates.remove( at: index )
                    continue
                }

                hits.append( candidates[index].removeFirst() )
                index += 1
            }
        }
        
        return hits
    }
}

guard CommandLine.arguments.count > 1 else {
    print( "No input file specified" )
    exit( 1 )
}

let input = try String( contentsOfFile: CommandLine.arguments[1] )
let map = Map( input: input )

print( "Part 1: \(map.maxVisible())" )

let destroyed = map.vaporize()

print( "Part 2: \( destroyed[199].x * 100 + destroyed[199].y )" )
