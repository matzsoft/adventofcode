//
//  main.swift
//  day24
//
//  Created by Mark Johnson on 12/29/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

let test1Input = """
Immune System:
17 units each with 5390 hit points (weak to radiation, bludgeoning) with an attack that does 4507 fire damage at initiative 2
989 units each with 1274 hit points (immune to fire; weak to bludgeoning, slashing) with an attack that does 25 slashing damage at initiative 3

Infection:
801 units each with 4706 hit points (weak to radiation) with an attack that does 116 bludgeoning damage at initiative 1
4485 units each with 2961 hit points (immune to radiation; weak to fire, cold) with an attack that does 12 slashing damage at initiative 4
"""
let input = """
Immune System:
5711 units each with 6662 hit points (immune to fire; weak to slashing) with an attack that does 9 bludgeoning damage at initiative 14
2108 units each with 8185 hit points (weak to radiation, bludgeoning) with an attack that does 36 slashing damage at initiative 13
1590 units each with 3940 hit points with an attack that does 24 cold damage at initiative 5
2546 units each with 6960 hit points with an attack that does 25 slashing damage at initiative 2
1084 units each with 3450 hit points (immune to bludgeoning) with an attack that does 27 slashing damage at initiative 11
265 units each with 8223 hit points (immune to radiation, bludgeoning, cold) with an attack that does 259 cold damage at initiative 12
6792 units each with 6242 hit points (immune to slashing; weak to bludgeoning, radiation) with an attack that does 9 slashing damage at initiative 18
3336 units each with 12681 hit points (weak to slashing) with an attack that does 28 fire damage at initiative 6
752 units each with 5272 hit points (immune to slashing; weak to bludgeoning, radiation) with an attack that does 69 radiation damage at initiative 4
96 units each with 7266 hit points (immune to fire) with an attack that does 738 bludgeoning damage at initiative 8

Infection:
1492 units each with 47899 hit points (weak to fire, slashing; immune to cold) with an attack that does 56 bludgeoning damage at initiative 15
3065 units each with 39751 hit points (weak to bludgeoning, slashing) with an attack that does 20 slashing damage at initiative 1
7971 units each with 35542 hit points (weak to bludgeoning, radiation) with an attack that does 8 bludgeoning damage at initiative 10
585 units each with 5936 hit points (weak to cold; immune to fire) with an attack that does 17 slashing damage at initiative 17
2449 units each with 37159 hit points (immune to cold) with an attack that does 22 cold damage at initiative 7
8897 units each with 6420 hit points (immune to bludgeoning, slashing, fire; weak to radiation) with an attack that does 1 bludgeoning damage at initiative 19
329 units each with 31704 hit points (weak to fire; immune to cold, radiation) with an attack that does 179 bludgeoning damage at initiative 16
6961 units each with 11069 hit points (weak to fire) with an attack that does 2 radiation damage at initiative 20
2837 units each with 29483 hit points (weak to cold) with an attack that does 20 bludgeoning damage at initiative 9
8714 units each with 7890 hit points with an attack that does 1 cold damage at initiative 3
"""

enum AttackType: String {
    case fire, cold, slashing, radiation, bludgeoning
}

class Group {
    let groupNumber: Int
    var unitCount: Int
    let hitPoints: Int
    var attackDamage: Int
    let attackType: AttackType
    let initiative: Int
    let weaknesses: Set<AttackType>
    let immunities: Set<AttackType>
    var target: Group?
    var isTargetted: Bool
    weak var army: Army?
    
    var effectivePower: Int {
        return unitCount * attackDamage
    }
    
    init( line: Substring, army: Army, groupNumber: Int ) {
        let sections = line.split(whereSeparator: { "()".contains($0) } )
        
        self.groupNumber = groupNumber
        self.army = army
        target = nil
        isTargetted = false
        switch sections.count {
        case 1:
            ( unitCount, hitPoints ) = Group.parseFirstSection(section: line)
            weaknesses = []
            immunities = []
            ( attackDamage, attackType, initiative ) = Group.parseThirdSection(section: line, offset: 7)
        case 3:
            ( unitCount, hitPoints ) = Group.parseFirstSection(section: sections[0])
            ( weaknesses, immunities ) = Group.parseSecondSection(section: sections[1])
            ( attackDamage, attackType, initiative ) = Group.parseThirdSection(section: sections[2], offset: 0)
        default:
            print( "Parse error - parenthetical nesting problem:", line )
            exit(1)
        }
    }
    
    static func parseFirstSection( section: Substring ) -> ( Int, Int ) {
        let words = section.split(separator: " ")
        
        return ( Int( words[0] )!, Int( words[4] )! )
    }
    
    static func parseSecondSection( section: Substring ) -> ( Set<AttackType>, Set<AttackType> ) {
        var weaknesses: Set<AttackType> = []
        var immunities: Set<AttackType> = []
        let types = section.split(separator: ";")

        for type in types {
            let words = type.split(whereSeparator: { ", ".contains($0) } )
            
            for word in words[2...] {
                switch words[0] {
                case "weak":
                    weaknesses.insert( AttackType(rawValue: String(word))! )
                case "immune":
                    immunities.insert( AttackType(rawValue: String(word))! )
                default:
                    print( "Invalid type:", words[0] )
                    exit(1)
                }
            }
        }
        
        return ( weaknesses, immunities )
    }
    
