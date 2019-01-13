//
//  main.swift
//  day10
//
//  Created by Mark Johnson on 1/12/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

class KnotHash {
    var list: [Int]
    let lengths: [Int]
    var current: Int
    var skip: Int
    
    init( list: [Int], lengths: [Int] ) {
        self.list = list
        self.lengths = lengths
        current = 0
        skip = 0
    }
    
    func oneRound() -> Void {
        for length in lengths {
            if current + length  < list.count {
                let reversed = Array( list[ current ..< ( current + length) ].reversed() )
                
                list.replaceSubrange( current ..< ( current + length), with: reversed )
            } else {
                let working = list + list
                let reversed = Array( working[ current ..< ( current + length) ].reversed() )
                let part1 = Array( reversed[ ( list.count - current )...] )
                let part2 = Array( list[ ( ( current + length ) % list.count ) ..< current ] )
                let part3 = Array( reversed[ 0 ..< ( list.count - current ) ] )
                
                list = part1 + part2 + part3
            }
            
            current = ( current + length + skip ) % list.count
            skip += 1
        }
    }
    
    func generate() -> String {
        guard list.count == 256 else { return "Wrong sized list" }
        var hash = ""
        
        for _ in 0 ..< 64 {
            oneRound()
        }
        
        for i in stride( from: 0, to: list.count, by: 16 ) {
            let element = list[ i ..< ( i + 16 ) ].reduce( 0, { $0 ^ $1 } )
            
            hash += String( format: "%02x", element )
        }
        
        return hash
    }
}


let test1 = [ 3, 4, 1, 5 ]
var testList = ( 0 ... 4 ).map { $0 }
let input = "34,88,2,222,254,93,150,0,199,255,39,32,137,136,1,167"
let lengths = input.split(separator: ",").map { Int( $0 )! }
let list = ( 0 ... 255 ).map { $0 }

let tester = KnotHash( list: testList, lengths: test1 )
let knot = KnotHash( list: list, lengths: lengths )

tester.oneRound()
knot.oneRound()

print( "Test1:", tester.list[0] * tester.list[1] )
print( "Part1:", knot.list[0] * knot.list[1] )


let asciiLengths = input.map { Int( $0.unicodeScalars.first!.value ) }
let extraLengths = [ 17, 31, 73, 47, 23 ]
let part2Lengths = asciiLengths + extraLengths
let knothash = KnotHash( list: list, lengths: part2Lengths )

print( "Part2:", knothash.generate() )
