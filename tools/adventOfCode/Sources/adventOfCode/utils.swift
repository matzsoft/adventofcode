//
//  utils.swift
//  Functions used by multiple other files
//
//  Created by Mark Johnson on 3/30/23.
//  Copyright © 2023 matzsoft. All rights reserved.
//

import Foundation
import ArgumentParser
import MATZMiscSwiftLibrary

func determinePackage( package: String ) throws -> ( Int, Int, String ) {
    let fileManager = FileManager.default
    let currentDirectory = fileManager.currentDirectoryPath
    let year = URL( fileURLWithPath: currentDirectory ).lastPathComponent
    guard let year = Int( year ) else { throw RuntimeError( "Invalid year: \(year)" ) }

    let currentYear = Calendar.current.component( .year, from: Date() )
    guard 2015 <= year && year <= currentYear else { throw RuntimeError( "Invalid year: \(year)" ) }
    
    guard let url = URL( string: package ) else { throw RuntimeError( "Invalid package: \(package)" ) }
    var newPackage = url.deletingPathExtension().lastPathComponent

    if newPackage.hasPrefix( "day" ) { newPackage = String( newPackage.dropFirst( 3 ) ) }
    if newPackage.hasPrefix( "-" ) { throw RuntimeError( "Invalid package: \(package)" ) }
    if newPackage.hasSuffix( "-" ) { throw RuntimeError( "Invalid package: \(package)" ) }

    let splits = newPackage.split( separator: "-" )
    if splits.isEmpty { throw RuntimeError( "Invalid package: \(package)" ) }
    
    guard let day = Int( splits[0] ) else { throw RuntimeError( "Invalid package: \(package)" ) }
    let maxDay = year < 2025 ? 25 : 12
    guard 0 < day && day <= maxDay else { throw RuntimeError( "Invalid day: \(day)" ) }
    
    let base = [ String( format: "day%02d", day ) ]
    let suffix = splits.dropFirst().map { String( $0 ) }
    newPackage = ( base + suffix ).joined( separator: "-" )
    
    return ( year, day, newPackage )
}