    static func parseThirdSection( section: Substring, offset: Int ) -> ( Int, AttackType, Int ) {
        let words = section.split(separator: " ")
        let attackDamage = Int( words[ offset + 5 ] )!
        let attackType = AttackType( rawValue: String( words[ offset + 6 ] ) )!
        let initiative = Int( words[offset + 10] )!
        
        return ( attackDamage, attackType, initiative )
    }
    
    func prepareForTargetting() -> Void {
        target = nil
        isTargetted = false
    }
    
    func findTarget() -> Void {
        let potentials = army!.enemy!.groups.filter { $0.isTargetted == false }.map {
            ( $0, $0.calculateDamage(attacker: self) )
        }
        
        if army!.debug {
            for group in potentials {
                print( "\(army!.name) group \(groupNumber) would deal defending group \(group.0.groupNumber) \(group.1) damage" )
            }
        }
        
        let preferences = potentials.sorted {
            if $0.1 > $1.1 { return true }
            if $0.1 < $1.1 { return false }
            if $0.0.effectivePower > $1.0.effectivePower { return true }
            if $0.0.effectivePower < $1.0.effectivePower { return false }
            return $0.0.initiative > $1.0.initiative
        }
        
        if let target = preferences.first {
            if target.1 > 0 {
                self.target = target.0
                target.0.isTargetted = true
            }
        }
    }
    
    func attackTarget() -> Void {
        guard unitCount > 0 else { return }
        
        if let target = target {
            target.defend(against: self)
        }
    }
    
    func calculateDamage( attacker: Group ) -> Int {
        if immunities.contains(attacker.attackType) {
            return 0
        }
        if weaknesses.contains(attacker.attackType) {
            return 2 * attacker.effectivePower
        }
        return attacker.effectivePower
    }
    
    func defend( against attacker: Group ) -> Void {
        let damage = calculateDamage(attacker: attacker)
        let unitsDestroyed = damage / hitPoints
        
        if unitsDestroyed < unitCount {
            unitCount -= unitsDestroyed
        } else {
            unitCount = 0
            army?.reportDemise(group: self)
        }
    }
}

class Army {
    var name: String
    var groups: [Group]
    weak var enemy: Army?
    var debug: Bool
    
    init( name: String ) {
        self.name = name
        groups = []
        enemy = nil
        debug = false
    }
    
    func equip( line: Substring ) -> Void {
        groups.append( Group( line: line, army: self, groupNumber: groups.count + 1 ) )
    }
    
    func reportDemise( group: Group ) -> Void {
        groups.removeAll( where: { $0.groupNumber == group.groupNumber } )
    }
    
    func printStatus() -> Void {
        if debug {
            print( "\(name):" )
            groups.forEach { print( "Group \($0.groupNumber) contains \($0.unitCount) units" ) }
        }
    }
    
    func boost(by amount: Int) -> Void {
        groups.forEach { $0.attackDamage += amount }
    }
}

func parse( input: String ) -> [Army] {
    var armies: [Army] = []
    let lines = input.split(separator: "\n")
    
    for line in lines {
        switch line {
        case "Immune System:":
            armies.append( Army(name: "Immune System") )
        case "Infection:":
            armies.append( Army(name: "Infection") )
        default:
            armies.last!.equip(line: line)
        }
    }
    
    armies[0].enemy = armies[1]
    armies[1].enemy = armies[0]
    return armies
}

func battle( armies: [Army] ) -> Army? {
    guard armies.count == 2 else {
        print( "Army count is wrong" )
        exit(1)
    }
    
    while armies.reduce( 1, { $0 * $1.groups.count } ) > 0 {
        let allGroups = armies.flatMap { $0.groups }
        let startStrengths = allGroups.map { $0.unitCount }
        let targetGroups = allGroups.sorted {
            if $0.effectivePower > $1.effectivePower { return true }
            if $0.effectivePower < $1.effectivePower { return false }
            return $0.initiative > $1.initiative
        }
        let attackGroups = allGroups.sorted { $0.initiative > $1.initiative }
 
        armies.forEach { $0.printStatus() }
        if armies[0].debug { print() }
        allGroups.forEach { $0.prepareForTargetting() }
        targetGroups.forEach { $0.findTarget() }
        if armies[0].debug { print() }
        if targetGroups.allSatisfy( { $0.target == nil } ) { break } // Check for stalemate
        attackGroups.forEach { $0.attackTarget() }
        
        let endStrengths = allGroups.map { $0.unitCount }
        
        if startStrengths == endStrengths { break } // Another stalemate check
    }
    
    let victors = armies.filter { $0.groups.count > 0 }
    
    if victors.count != 1 {
        return nil
    }
    
    return victors.last
}


let armies = parse(input: input)

//armies.forEach { $0.debug = true }
if let victor = battle(armies: armies) {
    print( "Part1: victory by \(victor.name) with \(victor.groups.reduce( 0, { $0 + $1.unitCount })) units." )
}

for current in 1 ... 50 {
    let armies = parse(input: input)
    
    armies[0].boost(by: current)
    if let victor = battle(armies: armies) {
        if victor.name == "Immune System" {
            print( "Success at boost level", current )
            print( "Victory by \(victor.name) with \(victor.groups.reduce( 0, { $0 + $1.unitCount })) units." )
            exit(0)
        }
    }
}

print( "WTF: I know that 50 is a win for Immune System" )
