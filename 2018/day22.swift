//
//         FILE: main.swift
//  DESCRIPTION: day22 - Mode Maze
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/29/21 12:52:09
//

import Foundation

let rowGeologicFactor = 16807
let colGeologicFactor = 48271
let erosionModulus    = 20183

enum Equipment: Int, CaseIterable { case none, torch, gear }
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


class Region {
    var type: RiskLevel
    var geologicIndex: Int
    var erosionLevel: Int
    var times = Array( repeating: Int.max, count: Equipment.allCases.count )
    
    init( depth: Int, geologicIndex: Int ) {
        self.geologicIndex = geologicIndex
        erosionLevel = ( geologicIndex + depth ) % erosionModulus
        type = RiskLevel( rawValue: erosionLevel % RiskLevel.allCases.count )!
    }
    
    func timeIsSet( rescuer: Rescuer ) -> Bool {
        return times[ rescuer.equipment.rawValue ] < Int.max
    }
    
    func setTime( rescuer: Rescuer ) -> Void {
        times[ rescuer.equipment.rawValue ] = rescuer.clock
    }
    
    func formatTimes( first: Int, second: Int ) -> String {
        return ( first < Int.max ? String( format: "%2d,", first ) : "XX," )
            + ( second < Int.max ? String( format: "%2d", second ) : "XX" )
    }
    
    func detailValue() -> String {
        switch type {
        case .rocky:
            return formatTimes(
                first: times[ Equipment.torch.rawValue ],
                second: times[ Equipment.gear.rawValue ]
            )
        case .wet:
            return formatTimes(
                first: times[ Equipment.gear.rawValue ],
                second: times[ Equipment.none.rawValue ]
            )
        case .narrow:
            return formatTimes(
                first: times[ Equipment.torch.rawValue ],
                second: times[ Equipment.none.rawValue ]
            )
        }
    }
}


class Cave {
    let depth: Int
    let target: Point2D
    let limit: Point2D
    var map: [[Region]]
    
    var riskLevel: Int {
        return ( 0 ... target.y ).reduce( 0, { ( result: Int, rowIndex: Int ) -> Int in
            result + ( 0 ... target.x ).reduce( 0, { $0 + map[rowIndex][$1].type.rawValue } )
        } )
    }
    
    init( lines: [String] ) {
        let words = lines.flatMap { $0.split(whereSeparator: { ": ,".contains( $0 ) } ) }
        
        depth = Int( words[1] )!
        target = Point2D( x: Int( words[3] )!, y: Int( words[4] )! )

        let extend = max( target.x, target.y ) / 5
        
        limit = target + Point2D( x: extend, y: extend )
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
    
    subscript( postition: Point2D ) -> Region? {
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
    
    func atTargetNow( events: Events, rescuer: Rescuer ) -> Bool {
        if rescuer.position == target {
            if rescuer.equipment == .torch {
                return true
            } else {
                let next = Rescuer( cave: rescuer.cave )
                
                next.replace( with: rescuer )
                next.change( to: .torch )
                events.add( new: next )
            }
        }
        
        return false

    }
    
    func traverse() -> Int {
        let events = Events()
        let rescuer = Rescuer( cave: self )
        let right = rescuer.move( direction: DirectionUDLR.right )!
        let down = rescuer.move( direction: DirectionUDLR.down )!
        
        self[ rescuer.position ]?.setTime( rescuer: rescuer )
        events.add( new: right )
        events.add( new: down )
        //printDetail( time: rescuer.clock )
        
        while let queue = events.getNextQueue() {
            //printDetail( time: queue[0].clock )
            for next in queue {
                if !( self[ next.position ]?.timeIsSet( rescuer: next ) )! {
                    self[ next.position ]?.setTime( rescuer: next )
                    
                    if atTargetNow( events: events, rescuer: next ) {
                        return next.clock
                    }
                    if let up = next.move( direction: DirectionUDLR.up ) {
                        events.add(new: up)
                    }
                    if let right = next.move( direction: DirectionUDLR.right ) {
                        events.add(new: right)
                    }
                    if let down = next.move( direction: DirectionUDLR.down ) {
                        events.add(new: down)
                    }
                    if let left = next.move( direction: DirectionUDLR.left ) {
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
    var position = Point2D( x: 0, y: 0 )
    let cave: Cave
    
    init( cave: Cave ) {
        self.cave = cave
    }
    
    init?( before: Rescuer, direction: DirectionUDLR ) {
        self.clock = before.clock + 1
        self.equipment = before.equipment
        self.position = before.position.move( direction: direction)
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
    
    func move( direction: DirectionUDLR ) -> Rescuer? {
        if let after = Rescuer(before: self, direction: direction) {
            if let current = cave[position] {
                if let next = cave[after.position] {
                    switch current.type {
                    case .rocky:
                        switch next.type {
                        case .rocky:
                            break
                        case .wet:
                            after.change( to: .gear )
                        case .narrow:
                            after.change( to: .torch )
                        }
                    case .wet:
                        switch next.type {
                        case .rocky:
                            after.change( to: .gear )
                        case .wet:
                            break
                        case .narrow:
                            after.change( to: .none )
                        }
                    case .narrow:
                        switch next.type {
                        case .rocky:
                            after.change( to: .torch )
                        case .wet:
                            after.change( to: .none )
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
    var events: [ Int : [Rescuer] ] = [:]
    
    func add( new: Rescuer ) -> Void {
        if events[new.clock] == nil {
            events[new.clock] = [new]
        } else {
            events[new.clock]?.append(new)
        }
    }
    
    func getNextQueue() -> [Rescuer]? {
        if let ( time, queue ) = events.min( by: { $0.key < $1.key } ) {
            events.removeValue( forKey: time )
            return queue
        }
        
        return nil
    }
}


func part1( input: AOCinput ) -> String {
    let cave = Cave( lines: input.lines )
    return "\(cave.riskLevel)"
}


func part2( input: AOCinput ) -> String {
    let cave = Cave( lines: input.lines )
    return "\(cave.traverse())"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
