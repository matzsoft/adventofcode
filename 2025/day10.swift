//
//         FILE: day10.swift
//  DESCRIPTION: Advent of Code 2025 Day 10: Factory
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2025 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/09/25 21:19:48
//

import Foundation
import Library

func pow( base: Int, exponent: Int ) -> Int {
    let base = Double( base )
    let exponent = Double( exponent )
    return Int( pow( base, exponent ) )
}

struct Results: Hashable {
    let joltages: [Int]
    let presses: Int
    
    init( count: Int ) {
        joltages = Array( repeating: 0 , count: count )
        presses = 0
    }
    
    init( joltages: [Int], presses: Int ) {
        self.joltages = joltages
        self.presses = presses
    }
    
    func press( affected: [Int] ) -> Results {
        var joltages = self.joltages
        
        for index in affected {
            joltages[index] += 1
        }
        
        return Results( joltages: joltages, presses: presses + 1 )
    }
}


struct Path: Hashable {
    let path: Set<Int>
    let results: Results
    
    init( path: Set<Int>, results: Results ) {
        self.path = path
        self.results = results
    }
    
    func advance( button: Int, result: Results ) -> Path {
        Path( path: path.union( [ button ] ), results: result )
    }
}


struct Merged: Hashable, Comparable {
    let goal: [Int]
    let presses: Int
    
    static func < ( lhs: Merged, rhs: Merged ) -> Bool { lhs.presses < rhs.presses }

    init( goal: [Int], presses: Int ) {
        self.goal = goal
        self.presses = presses
    }
    
    func advance( goal: [Int], buttons: Int, double: Bool ) -> Merged {
        let multiplier = double ? 2 : 1
        return Merged( goal: goal, presses: presses + multiplier * buttons )
    }
}


struct Machine {
    let lights: [Int]
    let joltages: [Int]
    let buttons: [[Int]]
    
    init( line: String ) {
        let fields = line.split( separator: " " )
        
        lights = fields[0].dropFirst().dropLast().map { $0 == "#" ? 1 : 0 }
        joltages = fields.last!
            .split( whereSeparator: { "{},".contains( $0 ) } )
            .map { Int( String( $0 ) )! }
        
        let buttons = fields.dropFirst().dropLast()
        self.buttons = buttons.map {
            $0.split( whereSeparator: { "(),".contains($0) } ).map { Int( String( $0 ) )! }
        }
    }
    
    func configureLights( to desired: [Int], first: Bool = true ) -> [Path] {
        var queue = [ Path( path: [], results: Results( count: lights.count ) ) ]
        var seen = Set<Set<Int>>()
        var results: [Path] = []
        
        if desired.allSatisfy( { $0 == 0 } ) { return results }
//        if desired.allSatisfy( { $0 == 0 } ) { return [ Path( path: [], results: Results( count: lights.count ) ) ] }
        while !queue.isEmpty {
            let path = queue.removeFirst()
            
            for ( index, button ) in buttons.enumerated() {
                if !path.path.contains( index ) {
                    let nextResult = path.results.press( affected: button )
                    let newPath = path.advance( button: index, result: nextResult )
                    
                    if seen.insert( newPath.path ).inserted {
                        queue.append( newPath )
                        if nextResult.joltages.map( { $0 & 1 } ) == desired {
                            if first { return [newPath] }
                            results.append( newPath )
                        }
                    }
                }
            }
        }

        return results
    }
    
    func isAcceptable( joltages: [Int] ) -> Bool {
        self.joltages.indices.allSatisfy { joltages[$0] <= self.joltages[$0] }
    }
    
