//
//         FILE: main.swift
//  DESCRIPTION: day24 - Electromagnetic Moat
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/25/21 19:51:48
//

import Foundation

typealias Bridge = ( length: Int, strength: Int )

struct Component: Hashable {
    let port1: Int
    let port2: Int
    
    var strength: Int { return port1 + port2 }
    
    init<T>( input: T ) where T: StringProtocol {
        let words = input.split( separator: "/" )
        
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




func parse( input: AOCinput ) -> Set<Component> {
    return Set<Component>( input.lines.map { Component( input: $0 ) } )
}


func part1( input: AOCinput ) -> String {
    let components = parse( input: input )
    return "\(findBest( starts: 0, available: components, by: { $0.strength < $1.strength } ).strength)"
}


func part2( input: AOCinput ) -> String {
    let components = parse( input: input )
    let result = findBest( starts: 0, available: components, by: {
        $0.length < $1.length ? true : $0.length == $1.length && $0.strength < $1.strength
    } ).strength
    
    return "\(result)"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
