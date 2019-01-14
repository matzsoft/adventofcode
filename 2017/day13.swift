//
//  main.swift
//  day13
//
//  Created by Mark Johnson on 1/13/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let test1 = """
0: 3
1: 2
4: 4
6: 4
"""
let input = """
0: 3
1: 2
2: 6
4: 4
6: 4
8: 8
10: 9
12: 8
14: 5
16: 6
18: 8
20: 6
22: 12
24: 6
26: 12
28: 8
30: 8
32: 10
34: 12
36: 12
38: 8
40: 12
42: 12
44: 14
46: 12
48: 14
50: 12
52: 12
54: 12
56: 10
58: 14
60: 14
62: 14
64: 14
66: 17
68: 14
72: 14
76: 14
80: 14
82: 14
88: 18
92: 14
98: 18
"""

func gcd( _ m: Int, _ n: Int ) -> Int {
    var a = 0
    var b = max( m, n )
    var r = min( m, n )
    
    while r != 0 {
        a = b
        b = r
        r = a % b
    }
    return b
}

func lcm( _ m: Int, _ n: Int ) -> Int {
    return m / gcd (m, n ) * n
}

class Layer {
    let depth: Int
    let range: Int
    var period: Int { return 2 * ( range - 1 ) }
    var severity: Int { return depth * range }
    
    init( input: Substring ) {
        let words = input.split( whereSeparator: { ": ".contains($0) } )
        
        depth = Int( words[0] )!
        range = Int( words[1] )!
    }
}

class Combo {
    let set: Set<Int>
    let period : Int
    
    init( layer: Layer ) {
        period = layer.period
        set = Set( ( 0 ..< period ).filter { ( $0 + layer.depth ) % layer.period != 0 } )
    }
    
    init( set: Set<Int>, period: Int ) {
        self.set = set
        self.period = period
    }
    
    func expandedSet( limit: Int ) -> Set<Int> {
        var expanded = Set<Int>()
        
        for m in stride( from: 0, to: limit, by: period ) {
            for n in set {
                expanded.insert( n + m )
            }
        }
        
        return expanded
    }
    
    func combine( other: Combo ) -> Combo {
        let newPeriod = lcm( period, other.period )
        let newSet = expandedSet( limit: newPeriod ).filter { other.set.contains( $0 % other.period )  }
        
        return Combo( set: newSet, period: newPeriod )
    }
}

func severity( layers: [Layer], delay: Int   ) -> Int {
    var severity = 0
    
    for layer in layers {
        if ( layer.depth + delay ) % layer.period == 0 {
            severity += layer.severity
        }
    }
    
    return severity
}



let layers = input.split(separator: "\n").map { Layer( input: $0 ) }

print( "Part1:", severity( layers: layers, delay: 0 ) )

var combo = Combo( layer: layers[0] )

for layer in layers[1...] {
    combo = combo.combine( other: Combo(layer: layer ) )
}

print( "Part2:", combo.set.min()! )
