//
//  KnotHash.swift
//  day10
//
//  Created by Mark Johnson on 4/19/21.
//

import Foundation

public class KnotHash {
    static let extraLengths = [ 17, 31, 73, 47, 23 ]
    
    public var list: [Int]
    let lengths: [Int]
    var current: Int
    var skip: Int
    
    public init( lengths: [Int] ) {
        list = ( 0 ... 255 ).map { $0 }
        self.lengths = lengths
        current = 0
        skip = 0
    }
    
    public init( input: String ) {
        list = ( 0 ... 255 ).map { $0 }
        lengths = input.map { Int( $0.unicodeScalars.first!.value ) } + KnotHash.extraLengths
        current = 0
        skip = 0
    }

    
    public func oneRound() -> Void {
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
    
    public func generate() -> String {
        guard list.count == 256 else { return "Wrong sized list" }
        
        for _ in 0 ..< 64 { oneRound() }
        
        return stride( from: 0, to: list.count, by: 16 ).map {
            return String( format: "%02x", list[ $0 ..< ( $0 + 16 ) ].reduce( 0, { $0 ^ $1 } ) )
        }.joined()
    }
}
