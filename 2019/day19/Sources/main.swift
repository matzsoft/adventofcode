//
//         FILE: main.swift
//  DESCRIPTION: day19 - Tractor Beam
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/15/21 16:37:22
//

import Foundation
import Library

let blockSize = 100
let xMultiplier = 10000


class BeamChecker {
    let initialMemory: [Int]
    var minFactor:     Int?
    var maxFactor:     Int?
    var rangeFactor:   Int?

    init( initialMemory: [Int] ) {
        self.initialMemory = initialMemory
        self.minFactor     = nil
        self.maxFactor     = nil
        self.rangeFactor   = nil
    }
    
    func isHit( x: Int, y: Int ) throws -> Bool {
        let computer = Intcode( name: "DroneControl", memory: initialMemory )

        computer.inputs = [ x, y ]
        guard let output = try computer.execute() else { throw RuntimeError( "Unexpected halt" ) }
        
        return output == 1
    }
    
    func setupFactors() throws -> Void {
        minFactor = try findXmin( y: 1000 )
        maxFactor = try findXmax( xmin: minFactor!, y: 1000 )
        rangeFactor = maxFactor! - minFactor! + 1
    }

    func findXmin( y: Int ) throws -> Int {
        for x in 0 ..< Int.max {
            if try isHit( x: x, y: y ) { return x }
        }
        return Int.max
    }


    func findXmax( xmin: Int, y: Int ) throws -> Int {
        for x in xmin ..< Int.max {
            if try !isHit( x: x, y: y ) { return x - 1 }
        }
        return Int.max
    }

    func xMin( y: Int ) throws -> Int {
        guard let minFactor = minFactor else { throw RuntimeError( "xMin called out of order." ) }
        var guess = minFactor * y / 1000
        
        if try isHit( x: guess, y: y ) {
            while try guess > 0 && isHit( x: guess - 1, y: y ) {
                guess -= 1
            }
        } else {
            guess += 1
            while try !isHit( x: guess, y: y ) {
                guess += 1
            }
        }
        
        return guess
    }
    
    func xMax( y: Int ) throws -> Int {
        guard let maxFactor = maxFactor else { throw RuntimeError( "xMax called out of order." ) }
        var guess = maxFactor * y / 1000
        
        if try isHit( x: guess, y: y ) {
            while try isHit( x: guess + 1, y: y ) {
                guess += 1
            }
        } else {
            guess -= 1
            while try guess > 0 && !isHit( x: guess, y: y ) {
                guess -= 1
            }
        }
        
        return guess
    }

    func getSmallest( for range: Int ) throws -> Int {
        guard let rangeFactor = rangeFactor else { throw RuntimeError( "getSmallest called out of order." ) }
        var guess = blockSize * 1000 / rangeFactor
        
        if try xMax( y: guess ) - xMin( y: guess ) + 1 >= range {
            while try xMax( y: guess - 1 ) - xMin( y: guess - 1 ) + 1 >= range {
                guess -= 1
            }
        } else {
            while try xMax( y: guess + 1 ) - xMin( y: guess + 1 ) + 1 < range {
                guess += 1
            }
        }
        
        return guess
    }

    func qualifies( y: Int ) throws -> Bool {
        let xmin1 = try xMin( y: y )
        let xmax1 = try xMax( y: y )
        let xmin2 = try xMin( y: y + blockSize - 1 )
        let xmax2 = try xMax( y: y + blockSize - 1)
        let xstart = xmax1 - blockSize + 1
        
        guard xmin1 <= xstart else { return false }
        guard xmin2 <= xstart && xstart <= xmax2 else { return false }
        guard xmin2 <= xmax1 && xmax1 <= xmax2 else { return false }
        
        return true
    }

    func details( y: Int ) throws -> Void {
        let xmin = try xMin( y: y )
        let xmax = try xMax( y: y )
        let range = xmax - xmin + 1
        
        print( "y = \(y), xrange = \(range) ( \(xmin) - \(xmax) )" )
    }
}




func parse( input: AOCinput ) -> BeamChecker {
    let initialMemory = input.line.split( separator: "," ).map { Int( $0 )! }
    return BeamChecker( initialMemory: initialMemory )
}


func part1( input: AOCinput ) -> String {
    let checker = parse( input: input )
    var sum = 0

    for y in 0 ..< 50 {
        for x in 0 ..< 50 {
            if try! checker.isHit( x: x, y: y ) { sum += 1 }
        }
    }

    return "\(sum)"
}


func part2( input: AOCinput ) -> String {
    let checker = parse( input: input )
    
    try! checker.setupFactors()
    
    var lowerBound = try! checker.getSmallest( for: blockSize )
    var upperBound = xMultiplier - 1

    while lowerBound + 1 < upperBound {
        let middle = ( lowerBound + upperBound ) / 2
        
        if try! checker.qualifies( y: middle ) {
            upperBound = middle
        } else {
            lowerBound = middle
        }
    }
    
//    for y in 0 ... 5 {
//        try! checker.details( y: y )
//    }

    let result = try! checker.xMin( y: upperBound + blockSize - 1 ) * xMultiplier + upperBound
    return "\(result)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
