//
//         FILE: main.swift
//  DESCRIPTION: day24 - It Hangs in the Balance
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/17/21 15:55:47
//

import Foundation
import Library

class Optimiser {
    let goal:      Int
    let weights:   [Int]
    var prefix:    [Int]
    var weight:    Int
    var best:      [Int]?
    var currentQE: Int
    var bestQE:    Int

    init( goal: Int, weights: [Int] ) {
        self.goal      = goal
        self.weights   = weights
        self.prefix    = []
        self.weight    = 0
        self.best      = nil
        self.currentQE = 1
        self.bestQE    = Int.max
    }

    init( other: Optimiser, weights: [Int], candidate: Int = 0 ) {
        self.goal      = other.goal
        self.weights   = weights
        self.best      = other.best
        self.bestQE    = other.bestQE
        if candidate == 0 {
            self.prefix    = other.prefix
            self.weight    = other.weight
            self.currentQE = other.currentQE
        } else {
            self.prefix    = other.prefix + [ candidate ]
            self.weight    = other.weight + candidate
            self.currentQE = other.currentQE * candidate
        }
    }

    func checkBest( bundle: [Int], QE: Int ) -> Bool {
        if let best = best {
            if bundle.count < best.count || ( bundle.count == best.count && QE < bestQE ) {
                self.best = bundle
                bestQE = QE
                return true
            }
            return false
        }

        self.best = bundle
        bestQE = QE
        return true
    }
    
    func findFewest() -> Bool {
        guard !weights.isEmpty else { return false }
        if let best = best, best.count <= prefix.count { return false }

        let candidate = weights.first!
        if weight + candidate == goal {
            return checkBest( bundle: prefix + [candidate], QE: currentQE * candidate )
        }

        let weights = Array( weights.dropFirst() )
        var newStuff = false

        // with candidate
        if weight + candidate < goal {
            let optimiser = Optimiser( other: self, weights: weights, candidate: candidate )

            if optimiser.findFewest() {
                best = optimiser.best
                bestQE = optimiser.bestQE
                newStuff = true
            }
        }

        // withour candidate
        let optimiser = Optimiser( other: self, weights: weights, candidate: 0 )

        if optimiser.findFewest() {
            best = optimiser.best
            bestQE = optimiser.bestQE
            newStuff = true
        }

        return newStuff
    }
}


func parse( input: AOCinput ) -> [Int] {
    return input.lines.map { Int( $0 )! }.sorted( by: > )
}


func part1( input: AOCinput ) -> String {
    let weights = parse( input: input )
    let optimiser = Optimiser( goal: weights.reduce( 0, + ) / 3, weights: weights )
    
    if optimiser.findFewest() {
        return "\( optimiser.bestQE )"
    }
    
    return "Failure"
}


func part2( input: AOCinput ) -> String {
    let weights = parse( input: input )
    let optimiser = Optimiser( goal: weights.reduce( 0, + ) / 4, weights: weights )
    
    if optimiser.findFewest() {
        return "\( optimiser.bestQE )"
    }
    
    return "Failure"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
