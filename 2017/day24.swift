//
//  main.swift
//  day24
//
//  Created by Mark Johnson on 1/25/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let testInput = """
0/2
2/2
2/3
3/4
3/5
0/1
10/1
9/10
"""
let input = """
50/41
19/43
17/50
32/32
22/44
9/39
49/49
50/39
49/10
37/28
33/44
14/14
14/40
8/40
10/25
38/26
23/6
4/16
49/25
6/39
0/50
19/36
37/37
42/26
17/0
24/4
0/36
6/9
41/3
13/3
49/21
19/34
16/46
22/33
11/6
22/26
16/40
27/21
31/46
13/2
24/7
37/45
49/2
32/11
3/10
32/49
36/21
47/47
43/43
27/19
14/22
13/43
29/0
33/36
2/6
"""

struct Component: Hashable {
    let port1: Int
    let port2: Int
    
    var strength: Int { return port1 + port2 }
    
    init<T>( input: T ) where T: StringProtocol {
        let words = input.split(separator: "/")
        
        port1 = Int( words[0] )!
        port2 = Int( words[1] )!
    }
    
    func matches( port: Int ) -> Bool {
        return port == port1 || port == port2
    }
    
    func other( port: Int ) -> Int {
        if port == port1 {
            return port2
        }
        return port1
    }
}

typealias Bridge = ( length: Int, strength: Int )

func findBest( starts: Int, available: Set<Component>, by: ( Bridge, Bridge ) -> Bool ) -> Bridge {
    var strengths = [ ( 0, 0 ) ]
    let list = available.filter { $0.matches( port: starts ) }
    
    for component in list {
        let remaining = available.subtracting( [ component ] )
        let start = component.other( port: starts )
        let best = findBest( starts: start, available: remaining, by: by )
        
        strengths.append( ( length: best.length + 1, strength: best.strength + component.strength ) )
    }
    
    return strengths.max( by: by )!
}



let set = Set<Component>( input.split(separator: "\n").map { Component( input: $0 ) } )

print( "Part1:", findBest( starts: 0, available: set, by: { $0.strength < $1.strength } ) )
print( "Part2:", findBest( starts: 0, available: set, by: {
    $0.length < $1.length ? true : $0.length == $1.length && $0.strength < $1.strength
} ) )
