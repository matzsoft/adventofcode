//
//         FILE: main.swift
//  DESCRIPTION: day24 - Immune System Simulator 20XX
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/31/21 12:04:34
//

import Foundation
import Library

class Group {
    enum AttackType: String { case fire, cold, slashing, radiation, bludgeoning }

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
    
    init( line: String, groupNumber: Int ) throws {
        let sections = line.split( whereSeparator: { "()".contains( $0 ) } )
        
        self.groupNumber = groupNumber
        target = nil
        isTargetted = false
        switch sections.count {
        case 1:
            ( unitCount, hitPoints ) = Group.parseFirstSection( section: line )
            weaknesses = []
            immunities = []
            ( attackDamage, attackType, initiative ) = Group.parseThirdSection( section: line, offset: 7 )
        case 3:
            ( unitCount, hitPoints ) = Group.parseFirstSection( section: String( sections[0] ) )
            ( weaknesses, immunities ) = try Group.parseSecondSection( section: sections[1] )
            ( attackDamage, attackType, initiative )
                = Group.parseThirdSection( section: String( sections[2] ), offset: 0 )
        default:
            throw RuntimeError( "Parse error - parenthetical nesting problem: \(line)" )
        }
    }
    
    static func parseFirstSection( section: String ) -> ( Int, Int ) {
        let words = section.split( separator: " " )
        
        return ( Int( words[0] )!, Int( words[4] )! )
    }
    
    static func parseSecondSection( section: Substring ) throws -> ( Set<AttackType>, Set<AttackType> ) {
        var weaknesses: Set<AttackType> = []
        var immunities: Set<AttackType> = []
        let types = section.split( separator: ";" )

        for type in types {
            let words = type.split( whereSeparator: { ", ".contains( $0 ) } )
            
            for word in words[2...] {
                switch words[0] {
                case "weak":
                    weaknesses.insert( AttackType( rawValue: String( word ) )! )
                case "immune":
                    immunities.insert( AttackType( rawValue: String( word ) )! )
                default:
                    throw RuntimeError( "Invalid type: \(words[0])" )
                }
            }
        }
        
        return ( weaknesses, immunities )
    }
    
    static func parseThirdSection( section: String, offset: Int ) -> ( Int, AttackType, Int ) {
        let words = section.split( separator: " " )
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
            ( $0, $0.calculateDamage( attacker: self ) )
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
            target.defend( against: self )
        }
    }
    
    func calculateDamage( attacker: Group ) -> Int {
        if immunities.contains( attacker.attackType ) {
            return 0
        }
        if weaknesses.contains( attacker.attackType ) {
            return 2 * attacker.effectivePower
        }
        return attacker.effectivePower
    }
    
    func defend( against attacker: Group ) -> Void {
        let damage = calculateDamage( attacker: attacker )
        let unitsDestroyed = damage / hitPoints
        
        if unitsDestroyed < unitCount {
            unitCount -= unitsDestroyed
        } else {
            unitCount = 0
            army?.reportDemise( group: self )
        }
    }
}

class Army {
    var name: String
    var groups: [Group]
    weak var enemy: Army?
    var debug = false
    
    init( lines: [String] ) throws {
        let words = lines[0].components( separatedBy: ":" )
        
        name = words[0]
        groups = try lines[1...].enumerated().map { try Group( line: $0.element, groupNumber: $0.offset ) }
        groups.forEach { $0.army = self }
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
    
    func boost( by amount: Int ) -> Void {
        groups.forEach { $0.attackDamage += amount }
    }
}


func battle( armies: [Army] ) throws -> Army? {
    guard armies.count == 2 else { throw RuntimeError( "Army count is wrong" ) }
    
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


func parse( input: AOCinput ) -> [Army] {
    let armies = input.paragraphs.map { try! Army( lines: $0 ) }
    
    armies[0].enemy = armies[1]
    armies[1].enemy = armies[0]
    return armies
}


func part1( input: AOCinput ) -> String {
    let armies = parse( input: input )
    
    if let victor = try! battle( armies: armies ) {
        print( "Part1: victory by \(victor.name)." )
        return "\(victor.groups.reduce( 0, { $0 + $1.unitCount } ))"
    }

    return "Failure"
}


func part2( input: AOCinput ) -> String {
    for current in 1 ... 50 {
        let armies = parse( input: input )
        
        armies[0].boost( by: current )
        if let victor = try! battle( armies: armies ) {
            if victor.name == "Immune System" {
                print( "Victory by \(victor.name) at boost level \(current)." )
                return "\(victor.groups.reduce( 0, { $0 + $1.unitCount } ))"
            }
        }
    }
    
    return "Failure"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
