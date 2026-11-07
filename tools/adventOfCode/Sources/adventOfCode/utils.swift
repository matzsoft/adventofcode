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


func getModificationDate( atPath path: String ) throws -> Date {
    let attributes = try FileManager.default.attributesOfItem( atPath: path )
    guard let date = attributes[.modificationDate] as? Date else { throw RuntimeError( "Error getting file attributes" ) }
    return date
}


struct Result: Codable {
    enum Test: Int, Codable { case none, good, bad }
    
    let name:   String
    let part1:  String?
    let part2:  String?
    let tests1: Test
    let tests2: Test
    
    init( solution: String ) {
        let lines = solution.split( separator: "\n" ).map { String( $0 ) }
        
        func part( n: Int ) -> String? {
            guard let line = lines.first( where: { $0.hasPrefix( "Part\(n): " ) } ) else { return nil }
            guard line.contains( "Correct!" ) else { return nil }
            let words = line.split( separator: /[ ()]+/ )
            guard let time = words.last else { return nil }
            return String( time )
        }
        
        func test( n: Int ) -> Test {
            guard let line = lines.first( where: { $0.contains( "Part\(n) tests ran successfully " ) } ) else { return .bad }
            let words = line.split( separator: " " )
            if words[0] != words[2] { return .bad }
            else if words[0] == "0" { return .none }
            return .good
        }
        
        name   = {
            return String( lines[0].split( separator: /[ ,]+/ )[4] )
        }()
        part1  = part( n: 1 )
        part2  = part( n: 2 )
        tests1 = test( n: 1 )
        tests2 = test( n: 2 )
     }
}
