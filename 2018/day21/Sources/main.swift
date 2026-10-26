//
//         FILE: main.swift
//  DESCRIPTION: day21 - Chronal Conversion
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/28/21 18:37:55
//

import Foundation
import Library

class Emulator {
    let initial: Int
    var result = 0
    var limiter = 0
    
    init( device: WristDevice ) {
        initial = device.memory[7].a
    }
    
    var produce: Int {
        limiter = result | 0x10000
        result = initial
        repeat {
            result = ( result + ( limiter & 0xFF ) ) & 0xFFFFFF
            result = ( result * 65899 ) & 0xFFFFFF
            
            if limiter < 256 { break }
            limiter = limiter / 256
        } while true
        return result
    }
}


func part1( input: AOCinput ) -> String {
    let device = WristDevice( assembly: input.lines )
    let targetRegister = device.memory[28].a
    var first = 0
    
    device.setBreakpoint( address: 28, action: { first = device.registers[targetRegister]; return false } )
    device.run()
    return "\(first)"
}


func part1e( input: AOCinput ) -> String {
    let device = WristDevice( assembly: input.lines )
    let emulator = Emulator( device: device )
    
    return "\(emulator.produce)"
}


func part2( input: AOCinput ) -> String {
    let device = WristDevice( assembly: input.lines )
    let targetRegister = device.memory[28].a
    var seen = Set<Int>()
    var last = 0
    
    //print(device.dump)
    device.setBreakpoint( address: 28, action: {
        if !seen.insert( device.registers[targetRegister] ).inserted { return false }

        last = device.registers[targetRegister]
        return true
    } )
    device.run()
    return "\(last)"
}


func part2e( input: AOCinput ) -> String {
    let device = WristDevice( assembly: input.lines )
    let emulator = Emulator( device: device )
    var seen = Set<Int>()
    var last = 0

    while true {
        let value = emulator.produce
        
        if seen.insert( value ).inserted {
            last = value
        } else {
            break
        }
    }
    return "\(last)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2e, label: "Emulator" )
try solve( part1: part1 )
try solve( part1: part1e, label: "Emulator" )
try solve( part2: part2e, label: "Emulator" )
//try solve( part2: part2 )      // Takes 27 minutes to run.
