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
import Library

extension Set {
    var allSubsets: Set<Set<Element>> {
        var subsets = Set<Set<Element>>( [ Set<Element>() ] )
        
        for element in self {
            let subsetsWithout = self.filter { $0 != element }.allSubsets
            
            for subset in subsetsWithout { subsets.insert( subset ) }
            for subset in subsetsWithout { subsets.insert( subset.union( [ element ] ) ) }
        }
        
        return subsets
    }
}

struct Game {
    var computer:    Intcode
    var runQuiet:    Bool
    var inputQueue:  [String]
    var trace:       Bool
    var traceBuffer: [String]
    var maxOutput:   Int
    
    var isHalted:    Bool { computer.nextInstruction.opcode == .halt }
    
    init( memory: [Int] ) {
        computer    = Intcode( name: "AOC-Advent", memory: memory )
        runQuiet    = false
        inputQueue  = []
        trace       = false
        traceBuffer = []
        maxOutput   = 0
    }
    
    init( from other: Game ) {
        computer    = Intcode( from: other.computer )
        runQuiet    = other.runQuiet
        inputQueue  = other.inputQueue
        trace       = other.trace
        traceBuffer = other.traceBuffer
        maxOutput   = other.maxOutput
    }

    func command( value: String ) -> Void {
        computer.inputs.append( contentsOf: value.map { Int( $0.asciiValue! ) } )
        computer.inputs.append( Int( Character( "\n" ).asciiValue! ) )
    }
    
