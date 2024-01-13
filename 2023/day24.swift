//
//         FILE: day24.swift
//  DESCRIPTION: Advent of Code 2023 Day 24: Never Tell Me The Odds
//        NOTES: I knew there was an algebraic solution, but I kept getting n equations with n+1 unknowns.
//               So thanks to shahata5 on the subreddit for revealing that the trick is to eliminate the
//               time variable.  The link to his excellent description is crazy long so I will place it
//               comments below.
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/23/23 21:08:49
//

import Foundation
import Library
import BigInt

struct Hail {
    let position: Point3D
    let velocity: Point3D
    let m: Double
    let b: Double
    
    init( line: String ) {
        let numbers = line.split( whereSeparator: { ", @".contains( $0 ) } ).map { Int( $0 )! }
        position = Point3D( x: numbers[0], y: numbers[1], z: numbers[2] )
        velocity = Point3D( x: numbers[3], y: numbers[4], z: numbers[5] )
        m = Double( velocity.y ) / Double( velocity.x )
        b = Double( position.y ) - m * Double( position.x )
    }

    // For some reason
    //        let y = ( m * other.b - other.m * b ) / denom
    // gave the wrong sign for y.
    func intersection( _ other: Hail ) -> ( Double, Double ) {
        let denom = other.m - m
        let x = ( b - other.b ) / denom
        let y = ( other.m * b - m * other.b ) / denom
        return ( x, y )
    }
    
    func time( for position: ( Double, Double ) ) -> Double {
        if velocity.x != 0 { return ( position.0 - Double( self.position.x ) ) / Double( velocity.x ) }
        return ( position.1 - Double( self.position.y ) ) / Double( velocity.y )
    }
                                                                    
    func futureIntersect( _ other: Hail ) -> ( Double, Double )? {
        guard m != other.m else { return nil }
        let intersect = intersection( other )
        
        if time( for: intersect ) < 0 { return nil }
        if other.time( for: intersect ) < 0 { return nil }
        
        return intersect
    }
}


func determinant( matrix: [[BigInt]] ) -> BigInt? {
    if matrix.isEmpty { return nil }
    guard matrix.allSatisfy( { $0.count == matrix.count } ) else { return nil }
    guard matrix.count > 1 else { return matrix[0][0] }
    
    func compute( matrix: [[BigInt]] ) -> BigInt {
        guard matrix.count > 2 else { return matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0] }
        
        func submatrix( index: Int ) -> [[BigInt]] {
            matrix[1...].map { row in row.indices.filter { $0 != index }.map { row[$0] } }
        }
        
        let partials = matrix.indices.map {
            matrix[0][$0] * compute( matrix: submatrix( index: $0 ) )
        }
        
        return partials.indices
            .reduce( 0 ) { $0 + ( $1.isMultiple( of: 2 ) ? partials[$1] : -partials[$1] ) }
    }
    
    return compute( matrix: matrix )
}


func cramersRule( matrix: [[BigInt]], vector: [BigInt] ) -> [BigInt]? {
    guard let denominator = determinant( matrix: matrix ) else { return nil }
    guard denominator != 0 else { return nil }
    guard vector.count == matrix.count else { return nil }
    
    let substituted = vector.indices
        .map { variable in
            vector.indices.map { row in
                vector.indices.map { col in
                    col == variable ? vector[row] : matrix[row][col]
                }
            }
        }
    let determinants = vector.indices
        .map { determinant( matrix: substituted[$0] )! }
    
    return determinants.map { $0 / denominator }
}


func part1( input: AOCinput ) -> String {
    let hail = input.lines.map { Hail( line: $0 ) }
    let range = Double( input.extras[0] )! ... Double( input.extras[1] )!
    var count = 0
    
    for index1 in 0 ..< hail.count - 1 {
        for index2 in index1 + 1 ..< hail.count {
            if let intersect = hail[index1].futureIntersect( hail[index2] ) {
                if range.contains( intersect.0 ) && range.contains( intersect.1 ) {
                    count += 1
                }
            }
        }
    }
    return "\(count)"
}

