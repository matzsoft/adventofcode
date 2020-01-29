//
//  main.swift
//  day21
//
//  Created by Mark Johnson on 12/23/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

// MARK: - Intcode Computer

extension String: Error {}

enum Opcode: Int {
    case add                = 1
    case multiply           = 2
    case input              = 3
    case output             = 4
    case jumpIfTrue         = 5
    case jumpIfFalse        = 6
    case lessThan           = 7
    case equals             = 8
    case relativeBaseOffset = 9
    case halt               = 99
}

enum ParameterMode: Int {
    case position  = 0
    case immediate = 1
    case relative  = 2
}

struct Instruction {
    let opcode: Opcode
    let modes: [ParameterMode]

    init( instruction: Int ) {
        opcode = Opcode( rawValue: instruction % 100 )!
        modes = [
            ParameterMode( rawValue: instruction /   100 % 10 )!,
            ParameterMode( rawValue: instruction /  1000 % 10 )!,
            ParameterMode( rawValue: instruction / 10000 % 10 )!,
        ]
    }
    
    func mode( operand: Int ) -> ParameterMode {
        return modes[ operand - 1 ]
    }
}

class IntcodeComputer {
    let name: String
    var memory: [Int]
    var inputs: [Int]
    var pc = 0
    var relativeBase = 0
    var halted = true
    var debug = false
    
    init( name: String, memory: [Int], inputs: [Int] ) {
        self.name = name
        self.memory = memory
        self.inputs = inputs
    }

    func fetch( _ instruction: Instruction, operand: Int ) throws -> Int {
        var location = memory[ pc + operand ]
        
        switch instruction.mode( operand: operand ) {
        case .position:
            break
        case .immediate:
            return location
        case .relative:
            location += relativeBase
        }

        if location < 0 {
            throw "Negative memory fetch (\(location)) at address \(pc)"
        } else if location >= memory.count {
            return 0
        }
        return memory[location]
    }
    
    func store( _ instruction: Instruction, operand: Int, value: Int ) throws -> Void {
        var location = memory[ pc + operand ]
        
        switch instruction.mode( operand: operand ) {
        case .position:
            break
        case .immediate:
            throw "Immediate mode invalid for address \(pc)"
        case .relative:
            location += relativeBase
        }

        if location < 0 {
            throw "Negative memory store (\(location)) at address \(pc)"
        } else if location >= memory.count {
            memory.append( contentsOf: Array( repeating: 0, count: location - memory.count + 1 ) )
        }
        memory[location] = value
    }

    func grind() -> Int? {
        halted = false
        while true {
            let instruction = Instruction( instruction: memory[pc] )
            
            switch instruction.opcode {
            case .add:
                let operand1 = try! fetch( instruction, operand: 1 )
                let operand2 = try! fetch( instruction, operand: 2 )
                
                try! store( instruction, operand: 3, value: operand1 + operand2 )
                pc += 4
            case .multiply:
                let operand1 = try! fetch( instruction, operand: 1 )
                let operand2 = try! fetch( instruction, operand: 2 )

                try! store( instruction, operand: 3, value: operand1 * operand2 )
                pc += 4
            case .input:
                if debug { print( "\(name): inputs \(inputs.first!)" ) }
                try! store( instruction, operand: 1, value: inputs.removeFirst() )
                pc += 2
            case .output:
                let operand1 = try! fetch( instruction, operand: 1 )

                pc += 2
                if debug { print( "\(name): outputs \(operand1)" ) }
                return operand1
            case .jumpIfTrue:
                let operand1 = try! fetch( instruction, operand: 1 )
                let operand2 = try! fetch( instruction, operand: 2 )

                if operand1 != 0 {
                    pc = operand2
                } else {
                    pc += 3
                }
            case .jumpIfFalse:
                let operand1 = try! fetch( instruction, operand: 1 )
                let operand2 = try! fetch( instruction, operand: 2 )

                if operand1 == 0 {
                    pc = operand2
                } else {
                    pc += 3
                }
            case .lessThan:
                let operand1 = try! fetch( instruction, operand: 1 )
                let operand2 = try! fetch( instruction, operand: 2 )

                if operand1 < operand2 {
                    try! store( instruction, operand: 3, value: 1 )
                } else {
                    try! store( instruction, operand: 3, value: 0 )
                }
                pc += 4
            case .equals:
                let operand1 = try! fetch( instruction, operand: 1 )
                let operand2 = try! fetch( instruction, operand: 2 )

                if operand1 == operand2 {
                    try! store( instruction, operand: 3, value: 1 )
                } else {
                    try! store( instruction, operand: 3, value: 0 )
                }
                pc += 4
            case .relativeBaseOffset:
                let operand1 = try! fetch( instruction, operand: 1 )

                relativeBase += operand1
                pc += 2
            case .halt:
                if debug { print( "\(name): halts" ) }
                halted = true
                return nil
            }
        }
    }
}


// MARK: - Get and parse the input

guard CommandLine.arguments.count > 1 else {
    print( "No input file specified" )
    exit( 1 )
}

let input = try String( contentsOfFile: CommandLine.arguments[1] ).dropLast( 1 )
let initialMemory = input.split( separator: "," ).map { Int($0)! }


// MARK: - Common to Part 1 and Part 2

