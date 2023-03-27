//
//         FILE: main.swift
//  DESCRIPTION: day19 - Not Enough Minerals
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/18/22 22:52:16
//

import Foundation

let timeLimit = 24

enum ResourceType: String { case ore, clay, obsidian, geode }

class SinglyLinkedList<T: Comparable> {
    class Node {
        let value: T
        var pointer: Node?

        internal init( value: T, pointer: SinglyLinkedList<T>.Node? = nil ) {
            self.value = value
            self.pointer = pointer
        }
    }
    
    var head: Node?
    var count = 0
    
    var isEmpty: Bool { head == nil }
    var first: T? { head?.value }
    var removeFirst: T {
        let retval = head!.value
        head = head?.pointer
        count -= 1
        return retval
    }
    
    init( value: T ) {
        head = Node( value: value )
        count = 1
    }
    
    func merge( elements: [T] ) -> Void {
        if elements.isEmpty { return }
        if isEmpty {
            elements.reversed().forEach { head = Node( value: $0, pointer: head ) }
        } else if elements[0] < head!.value {
            head = Node( value: elements[0], pointer: head )
            merge( elements: Array( elements[1...] ) )
        } else {
            var prev = head
            elements.forEach { element in
                while let next = prev?.pointer {
                    if element < next.value {
                        prev!.pointer = Node( value: element, pointer: next )
                        return
                    }
                    prev = next
                }
                prev!.pointer = Node( value: element, pointer: nil )
                prev = prev!.pointer
            }
        }
        count += elements.count
    }
}


struct Robot: CustomStringConvertible {
    let resource: ResourceType
    let costs: [ ResourceType: Int ]
    
    var description: String {
        let costs = self.costs.map { "\($0.value) \($0.key)" }.joined( separator: " and " )
        return "  Each \(resource) robot costs \(costs)."
    }
    
    init( line: String ) {
        let words = line.split( separator: " " ).map { String( $0 ) }
        resource = ResourceType( rawValue: words[1] )!
        if words.count < 7 {
            costs = [ ResourceType( rawValue: words[5] )! : Int( words[4] )! ]
        } else {
            costs = [
                ResourceType( rawValue: words[5] )! : Int( words[4] )!,
                ResourceType( rawValue: words[8] )! : Int( words[7] )!
            ]
        }
    }
}


struct Blueprint: CustomStringConvertible {
    let id: Int
    let robots: [ ResourceType : Robot ]
    let maximums: [ ResourceType : Int ]
    
    subscript( resource: ResourceType ) -> Robot {
        robots[resource]!
    }
    
    var description: String {
        let lines = [ "Blueprint \(id):" ] +
        robots.values.map { $0.description } +
        [ "  Maximums: " + maximums.map { "\($0.key) = \($0.value)"}.joined( separator: ", " ) ]
        return lines.joined( separator: "\n" )
    }
    
    init( line: String ) {
        let sentences = line.split( whereSeparator:  { ":.".contains( $0 ) } )
        id = Int( sentences[0].split( separator: " " )[1] )!
        robots = sentences[1...].reduce( into: [ ResourceType : Robot ]() ) { robots, sentence in
            let robot = Robot( line: String( sentence ) )
            robots[robot.resource] = robot
        }
        maximums = robots.reduce( into: [ ResourceType.geode : timeLimit ] ) { maximums, robot in
            robot.value.costs.forEach {
                if robot.key != $0.key {
                    maximums[$0.key] = max( $0.value, maximums[$0.key] ?? 0 )
                }
            }
        }
    }
}


class Status: Comparable, CustomStringConvertible {
    let clock: Int
    let firstGeode: Bool
    let robots: [ ResourceType : Int ]
    let resources: [ ResourceType : Int ]
    var prev: Status?

    var description: String {
        let timeString = "== Minute \(clock - 1) =="
        let robotsStrings = robots.filter { $0.value > 0 }.map { "\($0.value) \($0.key) robot" }
        let resourcesStrings = resources.filter { $0.value > 0 }.map { "\($0.value) \($0.key)" }
            
        return ( [ timeString ] + robotsStrings + resourcesStrings ).joined( separator: "\n" )
    }
    
