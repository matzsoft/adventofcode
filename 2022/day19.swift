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

enum ResourceType: String { case ore, clay, obsidian, geode }

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
    let timeLimit: Int
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
    
    init( line: String, timeLimit: Int ) {
        let sentences = line.split( whereSeparator:  { ":.".contains( $0 ) } )
        id = Int( sentences[0].split( separator: " " )[1] )!
        self.timeLimit = timeLimit
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
    let robots: [ ResourceType : Int ]
    let resources: [ ResourceType : Int ]
    var prev: Status?

    var description: String {
        let timeString = "== Minute \(clock) =="
        let robotsStrings = robots.filter { $0.value > 0 }.map { "\($0.value) \($0.key) robot" }
        let resourcesStrings = resources.filter { $0.value > 0 }.map { "\($0.value) \($0.key)" }
            
        return ( [ timeString ] + robotsStrings + resourcesStrings ).joined( separator: "\n" )
    }
    
    init() {
        clock = 0
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
        clock: Int, robots: [ ResourceType : Int ], resources: [ ResourceType : Int ], prev: Status? = nil
    ) {
        self.clock = clock
        self.robots = robots
        self.resources = resources
        self.prev = prev
    }
    
    static func == (lhs: Status, rhs: Status) -> Bool {
        guard lhs.clock == rhs.clock else { return false }
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
        return Status( clock: clock + time, robots: robots, resources: newResources, prev: self )
    }
    
    func build( blueprint: Blueprint, type: ResourceType ) -> Status {
        var newRobots = robots
        let newResources = resources.reduce( into: resources ) { newResources, resource in
            newResources[resource.key] = resource.value - ( blueprint[type].costs[resource.key] ?? 0 )
        }

        newRobots[ type, default: 0 ] += 1
        return Status( clock: clock, robots: newRobots, resources: newResources, prev: prev )
    }
    
    func nextBuilds( blueprint: Blueprint ) -> [Status] {
        let times = robots.reduce( into: [ ResourceType : Int ]() ) { times, robot in
            guard robot.value < blueprint.maximums[robot.key]! else { return }
            let time = blueprint[robot.key].costs.map { resource in
                let needed = resource.value - resources[resource.key]!
                guard needed > 0 else { return 0 }
                guard robots[resource.key]! > 0 else { return blueprint.timeLimit }
                return ( needed + robots[resource.key]! - 1 ) / robots[resource.key]!
            }.max()!
            if clock + time < blueprint.timeLimit { times[robot.key] = time }
        }
        return times.map {
            return advanced( by: $0.value + 1 ).build( blueprint: blueprint, type: $0.key )
        }.sorted()
    }
    
    func potential( blueprint: Blueprint ) -> Int {
        let remaining = blueprint.timeLimit - clock
        return resources[.geode]! + robots[.geode]! * remaining + remaining * ( remaining - 1 ) / 2
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


func nextGeodeRobots( blueprint: Blueprint, start: [Status] ) -> [Status] {
    var firstGeodeTime = blueprint.timeLimit
    var queue = start
    var candidates = [Status]()
    
    while !queue.isEmpty {
        let next = queue.removeFirst()
        let builds = next.nextBuilds( blueprint: blueprint ).filter {
            if $0.clock > firstGeodeTime { return false }
            guard $0.robots[.geode]! > next.robots[.geode]! else { return true }
            
            if $0.clock == firstGeodeTime {
                candidates.append( $0 )
            } else {
                firstGeodeTime = $0.clock
                candidates = [ $0 ]
            }
            return false
        }
        
        if !builds.isEmpty {
            queue = builds + queue
        }
    }
    
    return candidates.sorted()
}


func part1( input: AOCinput ) -> String {
    let blueprints = input.lines.map { Blueprint( line: $0, timeLimit: 24 ) }
    
    //print( blueprints.map { $0.description }.joined( separator: "\n" ) )

    let qualities = blueprints.map { blueprint in
        var candidates = [ Status() ]
        
        while !candidates.isEmpty {
            let newCandidates = nextGeodeRobots( blueprint: blueprint, start: candidates )
            
            if newCandidates.isEmpty {
                let advanced = candidates[0].advanced( by: blueprint.timeLimit - candidates[0].clock )
                return blueprint.id * advanced.resources[.geode]!
            }
            
            candidates = newCandidates
        }
        
        fatalError( "No solution for blueprint \(blueprint.id)" )
    }
    
    return "\( qualities.reduce( 0, + ) )"
}


func part2( input: AOCinput ) -> String {
    let allBlueprints = input.lines.map { Blueprint( line: $0, timeLimit: 32 ) }
    let blueprints = allBlueprints.count < 3 ? allBlueprints : Array( allBlueprints[..<3] )

    let geodes = blueprints.map { blueprint in
        var queue = [ Status() ]
        var maxGeodes = 0
        
        while !queue.isEmpty {
            let next = queue.removeFirst()
            if next.potential( blueprint: blueprint ) < maxGeodes { continue }
            let builds = next.nextBuilds( blueprint: blueprint )
            
            if !builds.isEmpty {
                queue = builds + queue
            } else {
                let advanced = next.advanced( by: blueprint.timeLimit - next.clock )
                maxGeodes = max( maxGeodes, advanced.resources[.geode]! )
            }
        }
        
        return maxGeodes
    }
    
    return "\( geodes.reduce( 1, * ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
