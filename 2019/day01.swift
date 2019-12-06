//
//  main.swift
//  day01
//
//  Created by Mark Johnson on 11/30/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let inputFile = "/Users/markj/Development/adventofcode/2019/input/day01.txt"
let modules = try String( contentsOfFile: inputFile ).split( separator: "\n" ).map { Int($0)! }

func fuel( mass: Int ) -> Int {
    var total = 0
    var current = mass
    
    while true {
        let next = current / 3 - 2
        
        guard next > 0 else { break }
        total += next
        current = next
    }
    
    return total
}


var bareFuel = 0
var totalFuel = 0

for module in modules {
    bareFuel += module / 3 - 2
    totalFuel += fuel( mass: module )
}
print( "Part 1: \(bareFuel)" )
print( "Part 2: \(totalFuel)" )
