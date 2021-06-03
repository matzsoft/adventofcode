//
//         FILE: main.swift
//  DESCRIPTION: day12 - The N-Body Problem
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/02/21 23:08:40
//

import Foundation

class Moon {
    var position: Point3D
    var velocity: Point3D
    var energy: Int { position.magnitude * velocity.magnitude }
    
    var asString: String {
        "pos=<x=\(position.x), y=\(position.y), z=\(position.z)>, " +
            "vel=<x=\(velocity.x), y=\(velocity.y), z=\(velocity.z)>"
    }

    init( input: String ) {
        let params = input.split( whereSeparator: { ",>".contains( $0 ) } ).map { String( $0 ) }
        let posX = Int( params[0][ params[0].index( params[0].startIndex, offsetBy: 3 )... ] )!
        let posY = Int( params[1][ params[1].index( params[1].startIndex, offsetBy: 3 )... ] )!
        let posZ = Int( params[2][ params[2].index( params[2].startIndex, offsetBy: 3 )... ] )!

        position = Point3D( x: posX, y: posY, z: posZ )
        velocity = Point3D( x: 0, y: 0, z: 0 )
    }
    
    func gravity( other: Moon ) -> Void {
        let newX = velocity.x + ( other.position.x - position.x ).signum()
        let newY = velocity.y + ( other.position.y - position.y ).signum()
        let newZ = velocity.z + ( other.position.z - position.z ).signum()
        
        velocity = Point3D( x: newX, y: newY, z: newZ )
    }
    
    func move() -> Void {
        position = position + velocity
    }
}

func step( moons: [Moon] ) -> Void {
    for i in 0 ..< moons.count {
        for j in i + 1 ..< moons.count {
            moons[i].gravity( other: moons[j] )
            moons[j].gravity( other: moons[i] )
        }
        moons[i].move()
    }
}


func parse( input: AOCinput ) -> [Moon] {
    return input.lines.map { Moon( input: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let moons = parse( input: input )
    let limit = Int( input.extras[0] )!
    
    ( 1 ... limit ).forEach { _ in step( moons: moons ) }
    return "\(moons.reduce( 0 ) { $0 + $1.energy } )"
}


func part2( input: AOCinput ) -> String {
    let moons = parse( input: input )
    var steps = Point3D( x: 0, y: 0, z: 0 )
    
    for stepNum in 1 ... Int.max {
        guard steps.x * steps.y * steps.z == 0 else { break }
        
        step( moons: moons )
        if steps.x == 0 && moons.allSatisfy( { $0.velocity.x == 0 } ) {
            steps = Point3D( x: stepNum, y: steps.y, z: steps.z )
        }
        if steps.y == 0 && moons.allSatisfy( { $0.velocity.y == 0 } ) {
            steps = Point3D( x: steps.x, y: stepNum, z: steps.z )
        }
        if steps.z == 0 && moons.allSatisfy( { $0.velocity.z == 0 } ) {
            steps = Point3D( x: steps.x, y: steps.y, z: stepNum )
        }
    }
    return "\( 2 * lcm( lcm( steps.x, steps.y ), steps.z ) )"
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
