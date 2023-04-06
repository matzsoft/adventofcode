//
//         FILE: main.swift
//  DESCRIPTION: day18 - Operation Order
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/29/21 13:13:44
//

import Foundation
import Library

enum Operation: Character { case add = "+", multiply = "*", leftParen = "(", rightParen = ")" }

struct Operator {
    let type: Operation
    let precedence: Int
}


func evaluate( expression: String, precedence: [ Operation : Operator ] ) throws -> Int {
    var valueStack: [Int] = []
    var operatorStack: [Operator] = []
    
    func apply( op: Operator ) throws -> Void {
        let value2 = valueStack.removeLast()
        let value1 = valueStack.removeLast()
        
        switch op.type {
        case .add:
            valueStack.append( value1 + value2 )
        case .multiply:
            valueStack.append( value1 * value2 )
        default:
            throw RuntimeError( "Tried to apply bad operator \"\(op.type)\"." )
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
                        try apply( op: top )
                    }
                }
            default:
                guard let op = precedence[operation] else {
                    throw RuntimeError( "No precedence for \(term)" )
                }
                while let top = operatorStack.last, top.precedence >= op.precedence {
                    try apply( op: operatorStack.removeLast() )
                }
                operatorStack.append( op )
            }
        } else {
            guard let value = Int( String( term ) ) else {
                throw RuntimeError( "Unrecognized character: \"\(term)\"." )
            }
            valueStack.append( value )
        }
    }
    
    while let top = operatorStack.last {
        operatorStack.removeLast( 1 )
        try apply( op: top )
    }
    return valueStack.first!
}


func parse( input: AOCinput ) -> [String] {
    return input.lines.map { $0.replacingOccurrences( of: " ", with: "" ) }
}


func part1( input: AOCinput ) -> String {
    let expressions = parse( input: input )
    let precedence = [
        Operation.add : Operator( type: Operation.add, precedence: 1 ),
        Operation.multiply : Operator( type: Operation.multiply, precedence: 1 ),
        Operation.leftParen : Operator( type: Operation.leftParen, precedence: Int.min )
    ]
    
    return "\( expressions.reduce( 0 ) { try! $0 + evaluate( expression: $1, precedence: precedence ) } )"
}


func part2( input: AOCinput ) -> String {
    let expressions = parse( input: input )
    let precedence = [
        Operation.add : Operator( type: Operation.add, precedence: 2 ),
        Operation.multiply : Operator( type: Operation.multiply, precedence: 1 ),
        Operation.leftParen : Operator( type: Operation.leftParen, precedence: Int.min )
    ]
    
    return "\( expressions.reduce( 0 ) { try! $0 + evaluate( expression: $1, precedence: precedence ) } )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
