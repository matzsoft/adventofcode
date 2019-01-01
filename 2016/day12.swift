//
//  main.swift
//  day12
//
//  Created by Mark Johnson on 12/31/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

let test1 = """
cpy 41 a
inc a
inc a
dec a
jnz a 2
dec a
"""
let input = """
cpy 1 a
cpy 1 b
cpy 26 d
jnz c 2
jnz 1 5
cpy 7 c
inc d
dec c
jnz c -2
cpy a c
inc a
dec b
jnz b -2
cpy c b
dec d
jnz d -6
cpy 18 c
cpy 11 d
inc a
dec d
jnz d -2
dec c
jnz c -5
"""

func execute( a:Int, b: Int, c: Int, d: Int ) -> Int {
    var a = a
    var b = b
    var c = c
    var d = d
    
    a = 1
    b = 1
    d = 26
    if c != 0 { d += 7 }
    for _ in 1 ... d {
        c = a
        a += b
        b = c
    }
    a += 198
    
    return a
}

let lines = input.split(separator: "\n")
lines.enumerated().forEach { print( "\($0.0):", $0.1 ) }


print( "Part1:", execute(a: 0, b: 0, c: 0, d: 0) )
print( "Part2:", execute(a: 0, b: 0, c: 1, d: 0) )
