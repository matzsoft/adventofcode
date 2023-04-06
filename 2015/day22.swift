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
import Library

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
        self.name     = name
        self.cost     = cost
        self.duration = duration
        self.damage   = damage
        self.heal     = heal
        self.armor    = armor
        self.mana     = mana
    }
    
    func cast( game: Game ) -> Void {
        game.player.mana -= cost
        game.currentCost += cost
        switch name {
        case .magicMissle:
            game.boss.hitPoints -= damage
        case .drain:
            game.player.hitPoints += heal
            game.boss.hitPoints -= damage
        case .shield:
            game.player.armor += armor
            game.effects[name] = Effect( spell: self )
        case .poison:
            game.effects[name] = Effect( spell: self )
        case .recharge:
            game.effects[name] = Effect( spell: self )
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
    
    mutating func apply( game: Game ) -> Void {
        duration -= 1
        switch spell.name {
        case .shield:
            if duration == 0 { game.player.armor -= spell.armor }
        case .poison:
            game.boss.hitPoints -= spell.damage
        case .recharge:
            game.player.mana += spell.mana
        default:
            break
        }
    }
}


class Game {
    enum Difficulty { case easy, hard }

    let player:      Player
    let boss:        Player
    var effects:     [ Spell.Name : Effect ]
    let turn:        Int
    var minCost:     Int
    var currentCost: Int
    let shop:        Shop
    let difficulty:  Difficulty
    var debug:       Bool
    
    init( boss: Player, difficulty: Game.Difficulty, debug: Bool = false ) {
        self.player      = Player( hitPoints: 50, damage: 0, armor: 0, mana: 500 )
        self.boss        = boss
        self.effects     = [:]
        self.turn        = 1
        self.minCost     = Int.max
        self.currentCost = 0
        self.shop        = Shop()
        self.difficulty  = difficulty
        self.debug       = debug
    }
    
    internal init( other: Game, turn: Int ) {
        self.player      = other.player.copy
        self.boss        = other.boss.copy
        self.effects     = other.effects
        self.turn        = turn
        self.minCost     = other.minCost
        self.currentCost = other.currentCost
        self.shop        = other.shop
        self.difficulty  = other.difficulty
        self.debug       = other.debug
    }
    
    func debugPrint( message: String ) -> Void {
        if debug {
            let prefix = String( repeating: " ", count: turn - 1 )
            print( "\(prefix)Turn \(turn) - \(message)" )
            print( "\(prefix)player = \(player)" )
            print( "\(prefix)boss = \(boss)" )
        }
    }
    
    func debugReturn( message: String, passThru: Int? = nil ) -> Int? {
        debugPrint( message: message )
        return passThru
    }
    
    func applyEffects() -> Void {
        for key in effects.keys { effects[key]!.apply( game: self ) }
        effects = effects.filter { $0.value.duration > 0 }
        debugPrint( message: "effects applied" )
    }

    func lowestCost() -> Int? {
        debugPrint( message: "start" )
        if difficulty == .hard {
            player.hitPoints -= 1
            if player.hitPoints <= 0 { return debugReturn( message: "player looses from difficulty" ) }
        }
        applyEffects()
        if boss.hitPoints <= 0 {
            return debugReturn( message: "boss killed before spell", passThru: currentCost ) }

        return shop.spells.compactMap { spell -> Int? in
            if currentCost + spell.cost >= minCost {
                return debugReturn( message: "\(spell) already exceeds \(minCost)" ) }
            if spell.cost >= player.mana { return debugReturn( message: "player can't afford \(spell)" ) }
            if effects[spell.name] != nil {
                return debugReturn( message: "can't cast \(spell), already in effect" ) }
            let game = Game( other: self, turn: turn )
            let result = game.checkSpell( spell: spell )
            if let cost = result { minCost = min( minCost, cost ) }
            return result
        }.min()
    }
    
    func checkSpell( spell: Spell ) -> Int? {
        spell.cast( game: self )
        debugPrint( message: "player cast \(spell)" )
        if boss.hitPoints <= 0 {
            return debugReturn( message: "boss killed by \(spell)", passThru: currentCost) }
        applyEffects()
        if boss.hitPoints <= 0 {
            return debugReturn( message: "boss killed by effects", passThru: currentCost) }
        player.hitPoints -= max( boss.damage - player.armor, 1 )
        if player.hitPoints <= 0 { return debugReturn( message: "boss kills player" ) }
        
        let game = Game( other: self, turn: turn + 2 )
        guard let recursed = game.lowestCost() else {
            return debugReturn( message: "\(spell) lead to death" ) }
        return debugReturn( message: "\(spell) lead to victory", passThru: recursed )
    }
}


func parse( input: AOCinput ) -> Player {
    return try! Player( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    let boss = parse( input: input )
    let game = Game( boss: boss, difficulty: .easy, debug: false )
    
    guard let cost = game.lowestCost() else { return "Failure" }
    return "\(cost)"
}


func part2( input: AOCinput ) -> String {
    let boss = parse( input: input )
    let game = Game( boss: boss, difficulty: .hard, debug: false )
    
    guard let cost = game.lowestCost() else { return "Failure" }
    return "\(cost)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
