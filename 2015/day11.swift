//
//         FILE: main.swift
//  DESCRIPTION: day11 - Corporate Policy
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/06/21 12:32:00
//

import Foundation

let alphabet = ( UnicodeScalar( "a" ).value ... UnicodeScalar( "z" ).value ).map {
    Character( UnicodeScalar( $0 )! )
}
let alphabetNext = ( 0 ..< alphabet.count - 1 ).reduce(into: [ Character : Character ]() ) {
    $0[ alphabet[$1] ] = alphabet[ $1 + 1 ]
}


func has2pairs( candidate: [Character] ) -> Bool {
    enum State { case initial, first, got1, second, final }
    
    var state = State.initial
    var first = Character( "#" )
    var second = Character( "#" )

    for character in candidate {
        switch state {
        case .initial:
            first = character
            state = .first
        case .first:
            if character == first {
                state = .got1
            }
            first = character
        case .got1:
            if character != first {
                second = character
                state = .second
            }
        case .second:
            if character == second {
                state = .final
            }
            if character == first {
                state = .got1
            }
            second = character
        case .final:
            break
        }
    }
    
    return state == .final
}

func has3consecutive( candidate: [Character] ) -> Bool {
    enum State { case initial, got1, got2, final }
    
    var state = State.initial
    var got = Character( "#" )

    for character in candidate {
        switch state {
        case .initial:
            got = character
            state = .got1
        case .got1:
            if character == alphabetNext[got] {
                state = .got2
            }
            got = character
        case .got2:
            if character == alphabetNext[got] {
                state = .final
            } else {
                got = character
                state = .got1
            }
        case .final:
            break
        }
    }
    
    return state == .final
}


func nextPassword( last: String ) -> String {
    var next = Array( last )
    
    while true {
        for index in ( 0 ..< next.count ).reversed() {
            next[index] = alphabetNext[ next[index] ] ?? alphabet[0]
            if next[index] != alphabet[0] { break }
        }
        
        if let index = next.firstIndex( where: { "iol".contains( $0 ) } ) {
            next[index] = alphabetNext[ next[index] ]!
            ( index + 1 ..< next.count ).forEach { next[$0] = alphabet[0] }
        }
        
        if has3consecutive( candidate: next ) && has2pairs( candidate: next ) { break }
    }
    
    return String( next )
}


func parse( input: AOCinput ) -> Any? {
    return nil
}


func part1( input: AOCinput ) -> String {
    let result = nextPassword( last: input.line )
    return "\(result)"
}


func part2( input: AOCinput ) -> String {
    let first = nextPassword( last: input.line )
    let second = nextPassword( last: first )
    return "\(second)"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
