//
//         FILE: main.swift
//  DESCRIPTION: day11 - Chronal Charge
//        NOTES: --- Although the problem describes coordinates as 1 ... 300, I use 0 ... 299 internally
//                   to save (significant) memory.  This means that I need to add 1 to x and y in certain
//                   places to conform to the problem.  These would be in cellsPower and when setting
//                   coordsOfMax and identifierOfMax. This off by 1 also applies to the first subscript of
//                   the grid array which represents the size of the mini grid it represents.
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/17/21 13:55:26
//

import Foundation

let gridSize = 300
let rackOffset = 10
let powerDrain = 5

func cellsPower( serialNumber: Int ) -> [[Int]] {
    return ( 0 ..< gridSize ).map { y in
        ( 0 ..< gridSize ).map { x in
            let rackID = x + 1 + rackOffset
            return ( ( y + 1 ) * rackID + serialNumber ) * rackID / 100 % 10 - powerDrain
        }
    }
}

func gridsPower( grid: [[[Int]]], depth: Int ) -> [[Int]] {
    let miniBigDepth   = depth / 2
    let miniBigSize    = depth / 2 + 1
    let miniSmallDepth = depth / 2 - 1
    
    return ( 0 ..< gridSize - depth ).map { y in
        ( 0 ..< gridSize - depth ).map { x in
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

            return powerLevel
        }
    }
}

func totalPowerAt( grid: [[[Int]]], x: Int, y: Int, miniGridSize: Int ) -> Int {
    return ( y ..< y + miniGridSize ).reduce( 0 ) { sum, y in
        sum + ( x ..< x + miniGridSize ).reduce( 0 ) { sum, x in sum + grid[0][y][x] }
    }
}

func findMax( grid: [[[Int]]], miniGridSize: Int ) -> String {
    var totalPowerMax = 0
    var coordsOfMax = ""

    for y in 0 ..< gridSize - miniGridSize + 1 {
        for x in 0 ..< gridSize - miniGridSize + 1 {
            let totalPower = totalPowerAt( grid: grid, x: x, y: y, miniGridSize: miniGridSize )
            
            if totalPower > totalPowerMax {
                totalPowerMax = totalPower
                coordsOfMax = "\(x+1),\(y+1)"
            }
        }
    }
    
    return coordsOfMax
}

func findBiggerMax( grid: [[[Int]]] ) -> String {
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


func parse( input: AOCinput ) -> Int {
    return Int( input.line )!
}


func part1( input: AOCinput ) -> String {
    let serialNumber = parse( input: input )
    let grid: [[[Int]]] = [ cellsPower( serialNumber: serialNumber ) ]

    return "\(findMax( grid: grid, miniGridSize: 3 ))"
}


func part2( input: AOCinput ) -> String {
    let serialNumber = parse( input: input )
    var grid: [[[Int]]] = [ cellsPower( serialNumber: serialNumber ) ]

    ( 1 ..< gridSize ).forEach { grid.append( gridsPower( grid: grid, depth: $0) ) }

    return "\(findBiggerMax( grid: grid ))"
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
