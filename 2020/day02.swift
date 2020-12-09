//
//  main.swift
//  day02
//
//  Created by Mark Johnson on 12/04/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

let inputFile = "/Users/markj/Development/adventofcode/2020/input/day02.txt"
let lines = try String( contentsOfFile: inputFile ).split( separator: "\n" )
var oldValidCount = 0
var newValidCount = 0

for line in lines {
    let fields   = line.split( whereSeparator: { "- :".contains( $0 ) } )
    let least    = Int( fields[0] )!
    let most     = Int( fields[1] )!
    let letter   = Character( String( fields[2] ) )
    let password = String( fields[3] )
    let count    = password.reduce( 0 ) { $0 + ( $1 == letter ? 1 : 0 ) }

    if least <= count && count <= most {
        oldValidCount += 1
    }
    
    let index1 = password.index( password.startIndex, offsetBy: least - 1 )
    let index2 = password.index( password.startIndex, offsetBy: most - 1 )
    let condition1 = ( password[index1] == letter ) ? 1 : 0
    let condition2 = ( password[index2] == letter ) ? 1 : 0
    if ( condition1 ^ condition2 ) == 1 {
        newValidCount += 1
    }
}

print( "Part 1: \(oldValidCount)" )
print( "Part 2: \(newValidCount)" )
