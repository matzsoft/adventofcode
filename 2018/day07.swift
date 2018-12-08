//
//  main.swift
//  day07
//
//  Created by Mark Johnson on 12/6/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

let upperCaseA = Character("A").unicodeScalars.first!.value

let input = """
Step Y must be finished before step J can begin.
Step C must be finished before step L can begin.
Step L must be finished before step X can begin.
Step H must be finished before step R can begin.
Step R must be finished before step X can begin.
Step I must be finished before step B can begin.
Step N must be finished before step Q can begin.
Step F must be finished before step X can begin.
Step K must be finished before step G can begin.
Step G must be finished before step P can begin.
Step A must be finished before step S can begin.
Step O must be finished before step D can begin.
Step M must be finished before step W can begin.
Step Q must be finished before step J can begin.
Step X must be finished before step E can begin.
Step U must be finished before step V can begin.
Step Z must be finished before step D can begin.
Step P must be finished before step W can begin.
Step S must be finished before step J can begin.
Step J must be finished before step T can begin.
Step W must be finished before step T can begin.
Step V must be finished before step B can begin.
Step B must be finished before step T can begin.
Step D must be finished before step T can begin.
Step E must be finished before step T can begin.
Step I must be finished before step Z can begin.
Step X must be finished before step D can begin.
Step Q must be finished before step D can begin.
Step S must be finished before step T can begin.
Step R must be finished before step W can begin.
Step O must be finished before step V can begin.
Step C must be finished before step Q can begin.
Step C must be finished before step S can begin.
Step S must be finished before step E can begin.
Step A must be finished before step D can begin.
Step V must be finished before step T can begin.
Step K must be finished before step B can begin.
Step B must be finished before step D can begin.
Step V must be finished before step E can begin.
Step N must be finished before step M can begin.
Step Z must be finished before step T can begin.
Step L must be finished before step A can begin.
Step K must be finished before step Z can begin.
Step F must be finished before step J can begin.
Step M must be finished before step U can begin.
Step Z must be finished before step P can begin.
Step R must be finished before step E can begin.
Step M must be finished before step X can begin.
Step O must be finished before step E can begin.
Step K must be finished before step V can begin.
Step U must be finished before step D can begin.
Step K must be finished before step T can begin.
Step F must be finished before step W can begin.
Step I must be finished before step U can begin.
Step Z must be finished before step S can begin.
Step H must be finished before step D can begin.
Step O must be finished before step P can begin.
Step B must be finished before step E can begin.
Step X must be finished before step U can begin.
Step A must be finished before step J can begin.
Step Y must be finished before step V can begin.
Step U must be finished before step T can begin.
Step G must be finished before step B can begin.
Step U must be finished before step W can begin.
Step H must be finished before step W can begin.
Step G must be finished before step J can begin.
Step X must be finished before step Z can begin.
Step L must be finished before step R can begin.
Step Q must be finished before step X can begin.
Step I must be finished before step O can begin.
Step J must be finished before step E can begin.
Step N must be finished before step D can begin.
Step C must be finished before step B can begin.
Step I must be finished before step W can begin.
Step P must be finished before step J can begin.
Step D must be finished before step E can begin.
Step L must be finished before step J can begin.
Step R must be finished before step J can begin.
Step N must be finished before step A can begin.
Step F must be finished before step O can begin.
Step Y must be finished before step Q can begin.
Step L must be finished before step F can begin.
Step Q must be finished before step U can begin.
Step O must be finished before step T can begin.
Step Z must be finished before step E can begin.
Step Y must be finished before step K can begin.
Step G must be finished before step A can begin.
Step Q must be finished before step E can begin.
Step V must be finished before step D can begin.
Step F must be finished before step K can begin.
Step C must be finished before step E can begin.
Step F must be finished before step A can begin.
Step X must be finished before step B can begin.
Step G must be finished before step U can begin.
Step C must be finished before step H can begin.
Step Y must be finished before step W can begin.
Step R must be finished before step Z can begin.
Step W must be finished before step D can begin.
Step C must be finished before step T can begin.
Step H must be finished before step M can begin.
Step O must be finished before step Q can begin.
"""
let testInput = """
Step C must be finished before step A can begin.
Step C must be finished before step F can begin.
Step A must be finished before step B can begin.
Step A must be finished before step D can begin.
Step B must be finished before step E can begin.
Step D must be finished before step E can begin.
Step F must be finished before step E can begin.
"""

class Node {
    let key: Substring
    var prerequisites: Set<Substring> = []
    var postrequisites: Set<Substring> = []
    
    init( _ key: Substring ) {
        self.key = key
    }
}

func buildNodes( _ input: String ) -> [Substring:Node] {
    var nodes: [Substring:Node] = [:]
    let lines = input.split(separator: "\n")

    for line in lines {
        let words = line.split(separator: " ")
        let first = words[1]
        let second = words[7]
        
        if nodes[first] == nil { nodes[first] = Node(first) }
        if nodes[second] == nil { nodes[second] = Node(second) }
        
        nodes[first]?.postrequisites.insert(second)
        nodes[second]?.prerequisites.insert(first)
    }
    
    return nodes
}

var nodes = buildNodes( input )
var part1 = ""

while true {
    let ready = nodes.filter { $0.value.prerequisites.count == 0 }
    
    if ready.count == 0 { break }
    
    let next = ready.sorted(by: { $0.key < $1.key } ).first!.value
    
    next.postrequisites.forEach { nodes[$0]?.prerequisites.remove(next.key ) }
    part1 += next.key
    nodes.removeValue(forKey: next.key)
}

print( "Part1:", part1 )


class Worker {
    let id: Int
    var task: Node? = nil
    var busyUntil = 0
    
    init( id: Int ) {
        self.id = id
    }
}

let baseDuration = 60
let workerCount = 5
var time = 0
var workers = ( 1 ... workerCount ).map { Worker(id: $0) }

func taskDuration( _ task: Node ) -> Int {
    let offset = Int( Character( String( task.key ) ).unicodeScalars.first!.value - upperCaseA )
    
    return baseDuration + offset + 1
}

func completeTasks( busyWorkers: [Worker] ) -> Void {
    guard busyWorkers.count > 0 else { return }
    
    let nextEvent = busyWorkers.min( by: { $0.busyUntil < $1.busyUntil } )!.busyUntil
    
    time = nextEvent
    for worker in busyWorkers.filter( { $0.busyUntil == time } ) {
        if let task = worker.task {
            print( "Worker \(worker.id) completes task \(task.key) at time \(time)" )
            task.postrequisites.forEach { nodes[$0]?.prerequisites.remove(worker.task!.key ) }
            worker.task = nil
        }
    }
}

nodes = buildNodes( input )

while nodes.count > 0 {
    let busyWorkers = workers.filter { $0.task != nil }
    
    if busyWorkers.count == workerCount {
        completeTasks( busyWorkers: busyWorkers )

    } else {
        let ready = nodes.filter { $0.value.prerequisites.count == 0 }
        
        if ready.count == 0 {
            completeTasks( busyWorkers: busyWorkers )
        } else {
            let task = ready.sorted(by: { $0.key < $1.key } ).first!.value
            let worker = workers.first(where: { $0.task == nil } )!
            
            print( "Worker \(worker.id) assigned task \(task.key) at time \(time)" )
            worker.task = task
            worker.busyUntil = time + taskDuration(task)
            nodes.removeValue(forKey: task.key)
        }
    }
}

print( "Part2:", workers.max( by: { $0.busyUntil < $1.busyUntil } )!.busyUntil )
