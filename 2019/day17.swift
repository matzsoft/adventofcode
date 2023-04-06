//
//         FILE: main.swift
//  DESCRIPTION: day17 - Set and Forget
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/11/21 13:41:13
//

import Foundation
import Library

struct Mapping {
    struct Robot {
        let position: Point2D
        let direction: DirectionUDLR
    }
    
    let rigging: Set<Point2D>
    var vacuum: Robot
    
    init( initialMemory: [Int] ) throws {
        let computer = Intcode( name: "ASCII", memory: initialMemory )
        var rigging = [Point2D]()
        var vacuum: Robot?
        var x = 0;
        var y = 0;

        while let output = try computer.execute() {
            let char = String( UnicodeScalar( output )! )
            
            switch char {
            case "\n":
                x = 0
                y += 1
            case ".":
                x += 1
            case "#":
                rigging.append( Point2D( x: x, y: y ) )
                x += 1
            default:
                if let direction = DirectionUDLR.fromArrows( char: char ) {
                    rigging.append( Point2D( x: x, y: y ) )
                    vacuum = Robot( position: Point2D( x: x, y: y ), direction: direction )
                    x += 1
                } else {
                    throw RuntimeError( "Invalid character '\(char)' while mapping scaffolding." )
                }
            }
        }
        
        self.rigging = Set( rigging )
        guard let vacuum = vacuum else { throw RuntimeError( "No vacuum robot found." ) }
        self.vacuum = vacuum
    }
    
    var asString: String {
        let bounds = Rect2D( points: Array( rigging ) )
        let vacuumX = vacuum.position.x - bounds.min.x
        let vacuumY = vacuum.position.y - bounds.min.y
        var grid = Array( repeating: Array( repeating: ".", count: bounds.width ), count: bounds.height )

        rigging.forEach {
            grid[ $0.y - bounds.min.y ][ $0.x - bounds.min.x ] = "#"
        }
        grid[vacuumY][vacuumX] = vacuum.direction.toArrow
        return grid.map { $0.joined() }.joined( separator: "\n" )
    }
    
    func alignmentParameter( position: Point2D ) -> Int {
        for direction in DirectionUDLR.allCases {
            guard rigging.contains( position.move( direction: direction ) ) else { return 0 }
        }

        return position.x * position.y
    }
    
    var calibration: Int {
        return rigging.map { alignmentParameter( position: $0 ) }.reduce( 0, + )
    }
    
    func getPath() -> [String] {
        var startPos = vacuum.position
        var endPos = startPos
        var direction = vacuum.direction
        var path: [String] = []
        
        func checkDirection() -> Bool {
            if rigging.contains( endPos + direction.vector ) { return true }
            for turn in [ Turn.left, Turn.right ] {
                if rigging.contains( endPos + direction.turn( turn ).vector ) {
                    path.append( turn.rawValue )
                    direction = direction.turn( turn )
                    return true
                }
            }
            
            return false
        }
        
        if rigging.contains( startPos + direction.turn( Turn.back ).vector ) {
            direction = direction.turn( Turn.back )
            path.append( contentsOf: [ "L", "L" ] )
        }
        
        while checkDirection() {
            while rigging.contains( endPos + direction.vector ) {
                endPos = endPos + direction.vector
            }
            path.append( String( startPos.distance( other: endPos ) ) )
            startPos = endPos
        }
        
        return path
    }
}

struct Cleaning {
    let computer: Intcode
    
    init( initialMemory: [Int] ) {
        computer = Intcode( name: "ASCII", memory: initialMemory )
        computer.memory[0] = 2
    }
    
    func command( value: String ) -> Void {
        computer.inputs.append( contentsOf: value.map { Int( $0.asciiValue! ) } )
        computer.inputs.append( Int( Character( "\n" ).asciiValue! ) )
    }
    
    func vacuum( path: [String] ) throws -> Int {
        let main = "A,A,B,C,B,C,B,C,C,A"
        let aDef = "L,10,R,8,R,8"
        let bDef = "L,10,L,12,R,8,R,10"
        let cDef = "R,10,L,12,R,10"
        let feed = "n"
        var garbage = ""
        var final = 0
        
        command( value: main )
        command( value: aDef )
        command( value: bDef )
        command( value: cDef )
        command( value: feed )
        
        while let output = try computer.execute() {
            let char = Character( UnicodeScalar( output )! )
            
            if char.isASCII { garbage.append( char ) }
            final = output
        }
        
        //print( garbage )
        return final
    }
}


func parse( input: AOCinput ) -> [Int] {
    return input.line.split( separator: "," ).map { Int( $0 )! }
}


func part1( input: AOCinput ) -> String {
    let initialMemory = parse( input: input )
    let scaffolds = try! Mapping( initialMemory: initialMemory )

    //print( scaffolds.asString )
    print( scaffolds.getPath().joined( separator: "," ) )
    return "\( scaffolds.calibration )"
}


func part2( input: AOCinput ) -> String {
    let initialMemory = parse( input: input )
    let scaffolds = try! Mapping( initialMemory: initialMemory )
    let cleaner = Cleaning( initialMemory: initialMemory )

    return try! "\(cleaner.vacuum( path: scaffolds.getPath() ) )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
