//
//  Extensions.swift
//  day07
//
//  Created by Mark Johnson on 3/26/21.
//  Contains useful extensions to standard types.

import Foundation

extension Collection {
    func splitAt( isSplit: ( Iterator.Element ) throws -> Bool ) rethrows -> [SubSequence] {
        let indexes = try indices.filter( { try isSplit( self[$0] ) } )
        var p = self.startIndex
        var result = [SubSequence]()
        
        for index in indexes {
            if index > p {
                result.append( self[p..<index] )
            }
            result.append( self[index...index] )
            p = self.index( after: index )
        }
        if p != self.endIndex {
            result.append( suffix( from: p ) )
        }
        return result
    }
}

extension String {
    /**
     Splits a string with multiple delimiters, but keeps the delimiters in the result.
     
     For example these 2 lines produce similar results.
     
     ~~~
    let withoutDelimiters = string.split( whereSeparator: { delimiters.contains( $0 ) } )
    let withDelimiters = string.tokenize( delimiters: delimiters )
     ~~~

     - Parameter delimiters: A string of characters, any one of which splits the input string.

     - Returns: An array of Substring that keeps the delimiters interspersed with the other parts.
    **/
    public func tokenize( delimiters: String ) -> [Substring] {
        return self.splitAt( isSplit: { delimiters.contains( $0 ) } )
    }
}

/// Returns the Greatest Common Divisor of two Int values.
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

/// Returns the Least Common Multiple of two Int values.
public func lcm( _ m: Int, _ n: Int ) -> Int {
    return m / gcd (m, n ) * n
}

