//
//         FILE: main.swift
//  DESCRIPTION: day07 - detecting IPV7 protocol support
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 03/25/21 20:33:58
//

import Foundation

class IPv7 {
    enum ParsingError: Error {
        case noOpenBracket, nestedHyperet, emptyHypernet, noCloseBracket, internalError
    }
    let supernets: [Substring]
    let hypernets: [Substring]
    
    init( line: String ) throws {
        enum State { case supernet, emptyHypernet, hypernet }
        var superList: [Substring] = []
        var hyperList: [Substring] = []
        let tokens = line.tokenize( delimiters: "[]" )
        var state = State.supernet
        
        for token in tokens {
            switch state {
            case .supernet:
                switch token {
                case "[":
                    state = .emptyHypernet
                case "]":
                    throw ParsingError.noOpenBracket
                default:
                    superList.append( token )
                }
            case .emptyHypernet:
                switch token {
                case "[":
                    throw ParsingError.nestedHyperet
                case "]":
                    throw ParsingError.emptyHypernet
                default:
                    hyperList.append( token )
                    state = .hypernet
                }
            case .hypernet:
                switch token {
                case "[":
                    throw ParsingError.nestedHyperet
                case "]":
                    state = .supernet
                default:
                    throw ParsingError.internalError
                }
            }
        }
        switch state {
        case .supernet:
            break
        case .emptyHypernet:
            throw ParsingError.noCloseBracket
        case .hypernet:
            throw ParsingError.noCloseBracket
        }

        supernets = superList
        hypernets = hyperList
    }
    
    static func containsABBA( region: Substring ) -> Bool {
        enum State { case Initial, A, AB, ABB }
        
        var state = State.Initial
        var alpha1 = Character(" ")
        var alpha2 = Character(" ")
        
        for char in region {
            switch state {
            case .Initial:
                alpha1 = char
                state = .A
            case .A:
                switch char {
                case alpha1:
                    break
                default:
                    alpha2 = char
                    state = .AB
                }
            case .AB:
                switch char {
                case alpha2:
                    state = .ABB
                default:
                    ( alpha1, alpha2 ) = ( alpha2, char )
                }
            case .ABB:
                switch char {
                case alpha1:
                    return true
                case alpha2:
                    alpha1 = char
                    state = .A
                default:
                    ( alpha1, alpha2 ) = ( alpha2, char )
                    state = .AB
                }
            }
        }
        
        return false
    }
    
    static func listOfABA( region: Substring ) -> [[Character]] {
        enum State { case Initial, A, AB }
        
        var state = State.Initial
        var alpha1 = Character(" ")
        var alpha2 = Character(" ")
        var list: [[Character]] = []

        for char in region {
            switch state {
            case .Initial:
                alpha1 = char
                state = .A
            case .A:
                switch char {
                case alpha1:
                    break
                default:
                    alpha2 = char
                    state = .AB
                }
            case .AB:
                switch char {
                case alpha1:
                    list.append( [ alpha1, alpha2 ] )
                    ( alpha1, alpha2 ) = ( alpha2, char )
                case alpha2:
                    alpha1 = char
                    state = .A
                default:
                    ( alpha1, alpha2 ) = ( alpha2, char )
                }
            }
        }
        
        return list
    }
    
    var supportsTLS: Bool {
        if hypernets.contains( where: { IPv7.containsABBA( region: $0 ) } ) { return false }
        
        return supernets.contains( where: { IPv7.containsABBA( region: $0 ) } )
    }

    var supportsSSL: Bool {
        var list: [[Character]] = []
        
        for net in supernets {
            list.append( contentsOf: IPv7.listOfABA( region: net ) )
        }
        
        for element in list {
            let bab = String( element[1] ) + String( element[0] ) + String( element[1] )
            
            if hypernets.contains( where: { $0.contains(bab) } ) { return true }
        }
        
        return false
    }
}


func parse( input: AOCinput ) -> [IPv7] {
    return input.lines.map { try! IPv7( line: $0 ) }
}


func part1( input: AOCinput ) -> String {
    return "\(parse( input: input ).filter { $0.supportsTLS }.count)"
}


func part2( input: AOCinput ) -> String {
    return "\(parse( input: input ).filter { $0.supportsSSL }.count)"
}

try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
