//
//  main.swift
//  day04
//
//  Created by Mark Johnson on 12/3/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let inputFile = "/Users/markj/Development/adventofcode/2019/input/day04.txt"
let wires = try String( contentsOfFile: inputFile ).split( separator: "\n" ).map { Int( $0 ) }
