//
//         FILE: main.swift
//  DESCRIPTION: day21 - Monkey Math
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/20/22 21:34:45
//

import Foundation

extension Double {
    func signum() -> Double {
        if self < 0 { return -1 }
        if self > 0 { return 1 }
        return self
    }
}


class Monkey {
    enum MonkeyType { case number, math }
    enum OperationType: String { case add = "+", subtract = "-", multiply = "*", divide = "/" }
    
    let name: String
    let monkeyType: MonkeyType
    var value: Double
    let operationType: OperationType
    let left: String
    let right: String
    
    init( line: String ) {
        let words = line.split( whereSeparator: { ": ".contains( $0 ) } ).map { String( $0 ) }
        
        name = words[0]
        switch words.count {
        case 2:
            monkeyType = .number
            value = Double( words[1] )!
            operationType = .add
            left = ""
            right = ""
        case 4:
            monkeyType = .math
            value = 0
            operationType = OperationType( rawValue: words[2] )!
            left = words[1]
            right = words[3]
        default:
            fatalError( "Parse error: \(line)" )
        }
    }
    
    init( name: String, value: Double ) {
        self.name = name
        monkeyType = .number
        self.value = value
        operationType = .add
        left = ""
        right = ""
    }
    
    func value( monkeys: [ String : Monkey ] ) -> Double {
        switch monkeyType {
        case .number:
            break
        case .math:
            let leftSide = monkeys[left]!.value( monkeys: monkeys )
            let rightSide = monkeys[right]!.value( monkeys: monkeys )
            switch operationType {
            case .add:
                value = leftSide + rightSide
            case .subtract:
                value = leftSide - rightSide
            case .multiply:
                value = leftSide * rightSide
            case .divide:
                value = leftSide / rightSide
            }
        }
        return value
    }
}

class Monkeys {
    var monkeys: [ String : Monkey ]
    
    init( monkeys: [ String : Monkey ] ) {
        self.monkeys = monkeys
    }
    
    func evaluate( human: Int ) -> Node {
        monkeys["humn"] = Monkey( name: "humn", value: Double(human) )
        
        let root = monkeys["root"]!
        _ = root.value( monkeys: monkeys )

        return Node( human: human, result: monkeys[root.left]!.value - monkeys[root.right]!.value )
    }
}


func parse( input: AOCinput ) -> Monkeys {
    let monkeys = input.lines.reduce( into: [ String : Monkey ]() ) { dict, line in
        let monkey = Monkey( line: line )
        dict[monkey.name] = monkey
    }
    return Monkeys( monkeys: monkeys )
}


func part1( input: AOCinput ) -> String {
    let monkeys = parse( input: input )
    return "\( Int( monkeys.monkeys["root"]!.value( monkeys: monkeys.monkeys ) ) )"
}


struct Node {
    let human: Int
    let result: Double
}


func part2( input: AOCinput ) -> String {
    let monkeys = parse( input: input )
    var high = monkeys.evaluate( human: 1000000000000000 )
    var low  = monkeys.evaluate( human: -high.human )
    assert( low.result.signum() != high.result.signum(), "Assumption failure" )
    
    while low.human < high.human {
        let middle = monkeys.evaluate( human: ( high.human + low.human ) / 2 )
        
        if middle.result == 0 { return "\(middle.human)" }
        if middle.result.signum() == low.result.signum() {
            low = middle
        } else {
            high = middle
        }
    }
    return "No solution"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
