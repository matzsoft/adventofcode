//
//  Glob.swift
//
//  Created by Mark Johnson on 03/02/21.
//  Copyright © 2021 matzsoft. All rights reserved.
//
// I adapted this from an article by Brad Grzesiak at
// (https://bendyworks.com/blog/using-linux-c-apis-in-swift-glob)
// I made mine a function instead of a class.

import Foundation

public func glob( pattern: String ) -> [String] {
    let globFlags = GLOB_TILDE | GLOB_BRACE | GLOB_MARK
    var globObj = glob_t()
    
    defer { globfree( &globObj ) }

    if let cPattern = pattern.cString( using: String.Encoding.utf8 ) {
        if glob( cPattern, globFlags, nil, &globObj ) == 0 {
            return ( 0 ..< Int( globObj.gl_matchc ) ).compactMap {
                return globObj.gl_pathv[$0] == nil ? nil : String( cString: globObj.gl_pathv[$0]! )
            }
        }
    }
    return []
}
