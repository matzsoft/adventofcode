//
//         FILE: main.swift
//  DESCRIPTION: day20 - Infinite Elves and Infinite Houses
//        NOTES: I tried to get fancy to decrease the run time with no success.  See the comments below.
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/12/21 14:50:43
//

import Foundation

// I realized that the number of presents in house n is just sigma(n).  (sigma(n) is the sum of the
// factors of n).  It turns out that using this fact and putting a lower bound on the search reduces the
// running time, but not by a lot.  And finding the lower bound requires an upperbound on sigma(n) which
// I couldn't find despite a lot of research so I hade to fudge it.  As a result I went with this simple
// sieve solution.
func part1( input: AOCinput ) -> String {
    let target = ( Int( input.line )! + 9 ) / 10         // Factor out the 10 presents per house.
    let limit = target / 4
    var sieve = Array(repeating: 1, count: limit + 1 )
    
    for i in 2 ... limit {
        if sieve[i] + i >= target { return "\(i)" }
        for j in stride( from: i, through: limit, by: i ) {
            sieve[j] += i
        }
    }
    
    return "Failure"
}


// As in part1, there is a function related to sigma(n) that gives the number of presents in house n.
// Put a search using it, even with a lower bound, is much slower than the simple sieve.
func part2( input: AOCinput ) -> String {
    let target = ( Int( input.line )! + 10 ) / 11         // Factor out the 11 presents per house.
    var sieve = Array( repeating: 0, count: target + 1 )

    for i in 1 ... target {
        if sieve[i] + i >= target { return "\(i)" }
        for j in stride( from: i, through: min( target, 50 * i ), by: i ) {
            sieve[j] += i
        }
    }

    return "Failure"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
