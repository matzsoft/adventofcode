//
//  KnotHash.swift
//  day10
//
//  Created by Mark Johnson on 4/19/21.
//

import Foundation

/// Implements the KnotHash algorithm used by 2017 days 10 and 14.
public class KnotHash {
    static let extraLengths = [ 17, 31, 73, 47, 23 ]
    
    public var list: [Int]
    let lengths: [Int]
    var current: Int
    var skip: Int
    
    /// Initialize a KnotHash with an array of Int.
    ///
    /// Only used in 2017 day 10.
    /// - Parameter lengths: An array of integers ranging from 0 to 255.
    public init( lengths: [Int] ) {
        list = ( 0 ... 255 ).map { $0 }
        self.lengths = lengths
        current = 0
        skip = 0
    }
    
    /// Normal KnotHash init.
    /// - Parameter input: A character string to hash.  The lengths are taken from the
    /// ASCII value of each character.
    public init( input: String ) {
        list = ( 0 ... 255 ).map { $0 }
        lengths = input.map { Int( $0.unicodeScalars.first!.value ) } + KnotHash.extraLengths
        current = 0
        skip = 0
    }

    
    /// Performs a single round of the KnotHash algorithm.
    ///
    /// Only used directly in 2017 day 10.
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
    
    /// Performs the full hashing on the input string.
    /// - Returns: A 32 digit hexadecimal number that is the hash.
    public func generate() -> String {
        guard list.count == 256 else { return "Wrong sized list" }
        
        for _ in 0 ..< 64 { oneRound() }
        
        return stride( from: 0, to: list.count, by: 16 ).map {
            return String( format: "%02x", list[ $0 ..< ( $0 + 16 ) ].reduce( 0, { $0 ^ $1 } ) )
        }.joined()
    }
}
