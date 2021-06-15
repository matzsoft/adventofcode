//
//         FILE: main.swift
//  DESCRIPTION: day14 - One-Time Pad
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/03/21 20:45:48
//

import Foundation

let range = 1000

class KeyGenerator {
    let salt: String
    var buffer: [String]
    var first = 0
    var firstIndex = 0
    var last = 0
    var lastIndex = 0
    var current = -1
    var stretch = 0
    
    init( salt: String, stretch: Int ) {
        self.salt = salt
        self.stretch = stretch
        buffer = []
        
        buffer = [ hashValue( for: 0 ) ]
    }
    
    func hashValue( for index: Int ) -> String {
        var hash = md5Hash( str: "\(salt)\(index)" )
        
        for _ in 0 ..< stretch {
            hash = md5Hash( str: hash )
        }
        
        return hash
    }
    
    subscript( index: Int ) -> String {
        guard firstIndex <= index else { print( "Index underflow:", index ); exit(1) }
        
        if index <= lastIndex {
            return buffer[ ( index - firstIndex + first ) % range ]
        }
        
        guard index == lastIndex + 1 else { print( "Index overflow:", index ); exit(1) }
        
        let value = hashValue( for: index )
        
        if buffer.count < range {
            last = buffer.count
            lastIndex = index
            buffer.append( value )
        } else {
            buffer[first] = value
            last = first
            lastIndex = index
            first = ( first + 1 ) % range
            firstIndex += 1
        }
        
        return value
    }
    
    func nextKey() -> String {
        while true {
            current += 1
            
            if let target = KeyGenerator.isPotential( key: self[current] ) {
                //print( "\(current): \(self[current])" )
                for index in current + 1 ... current + range {
                    if self[index].range( of: target ) != nil {
                        //print( "    \(index): \(self[index])" )
                        return self[current]
                    }
                }
            }
        }
    }
    
    static func isPotential( key: String ) -> String? {
        for offset in 0 ... key.count - 3 {
            let index1 = key.index( key.startIndex, offsetBy: offset )
            let index2 = key.index( key.startIndex, offsetBy: offset + 1 )
            let index3 = key.index( key.startIndex, offsetBy: offset + 2 )

            if key[index1] == key[index2] && key[index1] == key[index3] {
                return String( repeating: key[index1], count: 5 )
            }
        }
        
        return nil
    }
}


func parse( input: AOCinput ) -> String {
    return input.line
}


func part1( input: AOCinput ) -> String {
    let salt = parse( input: input )
    let generator = KeyGenerator( salt: salt, stretch: 0 )
    var keys: [String] = []

    while keys.count < 64 {
        keys.append( generator.nextKey() )
    }

    return "\(generator.current)"
}


func part2( input: AOCinput ) -> String {
    let salt = parse( input: input )
    let generator = KeyGenerator( salt: salt, stretch: 2016 )
    var keys: [String] = []

    while keys.count < 64 {
        keys.append( generator.nextKey() )
    }

    return "\(generator.current)"
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
