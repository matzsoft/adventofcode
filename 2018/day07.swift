//
//         FILE: main.swift
//  DESCRIPTION: day07 - The Sum of Its Parts
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/06/21 19:29:13
//

import Foundation

let upperCaseA = Character("A").unicodeScalars.first!.value
let baseDuration = 60
let workerCount = 5

class Node {
    let key: Substring
    var prerequisites: Set<Substring> = []
    var postrequisites: Set<Substring> = []
    
    init( _ key: Substring ) {
        self.key = key
    }
}


func parse( input: AOCinput ) -> [ Substring : Node ] {
    var nodes: [ Substring : Node ] = [:]

    for line in input.lines {
        let words = line.split( separator: " " )
        let first = words[1]
        let second = words[7]
        
        if nodes[first] == nil { nodes[first] = Node( first ) }
        if nodes[second] == nil { nodes[second] = Node( second ) }
        
        nodes[first]?.postrequisites.insert( second )
        nodes[second]?.prerequisites.insert( first )
    }
    
    return nodes
}


func part1( input: AOCinput ) -> String {
    var nodes = parse( input: input )
    var order = ""

    while let next = nodes.filter( { $0.value.prerequisites.count == 0 } )
            .sorted( by: { $0.key < $1.key } ).first?.value
    {
        next.postrequisites.forEach { nodes[$0]?.prerequisites.remove( next.key ) }
        order += next.key
        nodes.removeValue( forKey: next.key )
    }

    return order
}

// This is a "non-destructive" version of part1.  Takes twice as long to run.
func part3( input: AOCinput ) -> String {
    let nodes = parse( input: input )
    var completed = Set<Substring>()
    var order = ""

    while let next = nodes
            .filter( {
                !completed.contains( $0.key ) && $0.value.prerequisites.subtracting( completed ).isEmpty
            } )
            .sorted( by: { $0.key < $1.key } ).first?.value
    {
        order += next.key
        completed.insert( next.key )
    }

    return order
}


class Worker {
    let id: Int
    var task: Node? = nil
    var busyUntil = 0
    
    init( id: Int ) {
        self.id = id
    }
}


func taskDuration( _ task: Node ) -> Int {
    let offset = Int( Character( String( task.key ) ).unicodeScalars.first!.value - upperCaseA )
    
    return baseDuration + offset + 1
}


func completeTasks( busyWorkers: [Worker], nodes: [Substring : Node], time: Int ) -> Int {
    guard busyWorkers.count > 0 else { return time }
    
    let time = busyWorkers.min( by: { $0.busyUntil < $1.busyUntil } )!.busyUntil
    
    for worker in busyWorkers.filter( { $0.busyUntil == time } ) {
        if let task = worker.task {
            // print( "Worker \(worker.id) completes task \(task.key) at time \(time)" )
            task.postrequisites.forEach { nodes[$0]?.prerequisites.remove(worker.task!.key ) }
            worker.task = nil
        }
    }
    
    return time
}


func part2( input: AOCinput ) -> String {
    var nodes = parse( input: input )
    let workers = ( 1 ... workerCount ).map { Worker(id: $0) }
    var time = 0

    while nodes.count > 0 {
        let busyWorkers = workers.filter { $0.task != nil }
        
        if busyWorkers.count == workerCount {
           time = completeTasks( busyWorkers: busyWorkers, nodes: nodes, time: time )

        } else {
            let ready = nodes.filter { $0.value.prerequisites.count == 0 }
            
            if ready.count == 0 {
                time = completeTasks( busyWorkers: busyWorkers, nodes: nodes, time: time )
            } else {
                let task = ready.sorted(by: { $0.key < $1.key } ).first!.value
                let worker = workers.first( where: { $0.task == nil } )!
                
                // print( "Worker \(worker.id) assigned task \(task.key) at time \(time)" )
                worker.task = task
                worker.busyUntil = time + taskDuration( task )
                nodes.removeValue( forKey: task.key )
            }
        }
    }

    return "\(workers.max( by: { $0.busyUntil < $1.busyUntil } )!.busyUntil)"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
try solve( part1: part3 )
