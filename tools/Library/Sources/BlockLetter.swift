//
//  BlockLetter.swift
//  day08
//
//  Created by Mark Johnson on 5/16/21.
//

import Foundation

struct BlockLetter {
    let code: Int
    let width: Int
    let height: Int
    
    init( visual: String ) throws {
        let visual = visual.split( separator: "\n" )
        guard visual.allSatisfy( { $0.count == visual[0].count } ) else {
            throw RuntimeError( "Inconsistent widths in BlockLetter definition." )
        }
        
        width = visual[0].count
        height = visual.count
        code = visual.joined().reduce( into: 0, { $0 = ( $0 << 1 ) | ( $1 == " " ? 0 : 1 ) } )
    }
}

public struct BlockLetterDictionary {
    let width: Int
    let height: Int
    let hSpacing: Int
    let dictionary: [ Int: Character ]

    public init( from file: String ) throws {
        let inputDirectory = try findDirectory( name: "tools" )
        let path           = "\(inputDirectory)/figlet/\(file)"
        let contents       = try String( contentsOfFile: path )
        let paragraphs     = contents.components( separatedBy: "\n\n" )
        let headerLines    = paragraphs[0].split( separator: "\n" )
        let words          = headerLines[0].split( whereSeparator: { "  x+".contains( $0 ) } )
        let width          = Int( words[0] )!
        let height         = Int( words[1] )!
        let hSpacing       = Int( words[2] )!
        let keys           = Array( headerLines[1] )
        let letters        = try paragraphs[1...].map { try BlockLetter( visual: $0 ) }

        guard keys.count == letters.count else {
            throw RuntimeError( "Letter keys don't match letters count" )
        }
        guard letters.allSatisfy( { $0.width == width } ) else {
            throw RuntimeError( "Inconsistent widths in BlockLetterDictionary definition." )
        }
        guard letters.allSatisfy( { $0.height == height } ) else {
            throw RuntimeError( "Inconsistent heights in BlockLetterDictionary definition." )
        }

        self.width = width
        self.height = height
        self.hSpacing = hSpacing
        dictionary = Dictionary( uniqueKeysWithValues: zip( letters.map { $0.code }, keys ) )
    }
    
    public func makeString( screen: [[Bool]] ) -> String {
        guard screen.count == height else { return "Bad Height" }
        guard screen.allSatisfy( { $0.count == screen[0].count } ) else { return "Inconsistent Widths" }
        
        let letterCount = ( screen[0].count + hSpacing ) / ( width + hSpacing )
        var letters = Array( repeating: 0, count: letterCount )
        
        for line in screen {
            for index in 0 ..< letterCount {
                let start = index * ( width + hSpacing )
                let stop = start + width
                
                for pixel in line[ start ..< stop ] {
                    letters[index] = ( letters[index] << 1 ) | ( pixel ? 1 : 0 )
                }
            }
        }
        
        return String( letters.map { dictionary[$0] ?? "?" } )
    }
}