    func allPaths() -> [ [Int] : [Path] ] {
        let all = pow( base: 2, exponent: joltages.count )
        let desireds = ( 0 ..< all )
            .map { String( $0, radix: 2 ) }
            .map { String( repeating: "0", count: joltages.count - $0.count ) + $0 }
            .map { Array( $0 ).map { $0.wholeNumberValue! } }
        
        return desireds.reduce( into: [ [Int] : [Path] ]() ) { paths, desired in
            paths[desired] = configureLights( to: desired, first: false )
        }
    }
    
//    func configureJoltage( to desired: [Int] ) -> Int {
//        var cache = [ [Int] : Int ]()
//        let allPaths = allPaths()
//        var queue = BinaryHeap<Merged>.minHeap()
//        let start = Merged( goal: joltages, presses: 0 )
//        var seen = [ start.goal : 0 ]
//        var results = [Int]()
//        
//        queue.insert( start )
//        while let next = queue.pop() {
//            print( next.goal )
//            if next.goal.allSatisfy( { $0 == 0 } ) {
//                print( "Result: \(next.presses)" )
//                results.append( next.presses )
//            }
//            let desiredLights = next.goal.map( { $0 & 1 } )
//            
//            guard let paths = allPaths[desiredLights] else {
//                fatalError( "No paths for \(desiredLights)" )
//            }
//
//            for path in paths {
//                if zip( next.goal, path.results.joltages ).allSatisfy( { $0.0 > $0.1 && $0.0 % 2 == $0.1 % 2 } ) {
//                    let newGoal = zip( next.goal, path.results.joltages ).map {
//                        ( $0.0 - $0.1 ) / 2
//                    }
//                    let newMerged = next.advance( goal: newGoal, buttons: path.path.count, double: next != start )
//                    if let seenEntry = seen[newGoal] {
//                        if seenEntry > newMerged.presses {
//                            seen[newGoal] = newMerged.presses
//                            queue.insert( newMerged )
//                        }
//                    } else {
//                        seen[newGoal] = newMerged.presses
//                        queue.insert( newMerged )
//                    }
////                    if seen.insert( newGoal ).inserted {
////                        queue.insert( next.advance(
////                            goal: newGoal, buttons: path.path.count, double: next != start )
////                        )
////                    }
//                }
//            }
////            print( "Queue count: \(queue.count)" )
//        }
//        
//        return results.min()!
//    }

    func configureJoltage( to desired: [Int] ) -> Int {
        var cache = [ [Int] : Int ]()

        let allPaths = allPaths()
        
        func configure( to desired: [Int] ) -> Int {
            print( desired )
            if desired.allSatisfy( { $0 == 0 } ) { return 0 }
            if let cached = cache[desired] { return cached }
            
            let desiredLights = desired.map( { $0 & 1 } )
            guard let paths = allPaths[desiredLights] else {
                fatalError( "No paths for \(desiredLights)" )
            }
            
            let nextLevel = paths.reduce( into: [Int]() ) { nextLevel, path in
                if zip( desired, path.results.joltages ).allSatisfy( { $0.0 >= $0.1 } ) {
                    let newDesired = zip( desired, path.results.joltages ).map {
                        ( $0.0 - $0.1 ) / 2
                    }
                    let result = configure( to: newDesired )
                    nextLevel.append( path.path.count + 2 * result )
                }
            }
            
            let result = nextLevel.min() ?? Int( Int32.max )
            cache[desired] = result
            return result
        }

        let result = configure( to: desired )
        print( "Result: \(result)" )
        return result
    }

//    func configureJoltage( to desired: [Int] ) -> Int {
//        var cache = [ [Int] : Int ]()
//
//        let allPaths = allPaths()
//        
//        func configure( to desired: [Int] ) -> Int {
//            print( desired )
//            if desired.allSatisfy( { $0 == 0 } ) { return 0 }
//            let desiredLights = desired.map( { $0 & 1 } )
//            if let cached = cache[desiredLights] { return cached }
//            
//            guard let paths = allPaths[desiredLights] else {
//                fatalError( "No paths for \(desiredLights)" )
//            }
//            
//            let nextLevel = paths.map { path in
//                if zip( desired, path.results.joltages ).contains( where: { $0.0 < $0.1 } ) {
//                    return 0
//                } else {
//                    let newDesired = zip( desired, path.results.joltages ).map {
//                        ( $0.0 - $0.1 ) / 2
//                    }
//                    let result = configure( to: newDesired )
//                    return path.path.count + 2 * result
//                }
//            }
//            
//            let result = nextLevel.min()!
//            cache[desiredLights] = result
//            return result
//        }
//
//        let result = configure( to: desired )
//        print( "Result: \(result)" )
//        return result
////        let reducedJoltages = joltages.indices.map {
////            joltages[$0] - results[0].results.joltages[$0]
////        }
////
////        var queue = [ Results( count: lights.count ) ]
////        var seen = Set( [ queue[0].joltages ] )
////        
////        while !queue.isEmpty {
////            let buttonResults = queue.removeFirst()
////            
////            for button in buttons {
////                let nextResult = buttonResults.press( affected: button )
////
////                if nextResult.joltages == desired { return nextResult.presses }
////                if seen.insert( nextResult.joltages ).inserted && isAcceptable( joltages: joltages ) {
////                    queue.append( nextResult )
////                }
////            }
////        }
////        fatalError( "No solution found" )
//    }
}


func parse( input: AOCinput ) -> [Machine] {
    return input.lines.map { Machine( line: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let machines = parse( input: input )
    let presses = machines
        .flatMap { $0.configureLights( to: $0.lights ) }
        .map { $0.results.presses }
        .reduce( 0, + )

    return "\(presses)"
}


func part2( input: AOCinput ) -> String {
    let machines = parse( input: input )
    return "\(machines.map { $0.configureJoltage( to: $0.joltages ) }.reduce( 0, + ))"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
