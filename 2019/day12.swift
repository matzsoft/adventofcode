//
//  main.swift
//  day12
//
//  Created by Mark Johnson on 12/12/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

func gcd( _ m: Int, _ n: Int ) -> Int {
    var a: Int = 0
    var b: Int = max( m, n )
    var r: Int = min( m, n )

    while r != 0 {
        a = b
        b = r
        r = a % b
    }
    
    return b
}

func lcm( _ m: Int, _ n: Int ) -> Int {
    let factor = gcd( m, n )
    
    return m / factor * n
}
    
struct Point {
    let x: Int
    let y: Int
    let z: Int
    
    var magnitude: Int { return abs(x) + abs(y) + abs(z) }
    
    static func +( lhs: Point, rhs: Point ) -> Point {
        return Point( x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z )
    }
}

struct Moon {
    var position: Point
    var velocity: Point
    
    init( input: String ) {
        let params = input.split( whereSeparator: { ",>".contains( $0 ) } ).map { String( $0 ) }
        let posX = Int( params[0][ params[0].index( params[0].startIndex, offsetBy: 3 )... ] )!
        let posY = Int( params[1][ params[1].index( params[1].startIndex, offsetBy: 3 )... ] )!
        let posZ = Int( params[2][ params[2].index( params[2].startIndex, offsetBy: 3 )... ] )!

        position = Point( x: posX, y: posY, z: posZ )
        velocity = Point( x: 0, y: 0, z: 0 )
    }
    
    mutating func gravity( other: Moon ) -> Void {
        let newX = velocity.x + ( other.position.x - position.x ).signum()
        let newY = velocity.y + ( other.position.y - position.y ).signum()
        let newZ = velocity.z + ( other.position.z - position.z ).signum()
        
        velocity = Point( x: newX, y: newY, z: newZ )
    }
    
    mutating func move() -> Void {
        position = position + velocity
    }
    
    func energy() -> Int {
        return position.magnitude * velocity.magnitude
    }
    
    func asString() -> String {
        return "pos=<x=\(position.x), y=\(position.y), z=\(position.z)>, vel=<x=\(velocity.x), y=\(velocity.y), z=\(velocity.z)>"
    }
}

func step( moons: inout [Moon] ) -> Void {
    for i in 0 ..< moons.count {
        for j in i + 1 ..< moons.count {
            moons[i].gravity( other: moons[j] )
            moons[j].gravity( other: moons[i] )
        }
        moons[i].move()
    }
}
guard CommandLine.arguments.count > 1 else {
    print( "No input file specified" )
    exit( 1 )
}

let input = try String( contentsOfFile: CommandLine.arguments[1] )
let initial = input.split( separator: "\n" ).map { Moon( input: String( $0 ) ) }
var moons = initial

for stepNum in 1 ... 1000 {
    step( moons: &moons )
//    print()
//    print( "After \(stepNum) steps:" )
//    moons.forEach { print( $0.asString() ) }
}

print( "Part 1: \( moons.reduce( 0, { $0 + $1.energy() } ) )" )

var xSteps = 0
var ySteps = 0
var zSteps = 0

moons = initial
for stepNum in 1 ... Int.max {
    guard xSteps * ySteps * zSteps == 0 else { break }
    
    step( moons: &moons )
    if xSteps == 0 && moons.allSatisfy( { $0.velocity.x == 0 } ) {
        xSteps = stepNum
    }
    if ySteps == 0 && moons.allSatisfy( { $0.velocity.y == 0 } ) {
        ySteps = stepNum
    }
    if zSteps == 0 && moons.allSatisfy( { $0.velocity.z == 0 } ) {
        zSteps = stepNum
    }
}

print( "Part 2: \( 2 * lcm( lcm( xSteps, ySteps ), zSteps ) )" )
