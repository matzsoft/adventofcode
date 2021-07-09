//
//         FILE: main.swift
//  DESCRIPTION: day15 - Science for Hungry People
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/08/21 11:45:57
//

import Foundation

// Butterscotch: capacity -1, durability -2, flavor 6, texture 3, calories 8
// Cinnamon: capacity 2, durability 3, flavor -2, texture -1, calories 3
struct Ingredient {
    let name:       String
    let capacity:   Int
    let durability: Int
    let flavor:     Int
    let texture:    Int
    let calories:   Int
    
    init( line: String ) {
        let words = line.split { ": ,".contains( $0 ) }
        
        name       = String( words[0] )
        capacity   = Int( words[2] )!
        durability = Int( words[4] )!
        flavor     = Int( words[6] )!
        texture    = Int( words[8] )!
        calories   = Int( words[10] )!
    }
}

func cookieScores( teaspoons: Int, ingredients: [Ingredient], quantities: [Int] ) -> [ ( Int, Int ) ] {
    if ingredients.count > quantities.count {
        return ( 0 ... teaspoons ).flatMap { quantity -> [ ( Int, Int ) ] in
            let teaspoons = teaspoons - quantity
            let quantities = quantities + [ quantity ]
            return cookieScores( teaspoons: teaspoons, ingredients: ingredients, quantities: quantities )
        }
    }
    
    func sumIt( attributes: [ Int ] ) -> Int {
        let pairs = zip( attributes, quantities )
        return max( 0, pairs.reduce( 0 ) { $0 + $1.0 * $1.1 } )
    }
    
    let capacity   = sumIt( attributes: ingredients.map { $0.capacity } )
    let durability = sumIt( attributes: ingredients.map { $0.durability } )
    let flavor     = sumIt( attributes: ingredients.map { $0.flavor } )
    let texture    = sumIt( attributes: ingredients.map { $0.texture } )
    let calories   = sumIt( attributes: ingredients.map { $0.calories } )

    return [ ( capacity * durability * flavor * texture, calories ) ]
}


func parse( input: AOCinput ) -> [Ingredient] {
    return input.lines.map { Ingredient( line: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let ingredients = parse( input: input )
    let scores = cookieScores( teaspoons: 100, ingredients: ingredients, quantities: [] )
    
    return "\( scores.max( by: { $0.0 < $1.0 } )!.0 )"
}


func part2( input: AOCinput ) -> String {
    let ingredients = parse( input: input )
    let scores = cookieScores( teaspoons: 100, ingredients: ingredients, quantities: [] )
    
    return "\( scores.filter { $0.1 == 500 }.max( by: { $0.0 < $1.0 } )!.0 )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
