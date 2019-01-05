//
//  main.swift
//  day14
//
//  Created by Mark Johnson on 1/1/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let test1Salt = "abc"
let inputSalt = "qzyelonm"
let range = 1000
let stretchCount = 2016

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
        
        buffer = [ hashValue(for: 0) ]
    }
    
    func hashValue( for index: Int ) -> String {
        var hash = "\(salt)\(index)".utf8.md5.rawValue
        
        for _ in 0 ..< stretch {
            hash = hash.utf8.md5.rawValue
        }
        
        return hash
    }
    
    subscript( index: Int ) -> String {
        guard firstIndex <= index else { print( "Index underflow:", index ); exit(1) }
        
        if index <= lastIndex {
            return buffer[ ( index - firstIndex + first ) % range ]
        }
        
        guard index == lastIndex + 1 else { print( "Index overflow:", index ); exit(1) }
        
        let value = hashValue(for: index)
        
        if buffer.count < range {
            last = buffer.count
            lastIndex = index
            buffer.append(value)
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
                    if self[index].range(of: target ) != nil {
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
                return String(repeating: key[index1], count: 5)
            }
        }
        
        return nil
    }
}

let generator1 = KeyGenerator(salt: inputSalt, stretch: 0)
let generator2 = KeyGenerator(salt: inputSalt, stretch: stretchCount)
var keys: [String] = []

while keys.count < 64 {
    keys.append( generator1.nextKey() )
}

print( "Part1:", generator1.current )

keys = []
while keys.count < 64 {
    keys.append( generator2.nextKey() )
}

print( "Part2:", generator2.current )