    mutating func runUntilInput() throws -> String {
        var outputQueue = ""
        let outputLimit = maxOutput == 0 ? Int.max : 5 * maxOutput
        defer { maxOutput = max( maxOutput, outputQueue.count ) }
        
        while true {
            if computer.nextInstruction.opcode == .input {
                if computer.inputs.isEmpty {
                    return outputQueue
                }
            }

            if outputQueue.count >= outputLimit {
                // The computer seems hung.  Simulate a halt.
                computer.memory[computer.ip] = Intcode.Instruction.Opcode.halt.rawValue
                outputQueue.append( "\nDroid is hung.  Forcing a halt.\n" )
                return outputQueue
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
            
            if isHalted { break }
        }
        
        return outputQueue
    }
    
    mutating func send( command: String ) throws -> String {
        if !runQuiet { print( command ) }
        self.command( value: command )
        
        let output = try runUntilInput()
        if !runQuiet { print( output, terminator: "" ) }
        return output
    }
    
    mutating func interactive() throws -> String {
        while true {
            let output = try runUntilInput()

            print( output, terminator: "" )
            if isHalted { return output }

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
    class Room {
        let name:        String
        let description: String
        var exits:       [ String : Room? ]
        var items:       Set<String>
        let ejectsTo:    String?

        init?( input: String ) {
            let paragraphs = input.components( separatedBy: "\n\n" ).map {
                $0.trimmingCharacters( in: .newlines )
            }
            let rooms = paragraphs.indices.filter { paragraphs[$0].hasPrefix( "== " ) }
            
            guard !rooms.isEmpty else { return nil }
            
            let lines  = paragraphs[rooms[0]].components( separatedBy: "\n" )
            let doors  = paragraphs.first( where: { $0.hasPrefix( "Doors here lead:" ) } )
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
                items = Set( stuff[1...] )
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
        
        deinit {
            exits = [:]         // eliminate cyclic references.
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
    }
    
    struct SavedState {
        let game: Game
        let room: Room
        let inventory: Set<String>
    }

    var game:      Game
    let runQuiet:  Bool
    var room:      Room
    var roomsList: [Room]
    var roomsDict: [ String : Room ]
    var ejector:   Room?
    var inventory: Set<String>
    
    init( game: Game ) throws {
        self.game      = game
        self.runQuiet  = game.runQuiet

        let initialOutput = try self.game.runUntilInput()
        if !runQuiet { print( initialOutput, terminator: "" ) }

        guard let room = Room( input: initialOutput ) else {
            throw RuntimeError( "Game initialization failed." ) }
        
        self.room = room
        roomsList = [ room ]
        roomsDict = [ room.name : room ]
        ejector   = nil
        inventory = []
        
        try checkItems()
        try exploreMore()
    }
    
    mutating func saveState() -> SavedState {
        return SavedState( game: Game( from: game ), room: room, inventory: inventory )
    }
    
    mutating func restore( state: SavedState ) -> Void {
        game = state.game
        room = state.room
        inventory = state.inventory
    }
    
    mutating func checkItems() throws -> Void {
        for item in room.items {
            let beforeTake = saveState()
            
            if try !take( item: item ) {
                restore( state: beforeTake )
                continue
            }
            
            let beforeMove = saveState()
            let output = try game.send( command: room.exits.first!.key )
            guard !game.isHalted, Room( input: output ) != nil else {
                restore( state: beforeTake )
                continue
            }
            
            restore( state: beforeMove )
        }
    }
    
    mutating func findNewRooms() throws -> Void {
        // Walk around randomly until you reach a room that has been completely explored.
        while let nextDirection = room.exits.first( where: { $0.value == nil } ) {
            let output = try game.send( command: nextDirection.key )
            guard !game.isHalted else {
                throw RuntimeError( "Moving \(nextDirection) from \(room.name) causes a halt." ) }
            guard let nextRoom = Room( input: output ) else {
                throw RuntimeError( "Moving \(nextDirection) from \(room.name) goes nowhere." )
            }
            
            if let alreadyVisited = roomsDict[ nextRoom.name ] {
                if !alreadyVisited.matches( other: nextRoom ) {
                    throw RuntimeError( "Two rooms named \(nextRoom.name)?" )
                }
                room.exits[nextDirection.key] = alreadyVisited
                room = alreadyVisited
            } else {
                room.exits[nextDirection.key] = nextRoom
                roomsList.append( nextRoom )
                roomsDict[nextRoom.name] = nextRoom
                room = nextRoom
                try checkItems()
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
            try move( to: nextRoom )
            try findNewRooms()
        }
        
        let ejectors = roomsList.filter { $0.ejectsTo != nil }
        guard ejectors.count == 1 else {
            throw RuntimeError( "Expecting 1 ejector but found \(ejectors.count)." ) }
        ejector = ejectors[0]
    }
    
    mutating func move( to other: Room ) throws -> Void {
        guard let path = room.path( to: other ) else {
            throw RuntimeError( "Can't get from \(room.name) to \(other.name)." ) }

        for ( move, nextRoom ) in path {
            let output = try game.send( command: move )
            
            guard !game.isHalted else {
                throw RuntimeError( "Moving from \(room.name) to \(nextRoom.name) caused a halt." ) }
            
            guard let newRoom = Room( input: output ), newRoom.matches( other: nextRoom ) else {
                throw RuntimeError( "Moving from \(room.name) to \(nextRoom.name) fails." ) }
            
            room = nextRoom
        }
    }
    
    mutating func take( item: String ) throws -> Bool {
        let result = try game.send( command: "take \(item)" )
        
        guard !game.isHalted else { return false }

        let paragraphs = result.trimmingCharacters( in: .newlines ).components( separatedBy: "\n\n" )
        
        guard paragraphs[0] == "You take the \(item)." else { return false }
        guard paragraphs[1] == "Command?" else { return false }
        
        inventory.insert( item )
        return true
    }
    
    mutating func drop( item: String ) throws -> Bool {
        let result = try game.send( command: "drop \(item)" )
        
        guard !game.isHalted else { return false }

        let paragraphs = result.trimmingCharacters( in: .newlines ).components( separatedBy: "\n\n" )

        guard paragraphs[0] == "You drop the \(item)." else { return false }
        guard paragraphs[1] == "Command?" else { return false }
        
        inventory.remove( item )
        return true
    }
    
    mutating func solve() throws -> String {
        var items = inventory
        
        try move( to: roomsDict[ejector!.ejectsTo!]! )
        
        for item in items {
            guard try drop( item: item ) else { throw RuntimeError( "Error dropping \(item)." ) }
        }
        
        // Try each safe item, one at a time, discarding the too heavy ones.
        for item in items {
            let result = try attempt( items: [ item ] )
            switch result {
            case "heavier":
                // Single item is too light.  Keep it.
                break
            case "lighter":
                // Single item is too heavy.  Ignore it.
                items.remove( item )
            default:
                // Single item does it.
                return result
            }
        }
        
        let subsets = items.allSubsets.filter { $0.count > 1 }
        
        for subset in subsets {
            let result = try attempt( items: Array( subset ) )
            switch result {
            case "heavier", "lighter":
                break
            default:
                return result
            }
        }
        
        return "Failed to find the solution."
    }
    
    mutating func attempt( items: [String] ) throws -> String {
        let state = saveState()
        
        for item in items {
            guard try take( item: item ) else { throw RuntimeError( "Unexpected take error." ) }
        }
        
        guard let path = room.path( to: ejector! ) else {
            throw RuntimeError( "Can't get there from here." )
        }

        let output = try game.send( command: path[0].0 )
        let paragraphs = output.trimmingCharacters( in: .newlines ).components( separatedBy: "\n\n" )

        guard paragraphs[2].hasPrefix( "A loud, robotic voice says" ) else {
            throw RuntimeError( "Unexpected weight response." ) }
        
        restore( state: state )

        if paragraphs[2].contains( "heavier" ) { return "heavier" }
        if paragraphs[2].contains( "lighter" ) { return "lighter" }
        
        let words = paragraphs[2].components( separatedBy: " " )
        guard let index = words.firstIndex( of: "typing" ) else {
            throw RuntimeError( "Can't find the answer." ) }
        
        print( "Solved with: \( items.joined( separator: ", " ) )" )
        return words[index + 1]
    }
}
 
 
func parse( input: AOCinput ) -> Game {
    let initialMemory = input.line.split( separator: "," ).map { Int( $0 )! }

    return Game( memory: initialMemory )
}


func playIt( input: AOCinput ) -> Void {
    var game = parse( input: input )
    let _ = try! game.interactive()
}


func traceIt( input: AOCinput ) -> String {
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
    game.trace = true
    let words = try! game.interactive().components( separatedBy: " " )
    for line in game.traceBuffer { print( line ) }
    print( "Initial memory size \(initialSize), final memory size \(game.computer.memory.count) ")
    
    guard let index = words.firstIndex( of: "typing" ) else { return "Failed" }
    return words[index + 1]
}


func part1( input: AOCinput ) -> String {
    var game = parse( input: input )
    
    game.runQuiet = true
    do {
        var map = try Map( game: game )
        
        return try map.solve()
    } catch {
        return error.localizedDescription
    }
}


func part2( input: AOCinput ) -> String {
    return "None"
}


if CommandLine.arguments.count > 1 {
    switch CommandLine.arguments[1] {
    case "play":
        playIt( input: try getAOCinput() )
    case "trace":
        print( "The airlock code is \( traceIt( input: try getAOCinput() ) )." )
    default:
        print( "Unknown argument '\(CommandLine.arguments[1])'.  Acceptable arguments are 'play' and 'trace'." )
    }

} else {
    try print( projectInfo() )
    try runTests( part1: part1 )
    try runTests( part2: part2 )
    try solve( part1: part1 )
    try solve( part2: part2 )
}
