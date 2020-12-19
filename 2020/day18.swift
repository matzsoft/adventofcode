//
//  main.swift
//  day18
//
//  Created by Mark Johnson on 12/17/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

enum Operation: String {
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
    let terms: [Substring]
    
    init( input: Substring ) {
        terms = input.split( separator: " " )
    }
}


func evaluate1( expression: Expression ) -> Int {
    var currentState = State()
    var stack = Array<State>()
    var termIterator = expression.terms.makeIterator()
    
    while var term = termIterator.next() {
        while term.hasPrefix( "(" ) {
            stack.append( currentState )
            currentState = State()
            term = term.dropFirst()
        }
        
        currentState = currentState.update( value: Int( term.filter { $0 != ")" } )! )
        
        while term.hasSuffix( ")" ) {
            currentState = stack.removeLast().update( value: currentState.value )
            term = term.dropLast()
        }
        
        if let term = termIterator.next() {
            let operation = Operation( rawValue: String( term ) )!
            currentState = State( operation: operation, value: currentState.value )
        }
    }
    
    return currentState.value
}


func evaluate2( expression: Expression ) -> Int {
    var currentState = State()
    var stack = Array<State>()
    var termIterator = expression.terms.makeIterator()
    
    while var term = termIterator.next() {
        while term.hasPrefix( "(" ) {
            stack.append( currentState )
            currentState = State()
            term = term.dropFirst()
        }
        
        currentState = currentState.update( value: Int( term.filter { $0 != ")" } )! )
        
        if term.hasSuffix( ")" ) {
            while !stack.isEmpty && !stack.last!.fromParen {
                currentState = stack.removeLast().update( value: currentState.value )
            }
        }
        while term.hasSuffix( ")" ) {
            currentState = stack.removeLast().update( value: currentState.value )
            term = term.dropLast()
        }
        
        if let term = termIterator.next() {
            let operation = Operation( rawValue: String( term ) )!
            
            switch operation {
            case .add:
                currentState = State( operation: operation, value: currentState.value )
            case .multiply:
                stack.append( State( operation: operation, value: currentState.value, fromParen: false ) )
                currentState = State()
            }
        } else {
            while !stack.isEmpty {
                currentState = stack.removeLast().update( value: currentState.value )
            }
        }
    }
    
    return currentState.value
}

let test2 = "((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"
let inputFile = "/Users/markj/Development/adventofcode/2020/input/day18.txt"
let expressions = try String( contentsOfFile: inputFile ).split( separator: "\n" ).map {
    Expression( input: $0 )
}

print( evaluate2( expression: Expression( input: Substring( test2 ) ) ) )
print( "Part 1: \(expressions.reduce( 0 ) { $0 + evaluate1( expression: $1 ) })" )
print( "Part 2: \(expressions.reduce( 0 ) { $0 + evaluate2( expression: $1 ) })" )
