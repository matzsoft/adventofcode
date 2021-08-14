 //
//         FILE: main.swift
//  DESCRIPTION: day25 - Cryostasis
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/22/21 12:36:05
//

import Foundation

struct Item {
    let name: String
    var fatal = false
}
 
class Room {
    let name: String
    let description: String
    var exits: [ String : Room? ]
    var items: [Item]
    let ejectsTo: String?

    init?( input: String ) {
        let paragraphs = input.components( separatedBy: "\n\n" ).map {
            $0.trimmingCharacters( in: .newlines )
        }
        let rooms = paragraphs.indices.filter { paragraphs[$0].hasPrefix( "== " ) }
        
        guard !rooms.isEmpty else { return nil }
        
        let lines = paragraphs[rooms[0]].components( separatedBy: "\n" )
        let doors = paragraphs.first( where: { $0.hasPrefix( "Doors here lead:" ) } )
        let things = paragraphs.first( where: { $0.hasPrefix( "Items here:" ) } )
        
        name = String( lines[0].dropFirst( 3 ).dropLast( 3 ) )
        description = lines[1...].joined( separator: "\n" )
        
        if let doors = doors {
            let directions = doors.components( separatedBy: "\n- " )
            exits = Dictionary( uniqueKeysWithValues: directions[1...].map { ( $0, nil ) } )
        } else {
            exits = [:]
        }
        
        if let things = things {
            let stuff = things.components( separatedBy: "\n- " )
            items = Array( stuff[1...] ).map { Item( name: $0 ) }
        } else {
            items = []
        }
        
        if rooms.count == 1 {
            ejectsTo = nil
        } else {
            let lines = paragraphs[rooms.last!].components( separatedBy: "\n" )
            ejectsTo = String( lines[0].dropFirst( 3 ).dropLast( 3 ) )
        }
    }
    
    func matches( other: Room ) -> Bool {
        guard name == other.name else { return false }
        guard description == other.description else { return false }
        guard exits.keys == other.exits.keys else { return false }
        
        return true
    }
    
    func path( to other: Room ) -> [ ( String, Room ) ]? {
        guard !matches( other: other ) else { return [] }
        
        var visited = Set<String>( [ name ] )
        var queue = exits.filter { $0.value != nil }.map { [ ( $0.key, $0.value! ) ] }
        
        while let path = queue.first {
            let ( _, nextRoom ) = path.last!
            
            queue.removeFirst()
            if visited.insert( nextRoom.name).inserted {
                if nextRoom.matches( other: other ) { return path }
                let list = nextRoom.exits.filter { $0.value != nil }.map { path + [ ( $0.key, $0.value! ) ] }
                queue.append( contentsOf: list )
            }
        }
        
        return nil
    }

//    func path( to other: Room ) -> [String]? {
//        guard !matches( other: other ) else { return [] }
//
//        var visited = Set<String>( [ name ] )
//        var queue = exits.filter { $0.value != nil }.map { ( $0.value!, [ $0.key ] ) }
//
//        while let ( nextRoom, path ) = queue.first {
//            queue.removeFirst()
//            if visited.insert( nextRoom.name).inserted {
//                if nextRoom.matches( other: other ) { return path }
//                let list = nextRoom.exits.filter { $0.value != nil }.map { ( $0.value!, path + [ $0.key ] ) }
//                queue.append( contentsOf: list )
//            }
//        }
//
//        return nil
//    }
}

struct Game {
    var computer: Intcode
    var inputQueue: [String] = []
    var trace = false
    var traceBuffer = [String]()
    
    init( memory: [Int] ) {
        computer = Intcode( name: "AOC-Advent", memory: memory )
    }

    func command( value: String ) -> Void {
        computer.inputs.append( contentsOf: value.map { Int( $0.asciiValue! ) } )
        computer.inputs.append( Int( Character( "\n" ).asciiValue! ) )
    }
    
