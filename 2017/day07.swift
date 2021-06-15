//
//         FILE: main.swift
//  DESCRIPTION: day07 - Recursive Circus
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/17/21 13:40:03
//

import Foundation

struct ImbalanceError: Error {
    let name: String
    let correctedWeight: Int
}

struct Program {
    let name: String
    let weight: Int
    let parent: String
    let children: [String]
    
    init( name: String, weight: Int, parent: String, children: [String] = [] ) {
        self.name = name
        self.weight = weight
        self.parent = parent
        self.children = children
    }
}


func findBottom( tower: [ String : Program ] ) throws -> Program {
    let list = tower.values.filter { $0.parent == "" }

    guard list.count == 1 else { throw RuntimeError( "No unique bottom found." ) }

    return list[0]
}


func balance( tower: [ String: Program ], disc: Program ) throws -> ( name: String, totalWeight: Int ) {
    let weights = try disc.children.map { try balance( tower: tower, disc: tower[$0]! ) }.sorted {
        $0.totalWeight < $1.totalWeight
    }
    
    if weights.count > 1 {
        let small = weights.first!
        let big = weights.last!
        let diff = big.totalWeight - small.totalWeight
        
        if diff > 0 {
            if small.totalWeight == weights[1].totalWeight {
                throw ImbalanceError( name: big.name, correctedWeight: tower[big.name]!.weight - diff )
            }
            throw ImbalanceError( name: small.name, correctedWeight: tower[small.name]!.weight + diff )
        }
    }
    
    return ( name: disc.name, totalWeight: weights.reduce( disc.weight, { $0 + $1.totalWeight } ) )
}


func parse( input: AOCinput ) -> [ String : Program ] {
    var tower: [ String : Program ] = [:]
    
    for line in input.lines {
        let words = line.split( whereSeparator: { " (),".contains( $0 ) } )
        let name = String( words[0] )
        let weight = Int( words[1] )!
        
        if words.count < 3 {
            if let existing = tower[name] {
                tower[name] = Program( name: name, weight: weight, parent: existing.parent )
            } else {
                tower[name] = Program( name: name, weight: weight, parent: "" )
            }
        } else {
            let kids = words[3...].map { String( $0 ) }
            
            if let existing = tower[name] {
                tower[name] = Program( name: name, weight: weight, parent: existing.parent, children: kids )
            } else {
                tower[name] = Program( name: name, weight: weight, parent: "", children: kids )
            }
            
            for kid in kids {
                if let existing = tower[kid] {
                    let weight = existing.weight
                    let children = existing.children
                    
                    tower[kid] = Program( name: kid, weight: weight, parent: name, children: children )
                } else {
                    tower[kid] = Program( name: kid, weight: 0, parent: name )
                }
            }
        }
    }
    
    return tower
}


func part1( input: AOCinput ) -> String {
    let tower = parse( input: input )
    return try! findBottom( tower: tower ).name
}


func part2( input: AOCinput ) -> String {
    let tower = parse( input: input )
    
    do {
        try _ = balance( tower: tower, disc: try findBottom( tower: tower ) )
    } catch let error as ImbalanceError {
        return "\(error.correctedWeight)"
    } catch {
        return error.localizedDescription
    }

    return "Tower already balanced"
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
