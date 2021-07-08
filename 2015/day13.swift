//
//         FILE: main.swift
//  DESCRIPTION: day13 - Knights of the Dinner Table
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/07/21 19:34:08
//

import Foundation

extension Array {
    subscript( circular index: Int ) -> Element {
        let modIndex = isEmpty ? 0 : index % count
        return self[ modIndex < 0 ? modIndex + count : modIndex ]
    }
}


func getArrangements( people: [ String : [ String : Int ] ] ) -> [Int] {
    let names = people.keys.map { String( $0 ) }
    let remaining = Array( names.dropFirst() )
    
    return getArrangements( people: people, table: [ names[0] ], remaining: remaining )
}


func getArrangements(
    people: [ String : [ String : Int ] ],
    table: [String],
    remaining: [String]
) -> [Int] {
    if remaining.count > 1 {
        return remaining.reduce( into: [Int]() ) { list, next in
            let table = table + [ next]
            let remaining = remaining.filter { $0 != next }
            let arrangements = getArrangements( people: people, table: table, remaining: remaining )
            
            list.append( contentsOf: arrangements )
        }
    }
    
    let table = table + [ remaining[0] ]
    
    return [
        table.indices.reduce( 0 ) {
            let left = table[ circular: $1 - 1 ]
            let right = table[ circular: $1 + 1 ]
            return $0 + people[ table[$1] ]![left]! + people[ table[$1] ]![right]!
        }
    ]
}


func parse( input: AOCinput ) -> [ String : [ String : Int ] ] {
    let delimiters = CharacterSet.whitespaces.union( CharacterSet.punctuationCharacters )
    
    return input.lines.reduce(into: [ String : [ String : Int ] ]() ) { dict, line in
        let words = line.components( separatedBy: delimiters )
        let units = words[2] == "gain" ? Int( words[3] )! : -Int( words[3] )!
        
        dict[ words[0], default: [:] ][ words[10] ] = units
    }
}


func part1( input: AOCinput ) -> String {
    let people = parse( input: input )
    return "\( getArrangements( people: people ).max()! )"
}


func part2( input: AOCinput ) -> String {
    var people = parse( input: input )
    
    people.keys.forEach {
        people["me", default: [:] ][$0] = 0
        people[$0]!["me"] = 0
    }
    return "\( getArrangements( people: people ).max()! )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
