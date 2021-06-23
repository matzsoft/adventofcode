//
//         FILE: main.swift
//  DESCRIPTION: day19 - Go With The Flow
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/27/21 16:05:44
//

import Foundation

func sumFactors( target: Int ) -> Int {
    let limit = Int( sqrt( Double( target ) ) )
    var sum = 0
    
    for candidate in 1 ... limit {
        if target % candidate == 0 {
            sum += candidate + target / candidate
        }
    }
    
    return sum
}


func part1( input: AOCinput ) -> String {
    let device = WristDevice( assembly: input.lines )
    
    device.run()
    return "\(device.registers[0])"
}


func part1a( input: AOCinput ) -> String {
    let device = WristDevice( assembly: input.lines )
    let argRegister = device.memory[4].b
    
    device.setBreakpoint( address: 1, action: { return false } )
    device.run()
    return "\(sumFactors( target: device.registers[argRegister] ))"
}


func part2( input: AOCinput ) -> String {
    let device = WristDevice( assembly: input.lines )
    let argRegister = device.memory[4].b

    device.registers[0] = 1
    //print(device.dump)
    device.setBreakpoint( address: 1, action: { return false } )
    device.run()
    return "\(sumFactors( target: device.registers[argRegister] ))"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part1: part1a, label: "Fast" )
try solve( part2: part2 )
