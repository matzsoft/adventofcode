//
//  main.swift
//  day22
//
//  Created by Mark Johnson on 12/25/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

let input = """
depth: 10647
target: 7,770
"""

struct Position: Hashable {
    var x: Int
    var y: Int
    
    static func ==( left: Position, right: Position ) -> Bool {
        return left.x == right.x && left.y == right.y
    }
    
    static func +( left: Position, right: Position ) -> Position {
        return Position(x: left.x + right.x, y: left.y + right.y)
    }
    
    func move( direction: Direction ) -> Position {
        switch direction {
        case .up:
            return self + Position(x: 0, y: -1)
        case .right:
            return self + Position(x: 1, y: 0)
        case .down:
            return self + Position(x: 0, y: 1)
        case .left:
            return self + Position(x: -1, y: 0)
        }
    }
}

enum Direction: Int, CaseIterable {
    case up, right, down, left
}

let test1Depth = 510
let test1Target = Position( x: 10, y: 10 )
let inputDepth = 10647
let inputTarget = Position(x: 7, y: 770)
let rowGeologicFactor = 16807
let colGeologicFactor = 48271
let erosionModulus = 20183

enum RiskLevel: Int, CaseIterable {
    case rocky, wet, narrow
    
    var stringValue: String {
        switch self {
        case .rocky:
            return "."
        case .wet:
            return "="
        case .narrow:
            return "|"
        }
    }
}

enum Equipment: Int, CaseIterable {
    case none, torch, gear
}

class Region {
    var type: RiskLevel
    var geologicIndex: Int
    var erosionLevel: Int
    var times = Array( repeating: Int.max, count: Equipment.allCases.count )
    
    init( depth: Int, geologicIndex: Int ) {
        self.geologicIndex = geologicIndex
        erosionLevel = ( geologicIndex + depth ) % erosionModulus
        type = RiskLevel(rawValue: erosionLevel % RiskLevel.allCases.count )!
    }
    
    func timeIsSet( rescuer: Rescuer ) -> Bool {
        return times[ rescuer.equipment.rawValue ] < Int.max
    }
    
    func setTime( rescuer: Rescuer ) -> Void {
        times[ rescuer.equipment.rawValue ] = rescuer.clock
    }
    
    func formatTimes( first: Int, second: Int ) -> String {
        var result = ""
        
        if first < Int.max {
            result += String(format: "%2d,", first)
        } else {
            result += "XX,"
        }
        
        if second < Int.max {
            result += String(format: "%2d", second)
        } else {
            result += "XX"
        }
        
        return result
    }
    
    func detailValue() -> String {
        switch type {
        case .rocky:
            return formatTimes(first: times[Equipment.torch.rawValue], second: times[Equipment.gear.rawValue] )
        case .wet:
            return formatTimes(first: times[Equipment.gear.rawValue], second: times[Equipment.none.rawValue] )
        case .narrow:
            return formatTimes(first: times[Equipment.torch.rawValue], second: times[Equipment.none.rawValue] )
        }
    }
}

class Cave {
    let depth: Int
    let target: Position
    let limit: Position
    var map: [[Region]]
    
    init( depth: Int, target: Position ) {
        let extend = max(target.x, target.y) / 5
        
        self.depth = depth
        self.target = target
        self.limit = target + Position(x: extend, y: extend)
        map = []
        
        for y in 0 ... limit.y {
            var row: [Region] = []
            
            for x in 0 ... limit.x {
                if x == 0 {
                    if y == 0 {
                        row.append( Region( depth: depth, geologicIndex: 0 ) )
                    } else {
                        row.append( Region( depth: depth, geologicIndex: y * colGeologicFactor ) )
                    }
                } else if y == 0 {
                    row.append( Region( depth: depth, geologicIndex: x * rowGeologicFactor ) )
                } else if x == target.x && y == target.y {
                    row.append( Region( depth: depth, geologicIndex: 0 ) )
                } else {
                    let gIndex = row[x-1].erosionLevel * map[y-1][x].erosionLevel
                    
                    row.append( Region( depth: depth, geologicIndex: gIndex ) )
                }
            }
            map.append(row)
        }
    }
    
    subscript( postition: Position ) -> Region? {
        guard 0 <= postition.x && postition.x <= limit.x else { return nil }
        guard 0 <= postition.y && postition.y <= limit.y else { return nil }
        
        return map[postition.y][postition.x]
    }
    
    func printMap() -> Void {
        map.forEach { print( $0.map { $0.type.stringValue }.joined() ) }
        print()
    }
    