    mutating func runUntilInput() throws -> String {
        var outputQueue = ""
        
        while true {
            if computer.nextInstruction.opcode == .input {
                if computer.inputs.isEmpty {
                    return outputQueue
                }
            }

            if trace { try traceBuffer.append( computer.trace() ) }
            if let output = try computer.step() {
                if let code = UnicodeScalar( output ) {
                    let char = Character( code )
                    
                    if char.isASCII {
                        outputQueue.append( char )
                    }
                }
            }
            
            if computer.nextInstruction.opcode == .halt { break }
        }
        
        return outputQueue
    }
    
    mutating func send( command: String ) throws -> String {
        print( command )
        self.command( value: command )
        
        let output = try runUntilInput()
        print( output, terminator: "" )
        return output
    }
    
    mutating func trial() throws -> String {
        while true {
            let output = try runUntilInput()

            print( output, terminator: "" )
            if computer.nextInstruction.opcode == .halt { return output }

            if computer.inputs.isEmpty {
                if inputQueue.isEmpty {
                    let line = readLine( strippingNewline: true ) ?? ""
                    
                    command( value: line )
                } else {
                    let line = inputQueue.removeFirst()
                    
                    command( value: line )
                    print( line )
                }
            }
        }
    }
}


struct Map {
    var game: Game
    var restartComputer: Intcode
    var room: Room
    var roomsList: [Room]
    var roomsDict: [ String : Room ]
    
    init( game: Game ) throws {
        self.game = game
        self.restartComputer = Intcode( from: game.computer )

        let initialOutput = try self.game.runUntilInput()
        print( initialOutput, terminator: "" )

        guard let room = Room( input: initialOutput ) else {
            throw RuntimeError( "Game initialization failed." ) }
        
        self.room = room
        roomsList = [ room ]
        roomsDict = [ room.name : room ]
        
        try findNewRooms()
        try exploreMore()
        try findSafeItems()
        
        let items = try gatherSafeItems()
    }
    
    mutating func restart() throws -> Void {
        game.computer = Intcode( from: restartComputer )
        room = roomsList.first!
        
        print( "restart" )
        let initialOutput = try game.runUntilInput()
        print( initialOutput, terminator: "" )
    }
    
    mutating func move( to other: Room ) throws -> Bool {
        guard let path = room.path( to: other ) else {
            throw RuntimeError( "Can't get there from here." )
        }

        for ( move, nextRoom ) in path {
            let output = try game.send( command: move )
            
            guard game.computer.nextInstruction.opcode != .halt else {
                throw RuntimeError( "Unexpected halt" ) }
            
            guard let newRoom = Room( input: output ), newRoom.matches( other: nextRoom ) else {
                return false
            }
            
            room = nextRoom
        }
        
        return true
    }
    
    mutating func take( item: String ) throws -> Bool {
        guard item != "infinite loop" else { return false }         // TODO: try to improve this.
        let result = try game.send( command: "take \(item)" )
        
        guard game.computer.nextInstruction.opcode != .halt else { return false }

        let paragraphs = result.trimmingCharacters( in: .newlines ).components( separatedBy: "\n\n" )
        
        guard paragraphs[0] == "You take the \(item)." else { return false }
        guard paragraphs[1] == "Command?" else { return false }
        
        return true
    }
    
    mutating func drop( item: String ) throws -> Bool {
        let result = try game.send( command: "drop \(item)" )
        
        guard game.computer.nextInstruction.opcode != .halt else { return false }

        let paragraphs = result.trimmingCharacters( in: .newlines ).components( separatedBy: "\n\n" )

        guard paragraphs[0] == "You drop the \(item)." else { return false }
        guard paragraphs[1] == "Command?" else { return false }
        
        return true
    }
    mutating func findNewRooms() throws -> Void {
        // Walk around randomly until you reach a room that all the exits have been explored.
        while let nextDirection = room.exits.first( where: { $0.value == nil } ) {
            let output = try game.send( command: nextDirection.key )
            guard game.computer.nextInstruction.opcode != .halt else {
                throw RuntimeError( "Unexpected halt." ) }
            guard let nextRoom = Room( input: output ) else {
                throw RuntimeError( "Unexpected movement error." )
            }
            
            if let alreadyVisited = roomsDict[ nextRoom.name ] {
                if !alreadyVisited.matches( other: nextRoom ) {
                    throw RuntimeError( "Room conflict" )
                }
                room.exits[nextDirection.key] = alreadyVisited
                room = alreadyVisited
            } else {
                room.exits[nextDirection.key] = nextRoom
                roomsList.append( nextRoom )
                roomsDict[nextRoom.name] = nextRoom
                room = nextRoom
            }
            
            if let ejectsTo = room.ejectsTo {
                if room.exits.count != 1 {
                    throw RuntimeError(
                        "\(room.name) ejects to \(ejectsTo) but does not have exactly one exit." )
                }
                
                let destination = roomsDict[ejectsTo]!
                
                room.exits[ room.exits.keys.first! ] = destination
                room = destination
            }
        }
    }
    
