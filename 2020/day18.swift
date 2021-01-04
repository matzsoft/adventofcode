//
//  main.swift
//  day18
//
//  Created by Mark Johnson on 12/17/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

enum Operation: Character {
    case add = "+", multiply = "*", leftParen = "(", rightParen = ")"
}

struct Operator {
    let type: Operation
    let precedence: Int
}

func evaluate( expression: String, precedence: [ Operation : Operator ] ) -> Int {
    var valueStack: [Int] = []
    var operatorStack: [Operator] = []
    
    func apply( op: Operator ) -> Void {
        let value2 = valueStack.removeLast()
        let value1 = valueStack.removeLast()
        
        switch op.type {
        case .add:
            valueStack.append( value1 + value2 )
        case .multiply:
            valueStack.append( value1 * value2 )
        default:
            print( "Tried to apply bad operator \"\(op.type)\"." )
        }
    }
    
    for term in expression {
        if let operation = Operation( rawValue: term ) {
            switch operation {
            case .leftParen:
                operatorStack.append( precedence[operation]! )
            case .rightParen:
                while let top = operatorStack.last {
                    operatorStack.removeLast( 1 )
                    if top.type == .leftParen {
                        break
                    } else {
                        apply( op: top )
                    }
                }
            default:
                guard let op = precedence[operation] else { print( "No precedence for \(term)" ); exit( 0 ) }
                while let top = operatorStack.last, top.precedence >= op.precedence {
                    apply( op: operatorStack.removeLast() )
                }
                operatorStack.append( op )
            }
        } else {
            guard let value = Int( String( term ) ) else {
                print( "Unrecognized character: \"\(term)\"." )
                exit( 0 )
            }
            valueStack.append( value )
        }
    }
    
    while let top = operatorStack.last {
        operatorStack.removeLast( 1 )
        apply( op: top )
    }
    return valueStack.first!
}

let part1 = [
    Operation.add : Operator( type: Operation.add, precedence: 1 ),
    Operation.multiply : Operator( type: Operation.multiply, precedence: 1 ),
    Operation.leftParen : Operator( type: Operation.leftParen, precedence: Int.min )
]
let part2 = [
    Operation.add : Operator( type: Operation.add, precedence: 2 ),
    Operation.multiply : Operator( type: Operation.multiply, precedence: 1 ),
    Operation.leftParen : Operator( type: Operation.leftParen, precedence: Int.min )
]
let inputFile = "/Users/markj/Development/adventofcode/2020/input/day18.txt"
let expressions = try String( contentsOfFile: inputFile ).split( separator: "\n" ).map {
    $0.replacingOccurrences( of: " ", with: "" )
}

print( "Part 1: \(expressions.reduce( 0 ) { $0 + evaluate( expression: $1, precedence: part1 ) })" )
print( "Part 2: \(expressions.reduce( 0 ) { $0 + evaluate( expression: $1, precedence: part2 ) })" )
