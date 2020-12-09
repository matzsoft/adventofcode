//
//  main.swift
//  day06
//
//  Created by Mark Johnson on 12/05/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

struct Group {
    let anyone: Set<String.Element>
    let everyone: Set<String.Element>

    init( input: String ) {
        let people = input.split( separator: "\n" ).map { $0.map { $0 } }.map { Set( $0 ) }
        
        anyone = people.reduce( people[0] ) { $0.union( $1 ) }
        everyone = people.reduce( people[0] ) { $0.intersection( $1 ) }
    }
}

let inputFile = "/Users/markj/Development/adventofcode/2020/input/day06.txt"
let groups = try String( contentsOfFile: inputFile ).components( separatedBy: "\n\n" ).map {
    Group( input: $0 )
}

print( "Part 1: \(groups.map { $0.anyone.count }.reduce( 0 ) { $0 + $1 })" )
print( "Part 2: \(groups.map { $0.everyone.count }.reduce( 0 ) { $0 + $1 })" )
