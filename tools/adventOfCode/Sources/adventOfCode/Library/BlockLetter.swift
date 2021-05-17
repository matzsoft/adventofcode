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

    init( width: Int, height: Int, hSpacing: Int, blockLetters: [BlockLetter] ) {
        self.width = width
        self.height = height
        self.hSpacing = hSpacing
        self.dictionary = blockLetters.reduce( into: [:], { $0[$1.code] = $1.letter } )
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

let blockLettersDictionary5x6x0 = BlockLetterDictionary(
    width: 5, height: 6, hSpacing: 0, blockLetters: [
        BlockLetter( letter: "A", visual: [
            " **  ",
            "*  * ",
            "*  * ",
            "**** ",
            "*  * ",
            "*  * ",
        ] ),
        BlockLetter( letter: "B", visual: [
            "###  ",
            "#  # ",
            "###  ",
            "#  # ",
            "#  # ",
            "###  ",
        ] ),
        BlockLetter( letter: "C", visual: [
            " ##  ",
            "#  # ",
            "#    ",
            "#    ",
            "#  # ",
            " ##  ",
        ] ),
        BlockLetter( letter: "E", visual: [
            "**** ",
            "*    ",
            "***  ",
            "*    ",
            "*    ",
            "**** ",
        ] ),
        BlockLetter( letter: "F", visual: [
            "#### ",
            "#    ",
            "###  ",
            "#    ",
            "#    ",
            "#    ",
        ] ),
        BlockLetter( letter: "G", visual: [
            " **  ",
            "*  * ",
            "*    ",
            "* ** ",
            "*  * ",
            " *** ",
        ] ),
        BlockLetter( letter: "H", visual: [
            "*  * ",
            "*  * ",
            "**** ",
            "*  * ",
            "*  * ",
            "*  * ",
        ] ),
        BlockLetter( letter: "J", visual: [
            "  ## ",
            "   # ",
            "   # ",
            "   # ",
            "#  # ",
            " ##  ",
        ] ),
        BlockLetter( letter: "L", visual: [
            "#    ",
            "#    ",
            "#    ",
            "#    ",
            "#    ",
            "#### ",
        ] ),
        BlockLetter( letter: "O", visual: [
            " **  ",
            "*  * ",
            "*  * ",
            "*  * ",
            "*  * ",
            " **  ",
        ] ),
        BlockLetter( letter: "P", visual: [
            "***  ",
            "*  * ",
            "*  * ",
            "***  ",
            "*    ",
            "*    ",
        ] ),
        BlockLetter( letter: "R", visual: [
            "***  ",
            "*  * ",
            "*  * ",
            "***  ",
            "* *  ",
            "*  * ",
        ] ),
        BlockLetter( letter: "U", visual: [
            "#  # ",
            "#  # ",
            "#  # ",
            "#  # ",
            "#  # ",
            " ##  ",
        ] ),
        BlockLetter( letter: "Y", visual: [
            "*   *",
            "*   *",
            " * * ",
            "  *  ",
            "  *  ",
            "  *  ",
        ] ),
        BlockLetter( letter: "Z", visual: [
            "#### ",
            "   # ",
            "  #  ",
            " #   ",
            "#    ",
            "#### ",
        ] ),
    ]
)
