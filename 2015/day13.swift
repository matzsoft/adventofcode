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

struct Table {
    let people: [String]
    
    init( name: String ) {
        people = [ name ]
    }
    
    private init( people: [String] ) {
        self.people = people
    }
    
    func add( name: String ) -> Table {
        return Table( people: self.people + [ name ] )
    }
    
    subscript( index: Int ) -> String {
        let modIndex = index % people.count        
        return people[ modIndex < 0 ? modIndex + people.count : modIndex ]
    }
}


func getArrangements( people: [ String : [ String : Int ] ] ) -> [Int] {
    let names = people.keys.map { String( $0 ) }
    let table = Table( name: names[0] )
    let remaining = Array( names.dropFirst() )
    
    return getArrangements( people: people, table: table, remaining: remaining )
}


func getArrangements(
    people: [ String : [ String : Int ] ],
    table: Table,
    remaining: [String]
) -> [Int] {
    if remaining.count > 1 {
        return remaining.reduce( into: [Int]() ) { list, next in
            let table = table.add( name: next )
            let remaining = remaining.filter { $0 != next }
            let arrangements = getArrangements( people: people, table: table, remaining: remaining )
            
            list.append( contentsOf: arrangements )
        }
    }
    
    let table = table.add( name: remaining[0] )
    
    return [
        table.people.indices.reduce( 0 ) {
            $0 + people[ table[$1] ]![ table[ $1 - 1] ]! + people[ table[$1] ]![ table[ $1 + 1 ] ]!
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
