//
//         FILE: main.swift
//  DESCRIPTION: day16 - Dragon Checksum
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/04/21 23:09:26
//

import Foundation

struct Disk {
    let length:    Int
    let chunkSize: Int
    let initial:   [Character]
    let inverted:  [Character]
    let skeleton:  [Character]
    
    init( initial: String, length: Int ) {
        self.length   = length
        self.initial  = Array( initial )
        self.inverted = Array( Disk.flip( data: initial ) )
        
        // Calculate the chunk size - the biggest power of 2 that is a factor of length.
        // Each chunk becomes a single bit in the final checksum.
        var chunkSize = 1
        
        while length & chunkSize == 0 { chunkSize <<= 1 }
        self.chunkSize = chunkSize

        // Calculate the dragon curve skeleton - see class comments for more detail.
        let rounds = Int( ceil( log2( Double( ( length + 1 ) / ( initial.count + 1 ) ) ) ) )
        var skeleton = ""
        
        for _ in 1 ... rounds {
            skeleton = skeleton + "0" + Disk.flip( data: skeleton )
        }
        
        self.skeleton = Array( skeleton )
    }
    
    static func flip( data: String ) -> String {
        return data.reversed().map { $0 == "0" ? "1" : "0" }.joined()
    }

    subscript( offset: Int ) -> Character {
        if offset % ( initial.count + 1 )  == initial.count {
            // It's a character from the skeleton
            return skeleton[ offset / ( initial.count + 1 ) ]
        }
        
        if offset % ( 2 * initial.count + 2 ) < initial.count {
            // It's an a (initial)
            return initial[ offset % ( initial.count + 1 ) ]
        }
        
        // It's a b (inverted)
        return inverted[ offset % ( initial.count + 1 ) ]
    }

    func isEqual( leftStart: Int, rightStart: Int, size: Int ) -> Bool {
        return ( 0 ..< size ).allSatisfy { self[leftStart+$0] == self[rightStart+$0] }
    }
    
    var checksum: String {
        let result = stride( from: 0, to: length, by: chunkSize ).map {
            checksum( startIndex: $0, endIndex: $0 + chunkSize )
        }
        
        return String( result )
    }
    
    func checksum( startIndex: Int, endIndex: Int ) -> Character {
        let size = endIndex - startIndex
        let half = size / 2
        
        guard half > 1 else { return self[startIndex] == self[startIndex+1] ? "1" : "0" }
        
        if isEqual( leftStart: startIndex, rightStart: startIndex + half, size: half ) { return "1" }
        
        let left = checksum( startIndex: startIndex, endIndex: startIndex + half )
        let right = checksum(startIndex: startIndex + half, endIndex: endIndex )
        
        return left == right ? "1" : "0"
    }
}


// The dragon curve for the problem works as follows ( f(a) is the flip function, reverses and inverts a ):
// Round 1 - a0f(a) = a0b
// Round 2 - a0b0f(b)1f(a) = a0b0a1b
// Round 3 - a0b0a1b0a0b1a1b
// etc.
//
// Notice that it doesn't matter what a is so we can leave out the a (and b) and just return the seperating
// string of 0's and 1's.


// This function uses dragonSkeleton to get the 0's and 1's (see above).  Then it adds in the a and b
// segments in the appropriate places.  The loopCount is derived by observing that the length after n rounds
// of the dragon curve is
//
// 2**n * c + 2**n - 1
//
// This needs to be enough to satisy the length argument (denoted below by L). So solve
//
// 2**n * c + 2**n - 1 >= L
// 2**n( c + 1 ) - 1 >= L
// 2**n( c + 1 ) >= L + 1
// 2**n >= ( L + 1 ) / ( c + 1 )
// n >= log2( ( L + 1 ) / ( c + 1 ) )


func parse( input: AOCinput ) -> String {
    return input.line
}


//func part1( input: AOCinput ) -> String {
//    let initial = parse( input: input )
//
//    return "\(fillAndChecksum( length: 272, initial: initial ))"
//}


func part1( input: AOCinput ) -> String {
    let initial = parse( input: input )
    let disk = Disk( initial: initial, length: 272 )

    return disk.checksum
}


//func part2( input: AOCinput ) -> String {
//    let initial = parse( input: input )
//
//    return "\(fillAndChecksum( length: 35651584, initial: initial ))"
//}


func part2( input: AOCinput ) -> String {
    let initial = parse( input: input )
    let disk = Disk( initial: initial, length: 35651584 )

    return disk.checksum
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
