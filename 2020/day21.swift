//
//         FILE: main.swift
//  DESCRIPTION: day21 - Allergen Assessment
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/29/21 20:34:38
//

import Foundation
import Library

struct Food {
    let ingredients: Set<String>
    let allergens: Set<String>
    
    init( ingredients: Set<String>, allergens: Set<String> ) {
        self.ingredients = ingredients
        self.allergens = allergens
    }
    
    init( input: String ) {
        let groups = input.components( separatedBy: "(contains" )
        
        ingredients = Set( groups[0].split( separator: " " ).map { String( $0 ) } )
        allergens = Set( groups[1].dropLast().split { ", ".contains( $0 ) }.map { String( $0 ) } )
    }
}


func parse( input: AOCinput ) -> ( [Food], Set<String>, [ String : String ] ) {
    let foods = input.lines.map { Food( input: $0 ) }
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

    return ( foods, ingredients, dangerous )
}


func part1( input: AOCinput ) -> String {
    let ( foods, ingredients, _ ) = parse( input: input )
    let result = ingredients.flatMap { ing in foods.filter { $0.ingredients.contains( ing ) } }.count
    
    return "\(result)"
}


func part2( input: AOCinput ) -> String {
    let ( _, _, dangerous ) = parse( input: input )
    let result = dangerous.sorted { $0.value < $1.value }.map { $0.key }.joined( separator: "," )
    
    return "\(result)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
