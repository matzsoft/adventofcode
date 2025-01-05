//
//  Extensions.swift
//  day07
//
//  Created by Mark Johnson on 3/26/21.
//  Contains useful extensions to standard types.

import Foundation

extension Collection {
    /// Behaves like split(where:) except the delimiting elements are retained in the output array.
    /// - Parameter isSplit: A function that returns true when an element should cause a split.
    /// - Returns: An array of SubSequence that reflects the original collection split according to
    ///  the predicate isSplit.
    func splitAt( isSplit: ( Iterator.Element ) throws -> Bool ) rethrows -> [SubSequence] {
        let delimiterIndicees = try indices.filter( { try isSplit( self[$0] ) } )
        var lastStartIndex = self.startIndex
        let result = delimiterIndicees.reduce( into: [SubSequence]() ) { result, index in
            if index > lastStartIndex {
                result.append( self[lastStartIndex..<index] )
            }
            result.append( self[index...index] )
            lastStartIndex = self.index( after: index )
        }
        
        guard lastStartIndex < endIndex else { return result }
        return result + [ self[lastStartIndex..<endIndex] ]
    }
}

extension String {
    /// Splits a string with multiple delimiters, but keeps the delimiters in the result.
    ///
    /// For example these 2 lines produce similar results.
    ///
    ///     let withoutDelimiters = string.split( whereSeparator: { delimiters.contains( $0 ) } )
    ///     let withDelimiters = string.tokenize( delimiters: delimiters )
    ///
    /// - Parameter delimiters: A string of characters, any one of which splits the input string.
    /// - Returns: An array of Substring that keeps the delimiters interspersed with the other parts.
    public func tokenize( delimiters: String ) -> [Substring] {
        return self.splitAt( isSplit: { delimiters.contains( $0 ) } )
    }
}

/// Returns the Greatest Common Divisor of two Int values.
public func gcd( _ m: Int, _ n: Int ) -> Int {
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


public struct CircularBuffer<T> {
    var buffer: [T]
    var inPtr: Int
    var outPtr: Int
    let limit: Int
    
    public var isEmpty: Bool { inPtr == outPtr }
    public var isFull: Bool { ( inPtr + 1 ) % limit == outPtr }
    
    public init( initial: [T], limit: Int ) {
        buffer = initial
        inPtr = initial.count
        outPtr = 0
        self.limit = limit
    }
    
    public mutating func read() -> T? {
        if isEmpty { return nil }
        let readValue = buffer[outPtr]
        outPtr += 1
        if outPtr >= limit { outPtr = 0 }
        return readValue
    }
    
    public mutating func write( value: T ) throws {
        if isFull { throw RuntimeError( "Can't write when CircularBuffer is full." ) }
        if inPtr < limit {
            if inPtr >= buffer.count {
                buffer.append( value )
            } else {
                buffer[inPtr] = value
            }
            inPtr += 1
        } else {
            buffer[0] = value
            inPtr = 1
        }
    }
}