    init() {
        clock = 1
        firstGeode = false
        robots = [
            ResourceType.ore : 1, ResourceType.clay : 0,
            ResourceType.obsidian : 0, ResourceType.geode : 0
        ]
        resources = [
            ResourceType.ore : 0, ResourceType.clay : 0,
            ResourceType.obsidian : 0, ResourceType.geode : 0
        ]
    }
    
    init(
        clock: Int, robots: [ ResourceType : Int ],
        resources: [ ResourceType : Int ], firstGeode: Bool = false, prev: Status? = nil
    ) {
        self.clock = clock
        self.firstGeode = firstGeode
        self.robots = robots
        self.resources = resources
        self.prev = prev
    }
    
    static func == (lhs: Status, rhs: Status) -> Bool {
        guard lhs.clock == rhs.clock else { return false }
        guard lhs.firstGeode == rhs.firstGeode else { return false }
        guard lhs.robots == rhs.robots else { return false }
        guard lhs.resources == rhs.resources else { return false }
        
        return true
    }
    
    static func < ( lhs: Status, rhs: Status ) -> Bool {
        if lhs.clock < rhs.clock { return true }
        return lhs.clock == rhs.clock && lhs.resources[.geode]! > rhs.resources[.geode]!
    }
    
    func advanced( by time: Int ) -> Status {
        let newResources = resources.reduce( into: resources ) { newResources, resource in
            newResources[resource.key] = resource.value + robots[resource.key]! * time
        }
        return Status(
            clock: clock + time, robots: robots, resources: newResources,
            firstGeode: firstGeode, prev: self
        )
    }
    
    func build( blueprint: Blueprint, type: ResourceType ) -> Status {
        var newRobots = robots
        let newResources = resources.reduce( into: resources ) { newResources, resource in
            newResources[resource.key] = resource.value - ( blueprint[type].costs[resource.key] ?? 0 )
        }

        newRobots[ type, default: 0 ] += 1
        return Status(
            clock: clock, robots: newRobots, resources: newResources,
            firstGeode: type == .geode && robots[.geode] == 0, prev: prev
        )
    }
    
    func nextBuilds( blueprint: Blueprint ) -> [Status] {
        let times = robots.reduce( into: [ ResourceType : Int ]() ) { times, robot in
            guard robot.value < blueprint.maximums[robot.key]! else { return }
            let time = blueprint[robot.key].costs.map { resource in
                let needed = resource.value - resources[resource.key]!
                guard needed > 0 else { return 0 }
                guard robots[resource.key]! > 0 else { return timeLimit }
                return ( needed + robots[resource.key]! - 1 ) / robots[resource.key]!
            }.max()!
            if clock + time < timeLimit { times[robot.key] = time }
        }
        return times.map {
            return advanced( by: $0.value + 1 ).build( blueprint: blueprint, type: $0.key )
        }.sorted()
    }
    
    var chain: [Status] {
        var array = [ self ]
        var current = self
        
        while let prev = current.prev {
            array.insert( prev, at: 0 )
            current = prev
        }
        
        return array
    }
    
    var chainString: String {
        chain.map { $0.description }.joined( separator: "\n\n" )
    }
}


func parse( input: AOCinput ) -> [Blueprint] {
    return input.lines.map { Blueprint( line: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let blueprints = parse( input: input )
    
    //print( blueprints.map { $0.description }.joined( separator: "\n" ) )

    let qualities = blueprints.map { blueprint in
        var maxGeodes = 0
        var firstGeodeTime = timeLimit
        let queue = SinglyLinkedList( value: Status() )
        
        while !queue.isEmpty {
            let next = queue.removeFirst
            let builds = next.nextBuilds( blueprint: blueprint ).filter {
                if $0.clock > firstGeodeTime && $0.robots[.geode]! == 0 { return false }
                guard $0.firstGeode else { return true }
                guard $0.clock <= firstGeodeTime else { return false }
                firstGeodeTime = $0.clock
                return true
            }
            
            if !builds.isEmpty {
                queue.merge( elements: builds )
            } else {
                let advanced = next.advanced( by: timeLimit - next.clock + 1 )                
                maxGeodes = max( maxGeodes, advanced.resources[.geode]! )
            }
        }
        return blueprint.id * maxGeodes
    }
    
    return "\( qualities.reduce( 0, + ) )"
}


func part2( input: AOCinput ) -> String {
    let something = parse( input: input )
    return ""
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
