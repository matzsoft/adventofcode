//
//         FILE: main.swift
//  DESCRIPTION: day20 - Particle Swarm
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/23/21 15:12:48
//

import Foundation
import Library

struct Particle {
    struct SubTime: Comparable, Hashable {
        let second: Int
        let chronon: Int
        
        static func ==( left: SubTime, right: SubTime ) -> Bool {
            return left.second == right.second && left.chronon == right.chronon
        }
        
        static func <( left: SubTime, right: SubTime ) -> Bool {
            return left.second < right.second || left.second == right.second && left.chronon < right.chronon
        }
    }

    let position: Point3D
    let velocity: Point3D
    let acceleration: Point3D
    
    var p: Point3D { return position }
    var v: Point3D { return velocity }
    var a: Point3D { return acceleration }
    
    init( input: String ) {
        let words = input.split( whereSeparator: { "<>, =".contains( $0 ) } )
        
        position = Point3D( x: Int( words[1] )!, y: Int( words[2] )!, z: Int( words[3] )! )
        velocity = Point3D( x: Int( words[5] )!, y: Int( words[6] )!, z: Int( words[7] )! )
        acceleration = Point3D( x: Int( words[9] )!, y: Int( words[10] )!, z: Int( words[11] )! )
    }
    
    init( p: Point3D, v: Point3D, a: Point3D ) {
        position = p
        velocity = v
        acceleration = a
    }
    
    func updatePosition( time: Int ) -> Point3D {
        let px1 = p.x + v.x * time + a.x * time * ( time + 1 ) / 2
        let py1 = p.y + v.y * time + a.y * time * ( time + 1 ) / 2
        let pz1 = p.z + v.z * time + a.z * time * ( time + 1 ) / 2
        
        return Point3D( x: px1, y: py1, z: pz1 )
    }
    
    func collisionTimeLinear( other: Particle ) -> Int? {
        let deltaV = v.x - other.v.x
        let deltaX = p.x - other.p.x
        
        if deltaV == 0 {
            // Velocities equal - no collision
            return nil
        }
        
        if deltaX % deltaV != 0 {
            // Non integer result - no collision
            return nil
        }
        
        return -deltaX / deltaV
    }
    
    func collisionTimesQuadratic( other: Particle ) -> [Int] {
        let deltaX = p.x - other.p.x
        let deltaV = v.x - other.v.x
        let deltaA = a.x - other.a.x
        let bPrime = 2 * deltaV + deltaA
        let square = bPrime * bPrime - 8 * deltaA * deltaX
        
        guard square >= 0 else { return [] }
        
        let root = Int( sqrt( Double( square ) ) )
        
        guard root * root == square else { return [] }
        
        var times: [Int] = []
        let time1 = ( -bPrime + root ) / ( 2 * deltaA )
        let time2 = ( -bPrime - root ) / ( 2 * deltaA )
        
        if time1 >= 0 && ( -bPrime + root ) % ( 2 * deltaA ) == 0 { times.append( time1 ) }
        if time2 >= 0 && ( -bPrime - root ) % ( 2 * deltaA ) == 0 { times.append( time2 ) }
        
        return times
    }
    
    func confirmTime( other: Particle, time: Int ) -> SubTime? {
        let old1 = updatePosition( time: time - 1 )
        let new1 = updatePosition( time: time )
        let old2 = other.updatePosition( time: time - 1 )
        let new2 = other.updatePosition( time: time )

        if Point3D( x: new1.x, y: old1.y, z: old1.z ) == Point3D( x: new2.x, y: old2.y, z: old2.z ) {
            return SubTime( second: time - 1, chronon: 1 )
        }
        
        if Point3D( x: new1.x, y: new1.y, z: old1.z ) == Point3D( x: new2.x, y: new2.y, z: old2.z ) {
            return SubTime( second: time - 1, chronon: 2 )
        }
        
        if Point3D( x: new1.x, y: new1.y, z: new1.z ) == Point3D( x: new2.x, y: new2.y, z: new2.z ) {
            return SubTime( second: time, chronon: 0 )
        }
        
        return nil
    }
    
    func collisionTimes( other: Particle ) -> SubTime? {
        if a.x == other.a.x {
            if let seconds = collisionTimeLinear( other: other ) {
                return confirmTime( other: other, time: seconds )
            }
            return nil
        }

        let seconds = collisionTimesQuadratic( other: other )
        let subtimes = seconds.compactMap { confirmTime( other: other, time: $0 ) }
        
        return subtimes.min()
    }
}

func findSlowest( particles: [Particle] ) -> ( offset: Int, element: Particle ) {
    let sorted = particles.enumerated().sorted { $0.element.a.magnitude < $1.element.a.magnitude }
    var candidates = sorted.filter { $0.element.a.magnitude == sorted[0].element.a.magnitude }
    
    while true {
        let next = candidates.map { ( particle ) -> ( offset: Int, element: Particle ) in
            let nextV = particle.element.velocity + particle.element.acceleration
            let nextP = Particle( p: particle.element.p, v: nextV, a: particle.element.a )
            
            return ( offset: particle.offset, element: nextP )
        }
        
        let done = ( 0 ..< next.count ).allSatisfy {
            candidates[$0].element.v.magnitude < next[$0].element.v.magnitude
        }
        
        candidates = next
        if done { break }
    }
    
    return candidates.min { $0.element.v.magnitude < $1.element.v.magnitude }!
}


func detectCollisions( particles: [Particle] ) -> Int {
    var remaining = Set( 0 ..< particles.count )
    var collisions: [ Particle.SubTime : [Set<Int>] ] = [:]

    for i in 0 ..< particles.count - 1 {
        let range = i + 1 ..< particles.count
        let mine = range.reduce( into: [ Particle.SubTime : Set<Int> ]() ) { ( dict, j ) in
            if let time = particles[i].collisionTimes( other: particles[j] ) {
                dict[time] = ( dict[time] ?? Set<Int>() ).union( Set( [ i, j ] ) )
            }
        }
        
        for collision in mine {
            guard let list = collisions[collision.key] else {
                collisions[collision.key] = [ collision.value ]
                continue
            }
            
            if list.allSatisfy( { !collision.value.isSubset( of: $0 ) } ) {
                collisions[collision.key]!.append( collision.value )
            }
        }
    }

    collisions.values.forEach { $0.forEach { remaining.subtract( $0 ) } }
    return remaining.count
}


func parse( input: AOCinput ) -> [Particle] {
    return input.lines.map { Particle( input: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let particles = parse( input: input )
    let slowPoke = findSlowest( particles: particles )

    return "\(slowPoke.offset)"
}


func part2( input: AOCinput ) -> String {
    let particles = parse( input: input )
    return "\(detectCollisions( particles: particles ))"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
