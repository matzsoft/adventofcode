//
//         FILE: main.swift
//  DESCRIPTION: day12 - JSAbacusFramework.io
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/06/21 17:01:55
//

import Foundation

func jsonParse( json: Any ) -> Int {
    if let object = json as? [ String : Any ] {
        if object.values.compactMap( { $0 as? String } ).contains( "red" ) {
            return 0
        } else {
            return object.values.reduce( 0 ) { $0 + jsonParse( json: $1 ) }
        }
    }
    
    if let array = json as? [ Any ] {
        return array.reduce( 0 ) { $0 + jsonParse( json: $1 ) }
    }
    
    if let number = json as? Int {
        return number
    }
    
    // json must be a String, so we just return 0
    return 0
}


func part1( input: AOCinput ) -> String {
    let numbers = input.line.split { !"-0123456789".contains( $0 ) }.map { Int( $0 )! }
    return "\( numbers.reduce( 0, + ) )"
}


func part2( input: AOCinput ) -> String {
    let data = Data( input.line.utf8 )
    let json = try! JSONSerialization.jsonObject( with: data, options: [] )

    return "\( jsonParse( json: json ) )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
