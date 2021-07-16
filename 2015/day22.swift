//
//         FILE: main.swift
//  DESCRIPTION: day22 - Wizard Simulator 20XX
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/14/21 13:52:15
//

import Foundation

class Player: CustomStringConvertible {
    var hitPoints = 0
    var damage    = 0
    var armor     = 0
    var mana      = 0

    var description: String {
        "hitPoints: \(hitPoints), damage: \(damage), armor: \(armor), mana: \(mana)"
    }
    
    internal init( hitPoints: Int = 0, damage: Int = 0, armor: Int = 0, mana: Int = 0 ) {
        self.hitPoints = hitPoints
        self.damage    = damage
        self.armor     = armor
        self.mana      = mana
    }
    
    init( lines: [String] ) throws {
        for line in lines {
            let words = line.components( separatedBy: ": ")
            
            switch words[0] {
            case "Hit Points":
                hitPoints = Int( words[1] )!
            case "Damage":
                damage = Int( words[1] )!
            default:
                throw RuntimeError( "Unknow attribute '\(words[0])' for boss in input." )
            }
        }
    }
    
    var copy: Player {
        return Player( hitPoints: hitPoints, damage: damage, armor: armor, mana: mana )
    }
}


struct Spell: CustomStringConvertible {
    enum Name: String { case magicMissle, drain, shield, poison, recharge }

    let name:     Name
    let cost:     Int
    let duration: Int
    let damage:   Int
    let heal:     Int
    let armor:    Int
    let mana:     Int

    var description: String { return name.rawValue }
    
    init(
        name: Name, cost: Int, duration: Int = 0, damage: Int = 0,
        heal: Int = 0, armor: Int = 0, mana: Int = 0
    ) {
        self.name = name
        self.cost = cost
        self.duration = duration
        self.damage = damage
        self.heal = heal
        self.armor = armor
        self.mana = mana
    }
    
    func cast( player: Player, boss: Player ) -> Effect? {
        player.mana -= cost
        switch name {
        case .magicMissle:
            boss.hitPoints -= damage
            return nil
        case .drain:
            player.hitPoints += heal
            boss.hitPoints -= damage
            return nil
        case .shield:
            player.armor += armor
            return Effect( spell: self )
        case .poison:
            return Effect( spell: self )
        case .recharge:
            return Effect( spell: self )
        }
    }
}


struct Shop {
    let spells = [
        Spell( name: .magicMissle, cost: 53,  damage  : 4              ),
        Spell( name: .drain,       cost: 73,  damage  : 2, heal  : 2   ),
        Spell( name: .shield,      cost: 113, duration: 6, armor : 7   ),
        Spell( name: .poison,      cost: 173, duration: 6, damage: 3   ),
        Spell( name: .recharge,    cost: 229, duration: 5, mana  : 101 ),
    ]
}

struct Effect {
    let spell: Spell
    var duration: Int
    
    init( spell: Spell ) {
        self.spell = spell
        self.duration = spell.duration
    }
    
    mutating func apply( player: Player, boss: Player ) -> Void {
        switch spell.name {
        case .poison:
            boss.hitPoints -= spell.damage
        case .recharge:
            player.mana += spell.mana
        default:
            break
        }
        
        duration -= 1
    }
    
    func remove( player: Player, boss: Player ) -> Void {
        if spell.name == .shield {
            player.armor -= spell.armor
        }
    }
}


struct Game {
    enum Difficulty { case easy, hard }

    let player = Player( hitPoints: 50, damage: 0, armor: 0, mana: 500 )
    let boss: Player
    let difficulty: Difficulty
    let shop = Shop()
    var debug: Bool
    
    init( boss: Player, difficulty: Game.Difficulty, debug: Bool = false ) {
        self.boss = boss
        self.difficulty = difficulty
        self.debug = debug
    }
    
    var cheapestWin: Int? {
        cheapestWin( player: player.copy, boss: boss.copy, effects: [:], turn: 1 )
    }
    
    func cheapestWin( player: Player, boss: Player, effects: [ Spell.Name : Effect ], turn: Int ) -> Int? {
        func debugPrint( message: String ) -> Void {
            if debug {
                let prefix = String( repeating: " ", count: turn - 1 )
                print( "\(prefix)Turn \(turn) - \(message)" )
                print( "\(prefix)player = \(player)" )
                print( "\(prefix)boss = \(boss)" )
                if player.mana < 0 { exit(1) }
            }
        }
        
        debugPrint( message: "start" )
        var effects = effects
        
        if difficulty == .hard {
            player.hitPoints -= 1
            if player.hitPoints <= 0 {
                debugPrint(message: "player looses from difficulty")
                return nil
            }
        }
        effects.filter { $0.value.duration == 0 }.forEach {
            effects[$0.key]?.remove( player: player, boss: boss )
        }
        effects = effects.filter { $0.value.duration > 0 }
        for key in effects.keys { effects[key]!.apply( player: player, boss: boss ) }
        debugPrint( message: "effects applied" )
        
        let leastCost = shop.spells.compactMap { spell -> Int? in
            let player = player.copy
            let boss = boss.copy
            var effects = effects

            func debugPrint( message: String ) -> Void {
                if debug {
                    let prefix = String( repeating: " ", count: turn - 1 )
                    print( "\(prefix)Turn \(turn) - \(message)" )
                    print( "\(prefix)player = \(player)" )
                    print( "\(prefix)boss = \(boss)" )
                    if player.mana < 0 { exit(1) }
                }
            }
            
            if spell.cost > player.mana {
                debugPrint( message: "player can't afford \(spell)" )
                return nil
            }
            if effects[spell.name] != nil {
                debugPrint( message: "can't cast \(spell), already in effect")
                return nil
            }
            if let event = spell.cast( player: player, boss: boss ) {
                effects[event.spell.name] = Effect( spell: event.spell )
            }
            debugPrint( message: "player cast \(spell)" )

            effects.filter { $0.value.duration == 0 }.forEach {
                effects[$0.key]?.remove( player: player, boss: boss )
            }
            effects = effects.filter { $0.value.duration > 0 }
            for key in effects.keys { effects[key]!.apply( player: player, boss: boss ) }
            debugPrint( message: "effects applied" )

            if boss.hitPoints <= 0 {
                debugPrint( message: "boss killed with \(spell.cost)" )
                return spell.cost
            }
            player.hitPoints -= max( boss.damage - player.armor, 1 )
            if player.hitPoints <= 0 {
                debugPrint( message: "boss kills player" )
                return nil
            }
            if let recursed =
                cheapestWin( player: player.copy, boss: boss.copy, effects: effects, turn: turn + 2 ) {
                debugPrint( message: "\(spell) lead to victory" )
                return recursed + spell.cost
            }
            debugPrint( message: "\(spell) lead to death" )
            return nil
        }.min()
        
        if let leastCost = leastCost {
            debugPrint( message: "exit with \(leastCost)" )
            return leastCost
        }
        debugPrint( message: "exit with nil" )
        return nil
    }
}


func parse( input: AOCinput ) -> Player {
    return try! Player( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    let boss = parse( input: input )
    let game = Game( boss: boss, difficulty: .easy, debug: false )
    
    guard let cost = game.cheapestWin else { return "Failure" }
    return "\(cost)"
}


func part2( input: AOCinput ) -> String {
    let boss = parse( input: input )
    let game = Game( boss: boss, difficulty: .hard, debug: true )
    
    guard let cost = game.cheapestWin else { return "Failure" }
    return "\(cost)"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