/* From shahata5 on the subreddit.
We can create first three equations from the fact that the hailstone 0 and our rock will meet at t0
1) px0 + vx0*t0 = pxr + vxr*t0
2) py0 + vy0*t0 = pyr + vyr*t0
3) py0 + vz0*t0 = pzr + vzr*t0

We edit the three equations to isolate t0 because we don't really care about it
1) t0 = (pxr - px0) / (vx0 - vxr)
2) t0 = (pyr - py0) / (vy0 - vyr)
3) t0 = (pzr - pz0) / (vz0 - vzr)

Now we can create two equations eliminating t0 from the system
1) (pxr - px0) / (vx0 - vxr) = (pyr - py0) / (vy0 - vyr)
2) (pxr - px0) / (vx0 - vxr) = (pzr - pz0) / (vz0 - vzr)

We edit the two new equaltions to so that we get ready to expand them
1) (pxr - px0) * (vy0 - vyr) = (pyr - py0) * (vx0 - vxr)
2) (pxr - px0) * (vz0 - vzr) = (pzr - pz0) * (vx0 - vxr)

And now we expnad the equations
1) pxr*vy0 - pxr*vyr - px0*vy0 + px0*vyr = pyr*vx0 - pyr*vxr - py0*vx0 + py0*vxr
2) pxr*vz0 - pxr*vzr - px0*vz0 + px0*vzr = pzr*vx0 - pzr*vxr - pz0*vx0 + pz0*vxr

We know that those equations are true actually for any hailstone, not just hailstone 0
So now we add two new equations for hailstone N which are identical to the two above
3) pxr*vyN - pxr*vyr - pxN*vyN + pxN*vyr = pyr*vxN - pyr*vxr - pyN*vxN + pyN*vxr
4) pxr*vzN - pxr*vzr - pxN*vzN + pxN*vzr = pzr*vxN - pzr*vxr - pzN*vxN + pzN*vxr

Now we can substract equations 1 & 3 and substract 2 & 4
It will help us to get rid of those pxr*vyr, pyr*vxr and so on
We really don't want them because for cramer rule we need a linear equation a1*x+a2*y+...=c
1-3) pxr*(vy0 - vyN) + pyr*(vxN - vx0) + vxr*(pyN - py0) + vyr*(px0 - pxN) = px0*vy0 - py0*vx0 - pxN*vyN + pyN*vxN
2-4) pxr*(vz0 - vzN) + pzr*(vxN - vx0) + vxr*(pzN - pz0) + vzr*(px0 - pxN) = px0*vz0 - pz0*vx0 - pxN*vzN + pzN*vxN

Now let's just add any missing variables to the two new equations
1) pxr*(vy0 - vyN) + pyr*(vxN - vx0) + pzr*(0)         + vxr*(pyN - py0) + vyr*(px0 - pxN) + vzr*(0)         = px0*vy0 - py0*vx0 - pxN*vyN + pyN*vxN
2) pxr*(vz0 - vzN) + pyr*(0)         + pzr*(vxN - vx0) + vxr*(pzN - pz0) + vyr*(0)         + vzr*(px0 - pxN) = px0*vz0 - pz0*vx0 - pxN*vzN + pzN*vxN

That's it now we have two equations with constant coefficients for our six variables (pxr, pyr, pzr, vxr, vyr, vzr)
It means that we can choose any three hailstones (1 to N) and have six equations linear system.

vy0 - vy1    vx1 - vx0    0            py1 - py0    px0 - px1    0         = px0*vy0 - py0*vx0 - px1*vy1 + py1*vx1
vz0 - vz1    0            vx1 - vx0    pz1 - pz0    0            px0 - px1 = px0*vz0 - pz0*vx0 - px1*vz1 + pz1*vx1
vy0 - vy2    vx2 - vx0    0            py2 - py0    px0 - px2    0         = px0*vy0 - py0*vx0 - px2*vy2 + py2*vx2
vz0 - vz2    0            vx2 - vx0    pz2 - pz0    0            px0 - px2 = px0*vz0 - pz0*vx0 - px2*vz2 + pz2*vx2
vy0 - vy3    vx3 - vx0    0            py3 - py0    px0 - px3    0         = px0*vy0 - py0*vx0 - px3*vy3 + py3*vx3
vz0 - vz3    0            vx3 - vx0    pz3 - pz0    0            px0 - px3 = px0*vz0 - pz0*vx0 - px3*vz3 + pz3*vx3

Feed this matrix into Cramer's rule and we have our result: https://www.youtube.com/watch?v=RdLo-9jh2EM
*/

