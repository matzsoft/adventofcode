//
//  main.swift
//  day11
//
//  Created by Mark Johnson on 12/10/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//
// Important note: although the problem describes coordinates as 1 ... 300, I use 0 ... 299 internally
// to save (significant) memory.  This means that I need to add 1 to x and y in certain places to conform
// to the problem.  These would be in cellsPower and when setting coordsOfMax and identifierOfMax.
// This off by 1 also applies to the first subscript of the grid array which represents the size of the
// mini grid it represents.

import Foundation

let serialNumber = 1788
let gridSize = 300
let rackOffset = 10
let powerDrain = 5

func cellsPower() -> [[Int]] {
    var grid: [[Int]] = []
    
    for y in 0 ..< gridSize {
        grid.append( [] )
        for x in 0 ..< gridSize {
            let rackID = x + 1 + rackOffset
            let powerLevel = ( ( y + 1 ) * rackID + serialNumber ) * rackID / 100 % 10 - powerDrain
            
            grid[y].append( powerLevel )
        }
    }

    return grid
}

var grid: [[[Int]]] = [ cellsPower() ]

func gridsPower( depth: Int ) -> [[Int]] {
    let miniBigDepth   = depth / 2
    let miniBigSize    = depth / 2 + 1
    let miniSmallDepth = depth / 2 - 1
    var depthGrid: [[Int]] = []
    
    for y in 0 ..< gridSize - depth {
        depthGrid.append( [] )
        for x in 0 ..< gridSize - depth {
            var powerLevel = grid[miniBigDepth][y][x]

            if depth % 2 == 1 {
                powerLevel += grid[miniBigDepth][y][x+miniBigSize]
                powerLevel += grid[miniBigDepth][y+miniBigSize][x]
                powerLevel += grid[miniBigDepth][y+miniBigSize][x+miniBigSize]
                
            } else {
                powerLevel += grid[miniSmallDepth][y+1][x+miniBigSize]
                powerLevel += grid[miniSmallDepth][y+miniBigSize][x+1]
                powerLevel += grid[miniSmallDepth][y+miniBigSize][x+miniBigSize]
                
                for j in miniBigSize ... depth {
                    powerLevel += grid[0][y][x+j]
                    powerLevel += grid[0][y+j][x]
                }
            }
            
            depthGrid[y].append( powerLevel )
        }
    }
    
    return depthGrid
}

func totalPowerAt( x: Int, y: Int, miniGridSize: Int ) -> Int {
    var totalPower = 0
    
    for y in y ..< y + miniGridSize {
        for x in x ..< x + miniGridSize {
            totalPower += grid[0][y][x]
        }
    }
    
    return totalPower
}

func findMax( miniGridSize: Int ) -> String {
    var totalPowerMax = 0
    var coordsOfMax = ""

    for y in 0 ..< gridSize - miniGridSize + 1 {
        for x in 0 ..< gridSize - miniGridSize + 1 {
            let totalPower = totalPowerAt(x: x, y: y, miniGridSize: miniGridSize)
            
            if totalPower > totalPowerMax {
                totalPowerMax = totalPower
                coordsOfMax = "\(x+1),\(y+1)"
            }
        }
    }
    
    return coordsOfMax
}

func findBiggerMax() -> String {
    var totalPowerMax = 0
    var identifierOfMax = ""
    
    for depth in 0 ..< gridSize {
        for y in 0 ..< grid[depth].count {
            for x in 0 ..< grid[depth][y].count {
                if grid[depth][y][x] > totalPowerMax {
                    totalPowerMax = grid[depth][y][x]
                    identifierOfMax = "\(x+1),\(y+1),\(depth+1)"
                }
            }
        }
    }
    
    return identifierOfMax
}

print( "Part1:", findMax(miniGridSize: 3) )

( 1 ..< gridSize ).forEach { grid.append( gridsPower(depth: $0) ) }
print( "Part2:", findBiggerMax() )
