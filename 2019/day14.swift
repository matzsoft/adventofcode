//
//  main.swift
//  day14
//
//  Created by Mark Johnson on 12/14/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let oreMax = 1000000000000

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

struct Nanofactory {
    let reactions: [ String : Reaction ]
    var need: [ String : Int ] = [:]
    var have: [ String : Int ] = [ "ORE"  : Int.max ]

    init( input: String ) {
        let lines = input.split( separator: "\n" )
        var list: [ String : Reaction ] = [:]
        
        for line in lines {
            let fields = line.split( whereSeparator: { ",=>".contains( $0 ) } )
            let result = Node( input: String( fields.last! ) )
            
            guard list[result.name] == nil else {
                print( "Repeat results for \(result.name)" )
                exit(1)
            }
            
            let ingredients = fields[ 0 ..< fields.count - 1 ].map { Node( input: String( $0 ) ) }
            let reaction = Reaction( result: result, ingredients: ingredients )
            list[result.name] = reaction
        }
        reactions = list
    }
    
    mutating func reset() -> Void {
        have = [ "ORE"  : Int.max ]
    }
    
    mutating func produce( fuelCount: Int ) -> Int {
        let oreStarted = have["ORE"]!
        need = [ "FUEL" : fuelCount ]
        
        while !need.isEmpty {
            let ( name, needed ) = need.first!
            
            //print("Need \(needed) \(name)")
            need.removeValue( forKey: name )
            if needed > 0 {
                var needed = needed

                if var got = have[name] {
                    //print("We already have \(got)")
                    if got < needed {
                        needed -= got
                        have.removeValue( forKey: name )
                    } else {
                        got -= needed
                        needed = 0
                        if got == 0 {
                            have.removeValue( forKey: name )
                        } else {
                            have[name] = got
                        }
                    }
                }
                
                if needed > 0 {
                    guard let recipe = reactions[name] else { print( "No way to make \(name)" ); exit(1) }
                    
                    let multiplier = ( needed + recipe.result.quantity - 1 ) / recipe.result.quantity
                    
                    //print("Recipe is \(recipe)")
                    for ingredient in recipe.ingredients {
                        let amountNeeded = multiplier * ingredient.quantity
                        
                        if let alreadyNeeded = need[ingredient.name] {
                            //print("Adding \(amountNeeded) to \(alreadyNeeded) \(ingredient.name)")
                            need[ingredient.name] = alreadyNeeded + amountNeeded
                        } else {
                            //print("Now we need \(amountNeeded) \(ingredient.name)")
                            need[ingredient.name] = amountNeeded
                        }
                    }
                    let remaining = multiplier * recipe.result.quantity - needed
                    
                    if remaining > 0 {
                        if let alreadyHave = have[name] {
                            have[name] = alreadyHave + multiplier * recipe.result.quantity - needed
                        } else {
                            have[name] = multiplier * recipe.result.quantity - needed
                        }
                        //print("Now we have \(have[name]!) \(name)")
                    }
                }
            }
        }
        
        return oreStarted - have["ORE"]!
    }
    
    func haveAsString() -> String {
        let haveKeys = have.keys.filter { $0 != "ORE" }
        
        return haveKeys.sorted().map { "\($0)=\(have[$0]!)" }.joined( separator: "," )
    }
}

guard CommandLine.arguments.count > 1 else {
    print( "No input file specified" )
    exit( 1 )
}

let input = try String( contentsOfFile: CommandLine.arguments[1] )
var factory = Nanofactory( input: input )
var fuel = 1
var lowerbound = fuel
var upperbound = 0

while true {
    factory.reset()

    let ore = factory.produce( fuelCount: fuel )
    
    if fuel == 1 {
        print( "Part 1: \(ore)" )
    }
    
    if ore < oreMax {
        lowerbound = fuel
        fuel *= 10
    } else if ore == oreMax {
        lowerbound = fuel
        upperbound = fuel
        break
    } else {
        upperbound = fuel
        break
    }
}

while lowerbound < upperbound - 1 {
    factory.reset()

    let midpoint = ( lowerbound + upperbound ) / 2
    let ore = factory.produce( fuelCount: midpoint )

    if ore < oreMax {
        lowerbound = midpoint
    } else if ore == oreMax {
        lowerbound = fuel
        upperbound = fuel
        break
    } else {
        upperbound = midpoint
    }
}

print( "Part 2: \(lowerbound)" )