func walkOrJump( scan: String ) -> String {
    func trial( hull: [Int], position: Int ) -> Bool {
        guard position < hull.count else { return true }
        guard hull[position] == 1 else { return false }
        
        return trial( hull: hull, position: position + 1 ) || trial( hull: hull, position: position + 4 )
    }

    let hull = [ 1 ] + scan.map { Int( String( $0 ) )! } + [ 0 ]
    let walk = trial( hull: hull, position: 1 )
    let jump = trial( hull: hull, position: 4 )
    
    if walk && jump { return "X" }
    if walk         { return "W" }
    if jump         { return "J" }
    
    return "K"
}

func getCandidates( pattern: String ) -> [String] {
    let dots = pattern.filter { $0 == "." }.count
    let limit = 1 << dots
    var list: [String] = []
    
    for index in 0 ..< limit {
        var result = pattern
        let bits = String( index + limit, radix: 2 ).dropFirst()
        
        bits.forEach {
            let range = result.range( of: "." )!
            result = result.replacingCharacters( in: range, with: String( $0 ) )
        }
        list.append( result )
    }
    return list.filter { walkOrJump( scan: $0 ) != "K" }
}

func check( pattern: String ) -> String {
    let candidates = getCandidates( pattern: pattern )
    let categories = candidates.map { walkOrJump( scan: $0 ) }
    
    if categories.count == 0                                { return "None" }
    if categories.allSatisfy( { $0 == "J" } )               { return "J" }
    if categories.allSatisfy( { $0 == "W" } )               { return "W" }
    if categories.allSatisfy( { $0 == "X" } )               { return "X" }
    if categories.allSatisfy( { $0 == "J" || $0 == "X" } )  { return "J or X" }
    if categories.allSatisfy( { $0 == "W" || $0 == "X" } )  { return "W or X" }

    let errors = ( ["Problems"] + candidates.map { "    \($0) \( walkOrJump( scan: $0 ) )" } )
    
    return errors.joined(separator: "\n" )
}

struct Controller {
    let computer: IntcodeComputer
    let commands: [ String ]
    
    init( memory: [Int], commands: String ) {
        func assemble( code: String ) -> [String] {
            var lines = code.uppercased().split( separator: "\n" ).map { String( $0 ) }
            
            lines = lines.map {
                $0.replacingOccurrences( of: #"^\s+"#, with: "", options: .regularExpression )
            }
            lines = lines.map {
                $0.replacingOccurrences( of: #"\s+(//.*)$"#, with: "", options: .regularExpression )
            }
            lines = lines.map {
                $0.replacingOccurrences( of: #"\s+"#, with: " ", options: .regularExpression )
            }
            
            return lines.filter { $0 != "" }
        }

        computer = IntcodeComputer( name: "Robby", memory: memory, inputs: [] )
        self.commands = assemble( code: commands )
    }
    
    func command( value: String ) -> Void {
        computer.inputs.append( contentsOf: value.map { Int( $0.asciiValue! ) } )
        computer.inputs.append( Int( Character( "\n" ).asciiValue! ) )
    }
    
    func trial( quietly: Bool = false ) -> Int {
        var buffer = ""
        var final = 0
        
        commands.forEach { command( value: $0 ) }
        
        while let output = computer.grind() {
            if let code = UnicodeScalar( output ) {
                let char = Character( code )
                
                if char.isASCII { buffer.append( char ) }
            }
            final = output
        }
        
        if !quietly { print( buffer ) }
        return final
    }
}


// MARK: - Part 1 starts here

[ "0..." ].forEach { print( "Range \($0) \( check( pattern: $0 ) )" ) }
( 0b1000 ... 0b1111 ).map { String( $0, radix: 2 ) }.forEach {
    print( "Range \($0) \( check( pattern: $0 ) )" )
}

// Using the information produced from check(pattern:), we can derive the following expression.
// J = !A || !B && D || !C && D

let part1Commands = """
    NOT A J

    NOT B T
    AND D T
    OR  T J

    NOT C T
    AND D T
    OR  T J

    WALK
"""
let part1Controller = Controller( memory: initialMemory, commands: part1Commands )

print( "Part 1: \( part1Controller.trial( quietly: true ) )" )


// MARK: - Part 2 starts here

[ "0........" ].forEach { print( "Range \($0) \( check( pattern: $0 ) )" ) }
( 0b10000 ... 0b11111 ).map { String( $0, radix: 2 ) + "...." }.forEach {
    print( "Range \($0) \( check( pattern: $0 ) )" )
}
print()
[ "11010..0.", "11010..1." ].forEach { print( "Range \($0) \( check( pattern: $0 ) )" ) }


// Using the information produced from check(pattern:), we can derive the following expression.
// J = !A || !B && D || B && !C && D && E || B && !C && D && !E && H
// That is too long to translate into 15 springdroid instructions but it simplifies to this.
// J = !A || D && !B || D && E && !C || D && H && !C

let part2Commands = """
    NOT A J

    NOT B T
    AND D T
    OR  T J

    NOT C T
    AND D T
    AND E T
    OR  T J

    NOT C T
    AND D T
    AND H T
    OR  T J

    RUN
"""
let part2Controller = Controller( memory: initialMemory, commands: part2Commands )

print( "Part 2: \( part2Controller.trial( quietly: true ) )" )