    mutating func exploreMore() throws -> Void {
        // Next revisit the rooms that have not yet been fully explored.
        while let nextRoom = roomsList.first( where: { $0.exits.contains( where: { $0.value == nil } ) } ) {
            guard try move( to: nextRoom ) else { throw RuntimeError( "Traversal error." ) }

            try findNewRooms()
        }
    }
    
    mutating func findSafeItems() throws -> Void {
        let targetRooms = roomsList.filter { !$0.items.isEmpty }
        
        for targetRoom in targetRooms {
            try restart()
            guard try move( to: targetRoom ) else { throw RuntimeError( "Traversal error." ) }
            
            if try !take( item: room.items[0].name ) {
                room.items[0].fatal = true
                continue
            }

            guard try move( to: room.exits.first!.value! ) else {
                room.items[0].fatal = true
                continue
            }
        }
    }
    
    mutating func gatherSafeItems() throws -> [String] {
        let safeItemRooms = roomsList.filter { !$0.items.isEmpty && $0.items.allSatisfy { !$0.fatal } }
        var items = [String]()
        
        try restart()
        for targetRoom in safeItemRooms {
            guard try move( to: targetRoom ) else { throw RuntimeError( "Traversal error." ) }
            items.append( room.items[0].name )
            guard try take( item: room.items[0].name ) else {
                throw RuntimeError( "Unexpected take error." ) }
        }
        
        let ejectors = roomsList.compactMap { $0.ejectsTo }
        
        guard ejectors.count == 1 else { throw RuntimeError( "Found \(ejectors.count), expecting 1." ) }
        
        let waitingRoom = roomsDict[ejectors[0]]!
        guard try move( to: waitingRoom ) else { throw RuntimeError( "Traversal error." ) }
        
        for item in items {
            guard try drop( item: item ) else { throw RuntimeError( "Unexpected drop error." ) }
        }
        
        return items
    }
}
 
 
func parse( input: AOCinput ) -> Game {
    let initialMemory = input.line.split( separator: "," ).map { Int( $0 )! }

    return Game( memory: initialMemory )
}


func part1( input: AOCinput ) -> String {
    var game = parse( input: input )
    let initialSize = game.computer.memory.count
    let initialCommands = """
    south
    take mouse
    north
    west
    north
    north
    west
    take semiconductor
    east
    south
    west
    south
    take hypercube
    north
    east
    south
    west
    take antenna
    west
    south
    south
    south
    """
    
    game.inputQueue = initialCommands.split( separator: "\n" ).map { String( $0 ) }
//    game.trace = true
    let words = try! game.trial().components( separatedBy: " " )
    for line in game.traceBuffer { print( line ) }
    print( "Initial memory size \(initialSize), final memory size \(game.computer.memory.count) ")
    
    guard let index = words.firstIndex( of: "typing" ) else { return "Failed" }
    return words[index + 1]
}


func part2( input: AOCinput ) -> String {
    return "None"
}

if CommandLine.arguments.count > 1 {
    let game = try! parse( input: getAOCinput() )
    let map = try! Map( game: game )
    
    print( map.roomsList.count )
} else {
    try runTests( part1: part1 )
    try runTests( part2: part2 )
    try solve( part1: part1 )
    try solve( part2: part2 )
}
