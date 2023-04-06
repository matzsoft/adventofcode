//
//         FILE: main.swift
//  DESCRIPTION: day04 - Passport Processing
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/23/21 19:46:39
//

import Foundation
import Library

struct Pair {
    let key: String
    let value: String
    
    init( input: String ) {
        let fields = input.split( separator: ":" )
        
        key = String( fields[0] )
        value = String( fields[1] )
    }
}

struct Required {
    let key: String
    let isValid: ( Pair ) -> Bool
}

let requiredFields = [
    Required( key: "byr", isValid: { pair in
        guard let year = Int( pair.value ) else { return false }
        return 1920 <= year && year <= 2002
    } ),
    Required( key: "iyr", isValid: { pair in
        guard let year = Int( pair.value ) else { return false }
        return 2010 <= year && year <= 2020
    } ),
    Required( key: "eyr", isValid: { pair in
        guard let year = Int( pair.value ) else { return false }
        return 2020 <= year && year <= 2030
    } ),
    Required( key: "hgt", isValid: { pair in
        guard let height = Int( pair.value.dropLast( 2 ) ) else { return false }
        if pair.value.hasSuffix( "cm" ) {
            return 150 <= height && height <= 193
        } else if pair.value.hasSuffix( "in" ) {
            return 59 <= height && height <= 76
        } else {
            return false
        }
    } ),
    Required( key: "hcl", isValid: { pair in
        guard pair.value.hasPrefix( "#" ) else { return false }
        guard pair.value.count == 7 else { return false }
        return Int( pair.value.dropFirst(), radix: 16 ) != nil
    } ),
    Required( key: "ecl", isValid: { pair in
        return [ "amb", "blu", "brn", "gry", "grn", "hzl", "oth" ].contains( pair.value )
    } ),
    Required( key: "pid", isValid: { pair in
        guard Int( pair.value ) != nil else { return false }
        return pair.value.count == 9
    } ),
]
let optionalFields = [ "cid" ]

struct Batch {
    let present: Bool
    let valid: Bool
    
    init( lines: [String] ) {
        let pairs = lines.joined( separator: " " ).components( separatedBy: " " ).map { Pair( input: $0 ) }
        var present = true
        var valid = true
        var found = Set<String>()
        
        for pair in pairs {
            if let match = requiredFields.first( where: { $0.key == pair.key } ) {
                found.insert( pair.key )
                valid = valid && match.isValid( pair )
            } else if !optionalFields.contains( pair.key ) {
                present = false
            }
        }
        
        self.present = present && found.count == requiredFields.count
        self.valid = valid
    }
}


func parse( input: AOCinput ) -> [Batch] {
    return input.paragraphs.map { Batch( lines: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let batches = parse( input: input )
    return "\( batches.filter { $0.present }.count )"
}


func part2( input: AOCinput ) -> String {
    let batches = parse( input: input )
    return "\( batches.filter { $0.present && $0.valid }.count )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
