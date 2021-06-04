//
//         FILE: main.swift
//  DESCRIPTION: day14 - Space Stoichiometry
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/03/21 13:29:49
//

import Foundation

struct Nanofactory {
    struct Node {
        let name: String
        let quantity: Int
        
        init( input: String ) {
            let fields = input.split( separator: " " )
            
            name = String( fields[1] )
            quantity = Int( fields[0] )!
        }
    }

    struct Reaction {
        let result: Node
        let ingredients: [Node]
    }

    let reactions: [ String : Reaction ]

    init( lines: [String] ) {
        reactions = Dictionary( uniqueKeysWithValues: lines.map { line-> ( String, Reaction ) in
            let fields = line.split( whereSeparator: { ",=>".contains( $0 ) } )
            let result = Node( input: String( fields.last! ) )
            
            let ingredients = fields[ 0 ..< fields.count - 1 ].map { Node( input: String( $0 ) ) }
            return ( result.name, Reaction( result: result, ingredients: ingredients ) )
        } )
    }
    
    func produce( fuelCount: Int ) -> Int {
        var need = [ "FUEL" : fuelCount ]
        var have = [ String : Int ]()
        
        while let ( name, needed ) = need.first( where: { reactions[$0.key] != nil } ) {
            let reaction = reactions[name]!
            let repeats = ( needed + reaction.result.quantity - 1 ) / reaction.result.quantity
            let extra = repeats * reaction.result.quantity - needed
            
            need[name] = need[name]! - needed
            if need[name] == 0 { need.removeValue( forKey: name ) }
            have[name, default: 0] += extra

            for ingredient in reaction.ingredients {
                let required = repeats * ingredient.quantity
                let common = min( required, have[ingredient.name] ?? 0 )
                
                need[ingredient.name, default: 0] += required - common
                have[ingredient.name, default: 0] -= common
                if have[ingredient.name] == 0 { have.removeValue( forKey: ingredient.name ) }
            }
        }
        
        return need["ORE"]!
    }
}



func parse( input: AOCinput ) -> Nanofactory {
    return Nanofactory( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    let factory = parse( input: input )
    return "\(factory.produce( fuelCount: 1 ))"
}


func part2( input: AOCinput ) -> String {
    let factory = parse( input: input )
    let oreMax = 1000000000000
    var fuel = 1
    var lowerbound = fuel
    var upperbound = 0

    while true {
        let ore = factory.produce( fuelCount: fuel )
        
        if ore < oreMax {
            lowerbound = fuel
            fuel *= 10
        } else {
            if ore == oreMax {
                lowerbound = fuel
            }
            upperbound = fuel
            break
        }
    }

    while lowerbound < upperbound - 1 {
        let midpoint = ( lowerbound + upperbound ) / 2
        let ore = factory.produce( fuelCount: midpoint )

        if ore == oreMax {
            lowerbound = midpoint
            break
        }
        
        if ore < oreMax {
            lowerbound = midpoint
        } else {
            upperbound = midpoint
        }
    }

    return "\(lowerbound)"
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
