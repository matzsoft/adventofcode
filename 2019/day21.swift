//
//         FILE: main.swift
//  DESCRIPTION: day21 - Springdroid Adventure
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/15/21 19:56:17
//

import Foundation

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
    let computer: Intcode
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

        computer = Intcode( name: "Robby", memory: memory )
        self.commands = assemble( code: commands )
    }
    
    func command( value: String ) -> Void {
        computer.inputs.append( contentsOf: value.map { Int( $0.asciiValue! ) } )
        computer.inputs.append( Int( Character( "\n" ).asciiValue! ) )
    }
    
    func trial( quietly: Bool = false ) throws -> Int {
        var buffer = ""
        var final = 0
        
        commands.forEach { command( value: $0 ) }
        
        while let output = try computer.execute() {
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



func parse( input: AOCinput ) -> [Int] {
    return input.line.split( separator: "," ).map { Int( $0 )! }
}


func part1( input: AOCinput ) -> String {
    let initialMemory = parse( input: input )
    
    #if false
        [ "0..." ].forEach { print( "Range \($0) \( check( pattern: $0 ) )" ) }
        ( 0b1000 ... 0b1111 ).map { String( $0, radix: 2 ) }.forEach {
            print( "Range \($0) \( check( pattern: $0 ) )" )
        }
    #endif

    // Using the information produced from check(pattern:), we can derive the following expression.
    // J = !A || !B && D || !C && D

    let commands = """
        NOT A J

        NOT B T
        AND D T
        OR  T J

        NOT C T
        AND D T
        OR  T J

        WALK
    """
    let controller = Controller( memory: initialMemory, commands: commands )

    return "\( try! controller.trial( quietly: true ) )"
}


func part2( input: AOCinput ) -> String {
    let initialMemory = parse( input: input )
    
    #if false
        [ "0........" ].forEach { print( "Range \($0) \( check( pattern: $0 ) )" ) }
        ( 0b10000 ... 0b11111 ).map { String( $0, radix: 2 ) + "...." }.forEach {
            print( "Range \($0) \( check( pattern: $0 ) )" )
        }
        print()
        [ "11010..0.", "11010..1." ].forEach { print( "Range \($0) \( check( pattern: $0 ) )" ) }
    #endif


    // Using the information produced from check(pattern:), we can derive the following expression.
    // J = !A || !B && D || B && !C && D && E || B && !C && D && !E && H
    // That is too long to translate into 15 springdroid instructions but it simplifies to this.
    // J = !A || D && !B || D && E && !C || D && H && !C

    let commands = """
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
    let controller = Controller( memory: initialMemory, commands: commands )

    return "\( try! controller.trial( quietly: true ) )"
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
