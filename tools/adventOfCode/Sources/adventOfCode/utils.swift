//
//  utils.swift
//  Functions used by multiple other files
//
//  Created by Mark Johnson on 3/30/23.
//  Copyright © 2023 matzsoft. All rights reserved.
//

import Foundation
import ArgumentParser

func determinePackage( package: String ) -> String? {
    guard let url = URL( string: package ) else { return nil }
    var package = url.deletingPathExtension().lastPathComponent

    if package.hasPrefix( "day" ) { package = String( package.dropFirst( 3 ) ) }
    if package.hasPrefix( "-" ) { return nil }
    if package.hasSuffix( "-" ) { return nil }

    let splits = package.split( separator: "-" )
    if splits.isEmpty { return nil }
    
    guard let value = Int( splits[0] ) else { return nil }
    guard value < 26 else { return nil }
    
    let base = [ String( format: "day%02d", value ) ]
    let suffix = splits.dropFirst().map { String( $0 ) }
    return ( base + suffix ).joined( separator: "-" )
}