func part2( input: AOCinput ) -> String {
    let hail = input.lines.map { Hail( line: $0 ) }
    let ( px0, py0, pz0 ) = (
        BigInt( hail[0].position.x ), BigInt( hail[0].position.y ), BigInt( hail[0].position.z ) )
    let ( vx0, vy0, vz0 ) = (
        BigInt( hail[0].velocity.x ), BigInt( hail[0].velocity.y ), BigInt( hail[0].velocity.z ) )
    let ( px1, py1, pz1 ) = (
        BigInt( hail[1].position.x ), BigInt( hail[1].position.y ), BigInt( hail[1].position.z ) )
    let ( vx1, vy1, vz1 ) = (
        BigInt( hail[1].velocity.x ), BigInt( hail[1].velocity.y ), BigInt( hail[1].velocity.z ) )
    let ( px2, py2, pz2 ) = (
        BigInt( hail[2].position.x ), BigInt( hail[2].position.y ), BigInt( hail[2].position.z ) )
    let ( vx2, vy2, vz2 ) = (
        BigInt( hail[2].velocity.x ), BigInt( hail[2].velocity.y ), BigInt( hail[2].velocity.z ) )
    let ( px3, py3, pz3 ) = (
        BigInt( hail[3].position.x ), BigInt( hail[3].position.y ), BigInt( hail[3].position.z ) )
    let ( vx3, vy3, vz3 ) = (
        BigInt( hail[3].velocity.x ), BigInt( hail[3].velocity.y ), BigInt( hail[3].velocity.z ) )

    let matrix = [
        [ vy0 - vy1, vx1 - vx0,         0, py1 - py0, px0 - px1,         0 ],
        [ vz0 - vz1,         0, vx1 - vx0, pz1 - pz0,         0, px0 - px1 ],
        [ vy0 - vy2, vx2 - vx0,         0, py2 - py0, px0 - px2,         0 ],
        [ vz0 - vz2,         0, vx2 - vx0, pz2 - pz0,         0, px0 - px2 ],
        [ vy0 - vy3, vx3 - vx0,         0, py3 - py0, px0 - px3,         0 ],
        [ vz0 - vz3,         0, vx3 - vx0, pz3 - pz0,         0, px0 - px3 ],
    ]
    let vector = [
        BigInt( px0 * vy0 - py0 * vx0 - px1 * vy1 + py1 * vx1 ),
        BigInt( px0 * vz0 - pz0 * vx0 - px1 * vz1 + pz1 * vx1 ),
        BigInt( px0 * vy0 - py0 * vx0 - px2 * vy2 + py2 * vx2 ),
        BigInt( px0 * vz0 - pz0 * vx0 - px2 * vz2 + pz2 * vx2 ),
        BigInt( px0 * vy0 - py0 * vx0 - px3 * vy3 + py3 * vx3 ),
        BigInt( px0 * vz0 - pz0 * vx0 - px3 * vz3 + pz3 * vx3 ),
    ]
    let results = cramersRule( matrix: matrix, vector: vector )!
    return "\( results[0..<3].reduce( 0, + ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
