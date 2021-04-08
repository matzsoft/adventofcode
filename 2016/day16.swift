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

extension String {
    subscript( offset: Int ) -> Character {
        return self[ self.index( self.startIndex, offsetBy: offset ) ]
    }
}


// There are 2 important realizations that allow this problem to be solved in resonable time.  Number one,
// there is no need to generate the data for filling the disk.  Number two, there is a shortcut for
// calculating the checksum that requires little memory and is O(n).

// In the following discussion a is the initial data, f is a function that reverses the order of the
// chatacters in its argument and interchanges all the "0" and "1" characters, and b = f(a).

// The dragon curve for the problem works as follows:
// Round 1 - a0f(a) = a0b
// Round 2 - a0b0f(a0b) = a0b0f(b)1f(a) = a0b0a1b
// Round 3 - a0b0a1b0a0b1a1b
// ...
// Round n - asbsasbs...asb
//            0 1 2 3    n
//
// Where s represents the elements of what I call the skeleton.  Notice that it doesn't matter what a is so
// we can leave out the a (and b) and just return the skeleton as a string of 0's and 1's.

// But how big does n need to be to get the desired length of data?  Observe that the length of the dragon
// curve after n rounds is:
//
// 2**n * c + 2**n - 1
//
// The ( 2**n * c ) is the length of all the a and b parts and the ( 2**n - 1 ) is the length of the
// skeleton.  So if we denote the desired length as L, just solve the following for n.
//
// 2**n * c + 2**n - 1 >= L
// 2**n( c + 1 ) - 1 >= L
// 2**n( c + 1 ) >= L + 1
// 2**n >= ( L + 1 ) / ( c + 1 )
// n >= log2( ( L + 1 ) / ( c + 1 ) )

// So by knowing a, b, and the skeleton you can determine the value of any character in the filled disk just
// given its offset.

// The key to the checksum is noticing that the length of the resulting checksum will be the length of the
// data with all the 2 factors removed.  So divide the data into chunks, each with a length of the largest
// power of 2 that divides the data length.  Then each chunk will contribute one character to the checksum
// and that character can be computed independantly from all the other chunks.
//
// The checksum for a chunk is computed by combining the first two character, then combining that with the
// combination of the next two characters, and so on.

struct Disk {
    let length:    Int
    let chunkSize: Int
    let initial:   String
    let inverted:  String
    let skeleton:  String
    
    init( initial: String, length: Int ) {
        self.length   = length
        self.initial  = initial
        self.inverted = Disk.flip( data: initial )
        
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
        
        self.skeleton = skeleton
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
        let step = stride( from: startIndex + 2, to: endIndex, by: 2 )
        let result = step.reduce( self[startIndex] == self[startIndex+1] ) {
            $0 == ( self[$1] == self[$1+1] )
        }
        
        return result ? "1" : "0"
    }
}


func parse( input: AOCinput ) -> String {
    return input.line
}


func part1( input: AOCinput ) -> String {
    let initial = parse( input: input )
    let disk = Disk( initial: initial, length: 272 )

    return disk.checksum
}


func part2( input: AOCinput ) -> String {
    let initial = parse( input: input )
    let disk = Disk( initial: initial, length: 35651584 )

    return disk.checksum
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
