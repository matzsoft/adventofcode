//
//  Extensions.swift
//  day07
//
//  Created by Mark Johnson on 3/26/21.
//  Contains useful extensions to standard types.

import Foundation
import MATZMiscSwiftLibrary

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
