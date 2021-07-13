//
//         FILE: main.swift
//  DESCRIPTION: day20 - Infinite Elves and Infinite Houses
//        NOTES: See comments about lower bounds.
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/12/21 14:50:43
//

import Foundation

func pow( _ base: Int, _ exponent: Int ) -> Int {
    Int( pow( Double( base ), Double( exponent ) ) )
}

class Primes {
    let limit: Int
    let primes: [Int]
    
    init( to n: Int ) {
        self.limit = n
        guard n > 1 else { self.primes = []; return }
        
        let d = Double( n )
        let squareRootN = Int( d.squareRoot() )
        var composite = Array( repeating: false, count: n + 1 ) // The sieve
        var primes = [ 2 ]

        if n < 150 {
            primes.reserveCapacity( n )
        } else {
            // Upper bound for the number of primes up to and including `n`,  from https://en.wikipedia.org/wiki/Prime_number_theorem#Non-asymptotic_bounds_on_the_prime-counting_function :
            primes.reserveCapacity( Int( d / ( log( d ) - 4 ) ) )
        }
        
        var p = 3
        for q in stride( from: 2, through: n, by: 2 ) { composite[q] = true }
        while p <= squareRootN {
            if !composite[p] {
                primes.append( p )
                for q in stride( from: p * p, through: n, by: p ) {
                    composite[q] = true
                }
            }
            p += 2
        }
        
        while p <= n {
            if !composite[p] {
                primes.append( p )
            }
            p += 2
        }
        
        self.primes = primes
    }
    
    subscript( _ index: Int ) -> Int {
        return primes[index]
    }
    
    func primeFactors( of n: Int ) -> [ ( Int, Int ) ] {
        let squareRootN = Int( Double( n ).squareRoot() )
        var n = n
        var factors = [ ( Int, Int ) ]()
        
        for p in primes {
            var power = 0
            
            while n % p == 0 {
                n /= p
                power += 1
            }
            
            if power > 0 { factors.append( ( p, power ) ) }
            if n == 1 { break }
            if p > squareRootN { factors.append( ( n, 1 ) ); break }
        }
        
        return factors
    }
    
    func sumFactors( of n: Int ) -> Int {
        let factors = primeFactors( of: n )
        var sum = 1
        
        for ( p, e ) in factors {
            var factor = 1
            for _ in 1 ... e { factor = 1 + factor * p }
            sum *= factor
        }
        
        return sum
    }
    
    func factors( of factors: [ ( Int, Int ) ] ) -> [ [ ( Int, Int ) ] ] {
        if factors.count == 1 {
            return ( 0 ... factors[0].1 ).map { [ ( factors[0].0, $0 ) ] }
        }
        
        let others = self.factors( of: Array( factors.dropFirst() ) )
        var result = [ [ ( Int, Int ) ] ]()
        
        for power in 0 ... factors[0].1 {
            for other in others {
                result.append( [ ( factors[0].0, power ) ] + other )
            }
        }
        
        return result
    }
    
    func factors( of n: Int ) -> [Int] {
        guard n > 3 else { return [ 1, n ] }
        
        let factors = factors( of: primeFactors( of: n ) )
        return factors.map { $0.map { pow( $0.0, $0.1 ) }.reduce( 1, * ) }.sorted()
    }
}


func parse( input: AOCinput ) -> Any? {
    return nil
}


// Investigation of the primes.sumFactors(of:) function shows that it always stays below the line of
// "10y = 46x". Hence I can choose a reasonable lower bound for my linear search.
func part1( input: AOCinput ) -> String {
    let target = ( Int( input.line )! + 9 ) / 10         // Factor out the 10 presents per house.
    let primes = Primes( to: Int( Double( target ).squareRoot() ) )
    let lowerBound = target / 46 * 10
    
    for house in lowerBound... {
        if primes.sumFactors( of: house ) >= target {
            return "\(house)"
        }
    }
    
    return "Failure"
}


// Investigation of the function for presents in a house shows that it always stays below the line of
// "100y = 396x". Hence I can choose a reasonable lower bound for my linear search.
func part2( input: AOCinput ) -> String {
    let target = ( Int( input.line )! + 10 ) / 11         // Factor out the 11 presents per house.
    let primes = Primes( to: Int( Double( target ).squareRoot() ) )
    let lowerBound = target / 396 * 100

    for house in lowerBound... {
        if primes.factors( of: house ).filter( { $0 >= ( house + 49 ) / 50 } ).reduce( 0, + ) >= target {
            return "\(house)"
        }
    }

    return "Failure"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )


// Tools for getting the lower bound on my searches.
// Would be nice to do some research and find the limit of the sum of factors of n as n approaches infinity.
/*
extension Point2D {
    var slope: Double? {
        guard x != 0 else { return nil }
        return Double( y ) / Double( x )
    }
}

func part3( input: AOCinput ) -> String {
    let target = ( Int( input.line )! + 10 ) / 11         // Factor out the 11 presents per house.
    let primes = Primes( to: Int( Double( target ).squareRoot() ) )
    var points = [Point2D]()
    var highest = 0
    
    for n in 1...  {
        let sum = primes.factors( of: n ).filter( { $0 >= ( n + 49 ) / 50 } ).reduce( 0, + )
        
        if sum > highest {
            highest = sum
            points.append( Point2D( x: n, y: sum ) )
            if sum > target + 100000 { break }
        }
    }
    
    let best = points.max( by: { $0.slope! < $1.slope! } )!
    
    print( "\(best): \(best.slope!)" )
    print( "\(points.last!): \(points.last!.slope!)" )

    return ""
}
*/
