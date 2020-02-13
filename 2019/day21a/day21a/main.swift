//
//  main.swift
//  day21a
//
//  Created by Mark Johnson on 1/3/20.
//  Copyright © 2020 matzsoft. All rights reserved.
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


// MARK: - Useful for handling and displaying bits

extension Int {
    func extract( bits: Int ) -> [Int] {
        let sentinal = 1 << bits

        return ( 1 ... bits ).map { self & ( sentinal >> $0 ) == 0 ? 0 : 1 }
    }
    
    func asBinary( bits: Int ) -> String {
        let sentinal = 1 << bits

        return ( 1 ... bits ).map { self & ( sentinal >> $0 ) == 0 ? "0" : "1" }.joined()
    }
    
    func logicalTerm( bits: Int ) -> String {
        let labels = Array( "ABCDEFGHI" )
        let sentinal = 1 << bits

        return ( 1 ... bits ).map {
            self & ( sentinal >> $0 ) == 0 ? "!\(labels[$0-1])" : "\(labels[$0-1])"
        }.joined(separator: " * " )
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

func walkOrJump( scan: Int, range: Int ) -> String {
    func trial( hull: [Int], position: Int ) -> Bool {
        guard position < hull.count else { return true }
        guard hull[position] == 1 else { return false }
        
        return trial( hull: hull, position: position + 1 ) || trial( hull: hull, position: position + 4 )
    }

    let hull = [ 1 ] + scan.extract( bits: range ) + [ 0, 0 ]
    let walk = trial( hull: hull, position: 1 )
    let jump = trial( hull: hull, position: 4 )
    
    if walk && jump { return "X" }
    if walk         { return "W" }
    if jump         { return "J" }
    
    return "K"
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

( 0b1000 ... 0b1111 ).forEach { print( "\($0.asBinary(bits: 4)) \(walkOrJump(scan: $0, range: 4))" ) }
let candidates = ( 0b1000 ... 0b1111 ).filter { walkOrJump( scan: $0, range: 4 ) == "J" }
candidates.forEach { print( $0.asBinary( bits: 4 ) ) }
print( "!A + " + candidates.map { "( " + $0.logicalTerm(bits: 4 ) + " )" }.joined(separator: " + " ) )
// (! a && d) || (! b && d)
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

//[ "0........" ].forEach { print( "Range \($0) \( check( pattern: $0 ) )" ) }
//( 0b10000 ... 0b11111 ).map { String( $0, radix: 2 ) + "...." }.forEach {
//    print( "Range \($0) \( check( pattern: $0 ) )" )
//}
//print()
//[ "11010..0.", "11010..1." ].forEach { print( "Range \($0) \( check( pattern: $0 ) )" ) }


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




func grayCode( bits: Int ) -> [Int] {
    guard bits > 1 else { return [ 0, 1 ] }
    
    let prev = grayCode( bits: bits - 1 )
    let verp = prev.reversed()
    let extend = 1 << ( bits - 1 )
    
    return prev + verp.map { $0 + extend }
}


let codes = grayCode( bits: 2 )
let grid = ( 0 ... 3 ).map { y in ( 0 ... 3 ).map { x in
    walkOrJump( scan: 4 * codes[y] + codes[x], range: 4 ) }
}
let header = "AB|CD," + codes.map { $0.asBinary( bits: 2 ) }.joined(separator: "," )
let rows = ( 0 ... 3 ).map { codes[$0].asBinary( bits: 2 ) + "," + grid[$0].joined( separator: "," ) }
let filename = "/Users/markj/Development/adventofcode/2019/output/day21.txt"
let contents = header + "\n" + rows.joined( separator: "\n" )

try! contents.write( toFile: filename, atomically: true, encoding: String.Encoding.utf8 )



// MARK: - Quine–McCluskey

typealias Term = Int
typealias Implicant = Set<Term>

struct Bazinga {
    let inputs: Int
    let truthTable: [Bool?]
    let neighborsTable: [Implicant]
    let halfTerm: Term
    let lastTerm: Term

    init( inputs: Int ) {
        self.inputs = inputs
        halfTerm = Term( 1 << ( inputs - 1 ) )
        lastTerm = Term( ( 1 << inputs ) - 1 )
        
        let truthTable = Array( repeating: true, count: halfTerm ) + ( halfTerm ... lastTerm ).map {
            walkOrJump( scan: $0, range: inputs ) == "J"
        }
        
        self.truthTable = truthTable
        neighborsTable = truthTable.indices.map { index in
               Set( ( 0 ..< inputs ).map { index ^ ( 1 << $0 ) }.filter { truthTable[$0] != false } )
        }
    }
    
    init( inputs: Int, truthTable: [Bool?] ) {
        self.inputs = inputs
        halfTerm = Term( 1 << ( inputs - 1 ) )
        lastTerm = Term( ( 1 << inputs ) - 1 )
        
        self.truthTable = truthTable
        neighborsTable = truthTable.indices.map { index in
               Set( ( 0 ..< inputs ).map { index ^ ( 1 << $0 ) }.filter { truthTable[$0] != false } )
        }
    }

    func shape( implicant: Implicant ) -> [Int] {
//        assert( inputs.isMultiple( of: 2 ), "The shape function can't handle odd inputs" )
        let masks = stride( from: 2, through: inputs + 1, by: 2 ).map { 0b11 << ( inputs - $0 ) }

        return masks.map { mask in implicant.reduce( Implicant(), { $0.union( [ $1 & mask ] ) } ).count }
    }

    func combine( implicant1: Implicant, implicant2: Implicant ) -> Implicant? {
        guard implicant1.isDisjoint( with: implicant2 ) else { return nil }
        
        let oldShape = shape( implicant: implicant1 )
        let neighbors = implicant1.reduce( Implicant(), {
            $0.union( neighborsTable[$1] )
        } ).subtracting( implicant1 )

        guard !neighbors.isDisjoint( with: implicant2 ) else { return nil }
        guard oldShape == shape( implicant: implicant2 ) else { return nil }
        
        let combination = implicant1.union( implicant2 )
        let newShape = shape( implicant: combination )
        let indices = oldShape.indices.filter { oldShape[$0] != newShape[$0] }
        
        guard indices.count == 1 else { return nil }
        
        return newShape[indices[0]] == 2 * oldShape[indices[0]] ? combination : nil
    }

    func makePrimeImplicants() -> Set<Implicant> {
        var current = Set( truthTable.indices.filter { truthTable[$0] != false }.map { Set( [ $0 ] ) } )
        var primeImplicants: Set<Implicant> = Set()

        while !current.isEmpty {
            var candidates: Set<Implicant> = Set()

            for implicant in current {
                let possibles = current.compactMap { combine( implicant1: implicant, implicant2: $0 ) }
                
                if possibles.isEmpty {
                    primeImplicants.insert( implicant )
                } else {
                    for possible in possibles {
                        candidates.insert( implicant.union( possible ) )
                    }
                }
            }
            print( primeImplicants.count, candidates.count )
            current = candidates
        }
        
        return primeImplicants
    }

    func implicantMask( implicant: Implicant ) -> Int {
        return lastTerm ^ implicant.reduce( 0, { $0 | ( $1 ^ implicant.first! ) } )
    }

    func implicantTerm( implicant: Implicant ) -> String {
        let usedMask = implicantMask( implicant: implicant )
        let labels = Array( "ABCDEFGHI" )
        let sentinal = 1 << inputs

        return ( 1 ... inputs ).compactMap {
            let mask = sentinal >> $0
            guard usedMask & mask == mask else { return String?( nil ) }
            return implicant.first! & mask == 0 ? "!\(labels[$0-1])" : "\(labels[$0-1])"
        }.joined(separator: " * " )
    }
    
    func asBinary( implicant: Implicant ) -> String {
        let usedMask = implicantMask( implicant: implicant )
        
        return ( 1 ... inputs ).map {
            let shiftCount = inputs - $0
            let mask = 1 << shiftCount
            guard usedMask & mask == mask else { return "-" }
            return String( ( implicant.first! & mask ) >> shiftCount )
        }.joined()
    }

    func implicantNegatives( implicant: Implicant ) -> [String] {
        let usedMask = implicantMask( implicant: implicant )
        let labels = Array( "ABCDEFGHI" )

        return ( 1 ... inputs ).compactMap {
            let mask = 1 << ( inputs - $0 )
            return usedMask & mask == 0 || implicant.first! & mask != 0 ? String?( nil ) : "\(labels[$0-1])"
        }
    }

    func implicantPositives( implicant: Implicant ) -> [String] {
        let usedMask = implicantMask( implicant: implicant )
        let labels = Array( "ABCDEFGHI" )

        return ( 1 ... inputs ).compactMap {
            let mask = 1 << ( inputs - $0 )
            return usedMask & mask == 0 || implicant.first! & mask == 0 ? String?( nil ) : "\(labels[$0-1])"
        }
    }
    
    func makeEssentialImplicants() -> Set<Implicant> {
        var remainingTerms = truthTable.indices.filter { truthTable[$0] == true }
        var remainingImplicants = makePrimeImplicants()
        var essentialImplicants = Set<Implicant>()
        
        for minterm in remainingTerms {
            let coverage = remainingImplicants.filter { $0.contains( minterm ) }
            
            if coverage.count == 1 {
                let implicant = coverage.first!
                
                remainingTerms.removeAll { implicant.contains( $0 ) }
                remainingImplicants.remove( implicant )
                essentialImplicants.insert( implicant )
            }
        }
        
        for implicant in remainingImplicants {
            if implicant.isSuperset( of: remainingTerms ) {
                remainingTerms = []
                essentialImplicants.insert( implicant )
                remainingImplicants.remove( implicant )
                break
            }
        }
        
        print( "Remaining Terms" )
        remainingTerms.forEach { print( "    ", $0.asBinary( bits: inputs ) ) }
        print( "Remaining Implicants" )
        remainingImplicants.forEach { print( "    ", asBinary( implicant: $0 ) ) }
        print( "Essential Implicants" )
        essentialImplicants.forEach { print( "    ", asBinary( implicant: $0 ) ) }
        print( essentialImplicants.map { implicantTerm( implicant: $0 ) }.joined( separator: " + ") )
        
        return essentialImplicants
    }

    func springdroidCommands( final: String ) -> String {
        var result: [String] = []
        let implicants = makeEssentialImplicants()
        
        for implicant in implicants {
            let destination = implicant == implicants.first ? "J" : "T"
            let negatives = implicantNegatives( implicant: implicant )
            let positives = implicantPositives( implicant: implicant )
            
            if negatives.isEmpty {
                result.append( "NOT \(positives.first!) \(destination)" )
                result.append( "NOT \(destination) \(destination)" )
                for positive in positives {
                    if positive != positives.first {
                        result.append( "AND \(positive) \(destination)" )
                    }
                }
            } else {
                result.append("NOT \(negatives.first!) \(destination)" )
                if negatives.count > 1 {
                    result.append( "NOT \(destination) \(destination)" )
                    for negative in negatives {
                        if negative != negatives.first {
                            result.append( "OR  \(negative) \(destination)" )
                        }
                    }
                    result.append( "NOT \(destination) \(destination)" )
                }
                for positive in positives {
                    result.append( "AND \(positive) \(destination)" )
                }
            }
            if implicant != implicants.first {
                result.append("OR  T J" )
            }
        }
        
        result.append( final )
        return result.joined( separator: "\n" )
    }
}

print( "----------------------" )


func toTruthTable( expression: String, inputs: Int ) -> [Bool?] {
    let labels = "ABCDEFGHI"
    let expression = expression.replacingOccurrences( of: " ", with: "" )
    let terms = expression.split( separator: "+" )
    var truthTable = Array( repeating: Bool?( false ), count: 1 << inputs )
    
    print( expression )
    print( terms )
    
    for term in terms {
        let variables = term.split( separator: "*" )
        var mask = 0
        var value = 0

        for variable in variables {
            let not = variable.first == "!"
            let name = not ? variable.last! : variable.first!
            let index = labels.distance( from: labels.startIndex, to: labels.firstIndex( of: name )! )
            let bit = 1 << ( inputs - index - 1 )
            
            mask |= bit
            if !not { value |= bit }
        }
        
        for index in truthTable.indices {
            if index & mask == value {
                truthTable[index] = true
            }
        }
    }
    
    return truthTable
}

func makeTruthTable( index: Int, inputs: Int ) -> Bool? {
    let call = walkOrJump( scan: index, range: inputs )
    let masks = [
        ( 0b110100000, 0b100100000 ),
        ( 0b111111110, 0b110101110 ),
        ( 0b111110000, 0b110110000 )
    ]
    
    if call == "J" { return true }
    if index < ( 1 << ( inputs - 1 ) ) { return true }
    
    for mask in masks {
        if index & mask.0 == mask.1 { return true }
    }
    
    return false
}


do {
    let bazinga1 = Bazinga( inputs: 4 )
    let part1Commands = bazinga1.springdroidCommands( final: "WALK" )
    let part1Controller = Controller( memory: initialMemory, commands: part1Commands )

    print( "Part 1: \( part1Controller.trial( quietly: false ) )" )

    let bazinga2 = Bazinga( inputs: 9 )
    let truthTable = bazinga2.truthTable.indices.map { makeTruthTable( index: $0, inputs: bazinga2.inputs ) }
    let bazinga3 = Bazinga( inputs: bazinga2.inputs, truthTable: truthTable )
    let part2Commands = bazinga3.springdroidCommands( final: "RUN" )
    let part2Controller = Controller( memory: initialMemory, commands: part2Commands )

    print( "Part 2: \( part2Controller.trial( quietly: false ) )" )
}


do {
//    let inputs = 9
//    let test1 = "!A + !B * D + B * !C * D * E + B * !C * D * !E * H"
//    let test2 = "!A + D * !B + D * E * !C + D * H * !C"
//    let test = "!B * D * !E * H + !B * D * !G * H + !C * D * !F * H + !C * D * !G * H + !A + !B * D * !F * H"
//    let tt1 = toTruthTable( expression: test1, inputs: inputs )
//    let tt2 = toTruthTable( expression: test2, inputs: inputs )
//    let truthTable = toTruthTable( expression: test, inputs: inputs )
//    let bazinga2 = Bazinga( inputs: inputs )
//    let newTT = bazinga2.truthTable.indices.map { makeTruthTable( index: $0, inputs: inputs ) }
//
//    print( truthTable == bazinga2.truthTable )
//    print( tt1 == tt2 )
//    print( tt2 == bazinga2.truthTable )
//    print( tt2 == newTT )
//    print( "------------------" )
//    var count = 0
//    for index in bazinga2.truthTable.indices {
//        let call = walkOrJump( scan: index, range: inputs )
//
//        if ( call == "K" || call == "X" ) && index & 0x90 == 0x90 { count += 1 }
//        if index >= bazinga2.halfTerm {
//            print( index.asBinary( bits: inputs ), tt2[index]!, bazinga2.truthTable[index]!, call )
//        }
//    }
//    print( count )
//    
//    let bazinga1 = Bazinga( inputs: inputs, truthTable: newTT )
//    let part2Commands = bazinga1.springdroidCommands( final: "RUN" )
//    let part2Controller = Controller( memory: initialMemory, commands: part2Commands )
//    
//    print("Part 2: \( part2Controller.trial( quietly: false ) )" )
}
