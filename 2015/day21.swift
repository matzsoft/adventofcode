//
//         FILE: main.swift
//  DESCRIPTION: day21 - RPG Simulator 20XX
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/13/21 18:13:34
//

import Foundation

class Player {
    var hitPoints = 0
    var damage    = 0
    var armor     = 0

    init( hitPoints: Int, damage: Int, armor: Int ) {
        self.hitPoints = hitPoints
        self.damage    = damage
        self.armor     = armor
    }
    
    init( lines: [String] ) throws {
        for line in lines {
            let words = line.components( separatedBy: ": ")
            
            switch words[0] {
            case "Hit Points":
                hitPoints = Int( words[1] )!
            case "Damage":
                damage = Int( words[1] )!
            case "Armor":
                armor = Int( words[1] )!
            default:
                throw RuntimeError( "Unknow attribute '\(words[0])' for boss in input." )
            }
        }
    }
    
    func death( opponent: Player ) -> Int {
        Int( ( Double( hitPoints ) / Double( max( opponent.damage - armor, 1 ) ) ).rounded( .up ) )
    }
}

struct Shop {
    struct Item {
        let name:   String
        let cost:   Int
        let damage: Int
        let armor:  Int
    }
    
    let weapons = [
        Item( name: "dagger",     cost: 8,  damage: 4, armor: 0 ),
        Item( name: "shortsword", cost: 10, damage: 5, armor: 0 ),
        Item( name: "warhammer",  cost: 25, damage: 6, armor: 0 ),
        Item( name: "longsword",  cost: 40, damage: 7, armor: 0 ),
        Item( name: "greataxe",   cost: 74, damage: 8, armor: 0 ),
    ]
    
    let armor = [
        Item( name: "leather",    cost: 13,  damage: 0, armor: 1 ),
        Item( name: "chainmail",  cost: 31,  damage: 0, armor: 2 ),
        Item( name: "splintmail", cost: 53,  damage: 0, armor: 3 ),
        Item( name: "bandedmail", cost: 75,  damage: 0, armor: 4 ),
        Item( name: "platemail",  cost: 102, damage: 0, armor: 5 ),
        Item( name: "noarmor",    cost: 0,   damage: 0, armor: 0 ),
    ]
    
    let rings = [
        Item( name: "damage1",  cost: 25,  damage: 1, armor: 0 ),
        Item( name: "damage2",  cost: 50,  damage: 2, armor: 0 ),
        Item( name: "damage3",  cost: 100, damage: 3, armor: 0 ),
        Item( name: "defense1", cost: 20,  damage: 0, armor: 1 ),
        Item( name: "defense2", cost: 40,  damage: 0, armor: 2 ),
        Item( name: "defense3", cost: 80,  damage: 0, armor: 3 ),
        Item( name: "noring1",  cost: 0,   damage: 0, armor: 0 ),
        Item( name: "noring2",  cost: 0,   damage: 0, armor: 0 ),
    ]
}


func parse( input: AOCinput ) -> Player {
    return try! Player( lines: input.lines )
}


func battle( me: Player, boss: Player, startValue: Int, update: ( Int, Int ) -> Int ) -> Int {
    let shop = Shop()
    var currentValue = startValue
    
    for weapon in shop.weapons {
        for armor in shop.armor {
            for ring1 in shop.rings {
                for ring2 in shop.rings {
                    if ring1.name == ring2.name { continue }
                    
                    me.damage = weapon.damage + ring1.damage + ring2.damage
                    me.armor = armor.armor + ring1.armor + ring2.armor
                    
                    let cost = weapon.cost + armor.cost + ring1.cost + ring2.cost
                    
                    currentValue = update( currentValue, cost )
                }
            }
        }
    }
    
    return currentValue
}


func part1( input: AOCinput ) -> String {
    let boss = parse( input: input )
    let me = Player( hitPoints: 100, damage: 0, armor: 0 )
    
    func update( currentValue: Int, cost: Int ) -> Int {
        if boss.death( opponent: me ) <= me.death( opponent: boss ) {
            return min( currentValue, cost )
        }
        return currentValue
    }
    
    return "\( battle( me: me, boss: boss, startValue: Int.max, update: update(currentValue:cost:) ) )"
}


func part2( input: AOCinput ) -> String {
    let boss = parse( input: input )
    let me = Player( hitPoints: 100, damage: 0, armor: 0 )
    
    func update( currentValue: Int, cost: Int ) -> Int {
        if boss.death( opponent: me ) > me.death( opponent: boss ) {
            return max( currentValue, cost )
        }
        return currentValue
    }
    
    return "\( battle( me: me, boss: boss, startValue: 0, update: update(currentValue:cost:) ) )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
