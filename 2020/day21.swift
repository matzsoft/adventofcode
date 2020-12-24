//
//  main.swift
//  day21
//
//  Created by Mark Johnson on 12/23/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

struct Food {
    let ingredients: Set<String>
    let allergens: Set<String>
    
    init( ingredients: Set<String>, allergens: Set<String> ) {
        self.ingredients = ingredients
        self.allergens = allergens
    }
    
    init( input: Substring ) {
        let groups = input.components( separatedBy: "(contains" )
        
        ingredients = Set( groups[0].split( separator: " " ).map { String( $0 ) } )
        allergens = Set( groups[1].dropLast().split { ", ".contains( $0 ) }.map { String( $0 ) } )
    }
}


let inputFile = "/Users/markj/Development/adventofcode/2020/input/day21.txt"
let foods = try String( contentsOfFile: inputFile ).split( separator: "\n" ).map { Food( input: $0 ) }
var ingredients = foods.reduce( into: Set<String>(), { $0.formUnion( $1.ingredients ) } )
var allergens = foods.reduce( into: Set<String>(), { $0.formUnion( $1.allergens ) } )
var dangerous: [ String : String ] = [:]

while !allergens.isEmpty {
    for allergen in allergens {
        let candidates = foods.filter { $0.allergens.contains( allergen ) }.map {
            Food( ingredients: $0.ingredients.intersection( ingredients ), allergens: $0.allergens )
        }
        let suspects = candidates.reduce( into: candidates[0].ingredients, {
            $0.formIntersection( $1.ingredients )
        } )
        
        if suspects.count == 1 {
            let ingredient = suspects.first!
            
            allergens.remove( allergen )
            ingredients.remove( ingredient )
            dangerous[ingredient] = allergen
            break
        }
    }
}

let part1 = ingredients.reduce( 0 ) { sum, ingredient in
    sum + foods.reduce( 0 ) { $0 + ( $1.ingredients.contains( ingredient ) ? 1 : 0 ) }
}
let part2 = dangerous.sorted { $0.value < $1.value }.map { $0.key }.joined( separator: "," )

print( "Part 1: \( part1 )" )
print( "Part 2: \( part2 )" )
