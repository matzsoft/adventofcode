//
//  BlockLetter.swift
//  day08
//
//  Created by Mark Johnson on 5/16/21.
//

import Foundation

struct BlockLetter {
    let letter: Character
    let code: Int
    
    init( letter: Character, visual: [String] ) {
        self.letter = letter
        code = BlockLetter.makeBlockLetterCode( visual: visual )
    }
    
    static func makeBlockLetterCode( visual: [String] ) -> Int {
        return visual.joined().reduce( into: 0, { $0 = ( $0 << 1 ) | ( $1 == " " ? 0 : 1 ) } )
    }

}

struct BlockLetterDictionary {
    let width: Int
    let height: Int
    let hSpacing: Int
    let dictionary: [ Int: Character ]

    init( from file: String ) throws {
        let inputDirectory = try findDirectory( name: "tools" )
        let path = "\(inputDirectory)/figlet/\(file)"
        let contents = try String( contentsOfFile: path )
        let paragraphs = contents.components( separatedBy: "\n\n" )
        let headerLines = paragraphs[0].split( separator: "\n" )
        let words = headerLines[0].split( whereSeparator: { "  x+".contains( $0 ) } )
        
        width = Int( words[0] )!
        height = Int( words[1] )!
        hSpacing = Int( words[2] )!
        
        let keys = Array( headerLines[1] )
        let letters = paragraphs[1...].map { $0.split( separator: "\n" ).map { String( $0 ) } }

        guard keys.count == letters.count else {
            throw RuntimeError( "Letter keys don't match letters count" )
        }
        
        dictionary = zip( keys, letters ).reduce( into: [:] ) {
            let blockLetter = BlockLetter( letter: $1.0, visual: $1.1 )
            $0[blockLetter.code] = blockLetter.letter
        }
    }
    
    func makeString( screen: [[Bool]] ) -> String {
        guard screen.count == height else { return "Bad Height" }
        guard screen.allSatisfy( { $0.count == screen[0].count } ) else { return "Inconsistent Widths" }
        
        let letterCount = ( screen[0].count + hSpacing ) / ( width + hSpacing )
        var letters = Array( repeating: 0, count: letterCount )
        
        for line in screen {
            for letter in 0 ..< letterCount {
                let start = letter * ( width + hSpacing )
                let stop = start + width
                
                for pixel in line[ start ..< stop ] {
                    letters[letter] = ( letters[letter] << 1 ) | ( pixel ? 1 : 0 )
                }
            }
        }
        
        return String( letters.map { dictionary[$0] ?? "?" } )
    }
}
