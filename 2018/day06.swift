//
//  main.swift
//  day06
//
//  Created by Mark Johnson on 12/5/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

let input = """
267, 196
76, 184
231, 301
241, 76
84, 210
186, 243
251, 316
265, 129
142, 124
107, 134
265, 191
216, 226
67, 188
256, 211
317, 166
110, 41
347, 332
129, 91
217, 327
104, 57
332, 171
257, 287
230, 105
131, 209
110, 282
263, 146
113, 217
193, 149
280, 71
357, 160
356, 43
321, 123
272, 70
171, 49
288, 196
156, 139
268, 163
188, 141
156, 182
199, 242
330, 47
89, 292
351, 329
292, 353
290, 158
167, 116
268, 235
124, 139
116, 119
142, 259
"""
let testInput = """
1, 1
1, 6
8, 3
3, 4
5, 5
8, 9
"""

let lines = input.split(separator: "\n")
let coordinates = lines.map { $0.split( whereSeparator: { ", ".contains($0) } ).map { Int($0)! } }
let minx = coordinates.min( by: { $0[0] < $1[0] } )![0]
let maxx = coordinates.max( by: { $0[0] < $1[0] } )![0]
let miny = coordinates.min( by: { $0[1] < $1[1] } )![1]
let maxy = coordinates.max( by: { $0[1] < $1[1] } )![1]
var grid1: [[Int?]] = []
var grid2: [[Int]] = []

func distance( x: Int, y: Int, coord: [Int] ) -> Int {
    return abs( x - coord[0] ) + abs( y - coord[1] )
}

for y in 0 ... maxy {
    grid1.append([])
    grid2.append([])
    for x in 0 ... maxx {
        let distances = coordinates.map { distance(x: x, y: y, coord: $0 ) }
        let mind = distances.min()
        let closest = distances.enumerated().filter { $0.element == mind }.map { $0.offset }
        
        if closest.count > 1 {
            grid1[y].append(nil)
        } else {
            grid1[y].append(closest[0])
        }
        
        grid2[y].append( distances.reduce(0) { $0 + $1 } )
    }
}

var histo = Array( repeating: 0, count: coordinates.count )

grid1.forEach { $0.forEach { if let i = $0 { histo[i] += 1 } } }

for x in 0 ... maxx {
    if let i = grid1[0][x] { histo[i] = 0 }
    if let i = grid1[maxy][x] { histo[i] = 0 }
}

for y in 0 ... maxy {
    if let i = grid1[y][0] { histo[i] = 0 }
    if let i = grid1[y][maxx] { histo[i] = 0 }
}

print( "Part1:", histo.max()! )
print( "Part2:", grid2.flatMap { $0 }.filter { $0 < 10000 }.count )
