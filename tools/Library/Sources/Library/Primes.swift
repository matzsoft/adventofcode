//
//  Primes.swift
//  day20
//
//  Created by Mark Johnson on 8/6/21.
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
            if p >= squareRootN { factors.append( ( n, 1 ) ); n = 1; break }
        }
        
        if n > 1 { factors.append( ( n, 1 ) ) }
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
    
    func totient( of n: Int ) -> Int {
        let factors = primeFactors( of: n )
        
        return factors.reduce( 1, { $0 * pow( $1.0, $1.1 - 1 ) * ( $1.0 - 1 ) } )
    }
}