    func printDetail( time: Int ) -> Void {
        print( "At time", time )
        map.forEach { print( $0.map { $0.detailValue() }.joined(separator: " ") ) }
        print()
    }
    
    func riskLevel() -> Int {
        return ( 0 ... target.y ).reduce( 0, { ( result: Int, rowIndex: Int ) -> Int in
            result + ( 0 ... target.x ).reduce( 0, { $0 + map[rowIndex][$1].type.rawValue } )
        } )
    }
    
    func atTargetNow( events: Events, rescuer: Rescuer ) -> Bool {
        if rescuer.position == target {
            if rescuer.equipment == .torch {
                return true
            } else {
                let next = Rescuer(cave: rescuer.cave)
                
                next.replace(with: rescuer)
                next.change(to: .torch)
                events.add(new: next)
            }
        }
        
        return false

    }
    
    func traverse() -> Int {
        let events = Events()
        let rescuer = Rescuer(cave: self)
        let right = rescuer.move(direction: .right)!
        let down = rescuer.move(direction: .down)!
        
        self[ rescuer.position ]?.setTime(rescuer: rescuer)
        events.add(new: right)
        events.add(new: down)
        //printDetail(time: rescuer.clock)
        
        while let queue = events.getNextQueue() {
            //printDetail(time: queue[0].clock)
            for next in queue {
                if !(self[ next.position ]?.timeIsSet(rescuer: next))! {
                    self[ next.position ]?.setTime(rescuer: next)
                    
                    if atTargetNow(events: events, rescuer: next) {
                        return next.clock
                    }
                    if let up = next.move(direction: .up) {
                        events.add(new: up)
                    }
                    if let right = next.move(direction: .right) {
                        events.add(new: right)
                    }
                    if let down = next.move(direction: .down) {
                        events.add(new: down)
                    }
                    if let left = next.move(direction: .left) {
                        events.add(new: left)
                    }
                }
            }
        }
        
        return Int.max
    }
}

class Rescuer {
    var clock = 0
    var equipment: Equipment = .torch
    var position = Position(x: 0, y: 0)
    let cave: Cave
    
    init( cave: Cave ) {
        self.cave = cave
    }
    
    init?( before: Rescuer, direction: Direction ) {
        self.clock = before.clock + 1
        self.equipment = before.equipment
        self.position = before.position.move(direction: direction)
        self.cave = before.cave
        
        guard 0 <= position.x && position.x <= cave.limit.x else { return nil }
        guard 0 <= position.y && position.y <= cave.limit.y else { return nil }
    }
    
    func replace( with other: Rescuer ) -> Void {
        self.clock = other.clock
        self.equipment = other.equipment
        self.position = other.position
    }
    
    func change( to newEquipment: Equipment ) -> Void {
        guard equipment != newEquipment else { return }

        equipment = newEquipment
        clock += 7
    }
    
    func move( direction: Direction ) -> Rescuer? {
        if let after = Rescuer(before: self, direction: direction) {
            if let current = cave[position] {
                if let next = cave[after.position] {
                    switch current.type {
                    case .rocky:
                        switch next.type {
                        case .rocky:
                            break
                        case .wet:
                            after.change(to: .gear)
                        case .narrow:
                            after.change(to: .torch)
                        }
                    case .wet:
                        switch next.type {
                        case .rocky:
                            after.change(to: .gear)
                        case .wet:
                            break
                        case .narrow:
                            after.change(to: .none)
                        }
                    case .narrow:
                        switch next.type {
                        case .rocky:
                            after.change(to: .torch)
                        case .wet:
                            after.change(to: .none)
                        case .narrow:
                            break
                        }
                    }
                    return after
                }
            }
        }
        
        return nil
    }
}

class Events {
    var events: [Int:[Rescuer]] = [:]
    
    func add( new: Rescuer ) -> Void {
        if events[new.clock] == nil {
            events[new.clock] = [new]
        } else {
            events[new.clock]?.append(new)
        }
    }
    
    func getNextQueue() -> [Rescuer]? {
        if let ( time, queue ) = events.min(by: { $0.key < $1.key }) {
            events.removeValue(forKey: time)
            return queue
        }
        
        return nil
    }
}


let testCave = Cave(depth: test1Depth, target: test1Target)
let inputCave = Cave(depth: inputDepth, target: inputTarget)

//testCave.printMap()
print( "Test1:", testCave.riskLevel() )
print( "Part1:", inputCave.riskLevel() )

print( "Test2:", testCave.traverse() )
print( "Part2:", inputCave.traverse() )
