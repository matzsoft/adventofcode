//
//  main.swift
//  day18
//
//  Created by Mark Johnson on 12/17/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

enum Operation: Character {
    case add = "+", multiply = "*"
}

struct State {
    let operation: Operation
    let value: Int
    let fromParen: Bool
    
    init( operation: Operation = .add, value: Int = 0, fromParen: Bool = true ) {
        self.operation = operation
        self.value = value
        self.fromParen = fromParen
    }
    
    func update( value: Int ) -> State {
        switch operation {
        case .add:
            return State( value: self.value + value )
        case .multiply:
            return State( value: self.value * value )
        }
    }
}

struct Expression {
    let terms: String
    
    init( input: Substring ) {
        terms = input.replacingOccurrences( of: " ", with: "" )
    }
}


func evaluate( expression: Expression, part2: Bool = false ) -> Int {
    enum fsaState { case begin, digit }
    var currentState = State()
    var stack = Array<State>()
    var fsa = fsaState.begin
    
    for term in expression.terms {
        switch fsa {
        case .begin:
            if term == "(" {
                stack.append( currentState )
                currentState = State()
            } else if let value = Int( String( term ) ) {
                currentState = currentState.update( value: value )
                fsa = .digit
            } else {
                print( "Invalid \(term) in state \(fsa)" )
            }
        case .digit:
            switch term {
            case ")":
                while !stack.last!.fromParen {
                    currentState = stack.removeLast().update( value: currentState.value )
                }
                currentState = stack.removeLast().update( value: currentState.value )
            case "+":
                currentState = State( operation: Operation( rawValue: term )!, value: currentState.value )
                fsa = .begin
            case "*":
                let operation = Operation( rawValue: term )!
                if !part2 {
                    currentState = State( operation: operation, value: currentState.value )
                } else {
                    stack.append(
                        State( operation: operation, value: currentState.value, fromParen: false )
                    )
                    currentState = State()
                }
                fsa = .begin
            default:
                print( "Invalid \(term) in state \(fsa)" )
            }
        }
    }
    
    while !stack.isEmpty && !stack.last!.fromParen {
        currentState = stack.removeLast().update( value: currentState.value )
    }
    return currentState.value
}


let inputFile = "/Users/markj/Development/adventofcode/2020/input/day18.txt"
let expressions = try String( contentsOfFile: inputFile ).split( separator: "\n" ).map {
    Expression( input: $0 )
}

print( "Part 1: \(expressions.reduce( 0 ) { $0 + evaluate( expression: $1 ) })" )
print( "Part 2: \(expressions.reduce( 0 ) { $0 + evaluate( expression: $1, part2: true ) })" )
