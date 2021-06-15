//
//         FILE: main.swift
//  DESCRIPTION: day10 - The Stars Align
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/16/21 15:04:40
//

import Foundation

class Light {
    var position: Point2D
    let velocity: Point2D
    
    init( line: String ) {
        let words = line.split( whereSeparator: { " ,<>".contains($0) } )
        
        position = Point2D( x: Int( words[1] )!, y: Int( words[2] )! )
        velocity = Point2D( x: Int( words[4] )!, y: Int( words[5] )! )
    }
    
    func forward() -> Void {
        position = position + velocity
    }
    
    func backward() -> Void {
        position = position - velocity
    }
}


func yRange( lights: [Light] ) -> Int {
    let bounds = Rect2D( points: lights.map { $0.position } )

    return bounds.max.y - bounds.min.y
}


func printLights( step: Int, lights: [Light] ) -> Void {
    let bounds = Rect2D( points: lights.map { $0.position } )

    print( "After \(step) seconds:" )
    for y in bounds.min.y ... bounds.max.y {
        var line = ""
        
        for x in bounds.min.x ... bounds.max.x {
            line.append( lights.contains( where: { $0.position.x == x && $0.position.y == y } ) ? "#" : "." )
        }
        
        print(line)
    }
}


func convertLights( lights: [Light] ) -> [[Bool]] {
    let bounds = Rect2D( points: lights.map { $0.position } )
    
    return ( bounds.min.y ... bounds.max.y ).reduce( into: [[Bool]]() ) { screen, y in
        screen.append( ( bounds.min.x ... bounds.max.x ).reduce( into: [Bool]() ) { line, x in
            line.append(
                lights.contains( where: { $0.position.x == x && $0.position.y == y } ) ? true : false
            )
        } )
    }
}


func parse( input: AOCinput ) -> [Light] {
    return input.lines.map { Light( line: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let lights = parse( input: input )
    let blockLetters = try! BlockLetterDictionary( from: "6x10+2.txt" )
    var yRangeLast = yRange(lights: lights)

    for step in 1 ... Int.max {
        lights.forEach { $0.forward() }
        
        let yrange = yRange(lights: lights)
        
        if yrange < yRangeLast {
            yRangeLast = yrange
        } else {
            lights.forEach { $0.backward() }
            #if false           // Change to true to print the block letters.
                printLights( step: step - 1, lights: lights )
            #endif
            return "\(blockLetters.makeString( screen: convertLights( lights: lights ) ))"
        }
    }
    return ""
}


func part2( input: AOCinput ) -> String {
    let lights = parse( input: input )
    var yRangeLast = yRange(lights: lights)

    for step in 1 ... Int.max {
        lights.forEach { $0.forward() }
        
        let yrange = yRange(lights: lights)
        
        if yrange < yRangeLast {
            yRangeLast = yrange
        } else {
            return "\(step - 1)"
        }
    }
    return ""
}


try runTestsPart1( part1: part1 )
try runTestsPart2( part2: part2 )
try runPart1( part1: part1 )
try runPart2( part2: part2 )
