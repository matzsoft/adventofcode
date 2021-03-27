//
//         FILE: main.swift
//  DESCRIPTION: day08 - Two-Factor Authentication
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 03/26/21 23:59:23
//

import Foundation

func makeBlockLetterCode( visual: [String] ) -> Int {
    guard visual.count == 6, visual.allSatisfy( { $0.count == 5 } ) else {
        return 0
    }
    
    return visual.joined().reduce( into: 0, { $0 = ( $0 << 1 ) | ( $1 == " " ? 0 : 1 ) } )
}

struct BlockLetter {
    let letter: Character
    let code: Int
    
    init( letter: Character, visual: [String] ) {
        self.letter = letter
        
        guard visual.count == 6, visual.allSatisfy( { $0.count == 5 } ) else {
            code = 0
            return
        }
        
        code = makeBlockLetterCode( visual: visual )
    }
}

func makeBlockLetterDictionary( blockLetters: [BlockLetter] ) -> [ Int : Character ] {
    return blockLetters.reduce( into: [:], { $0[$1.code] = $1.letter } )
}

let blockLetterDictionary = makeBlockLetterDictionary( blockLetters: [
    BlockLetter( letter: "E", visual: [
        "**** ",
        "*    ",
        "***  ",
        "*    ",
        "*    ",
        "**** ",
    ] ),
    BlockLetter( letter: "O", visual: [
        " **  ",
        "*  * ",
        "*  * ",
        "*  * ",
        "*  * ",
        " **  ",
    ] ),
    BlockLetter( letter: "A", visual: [
        " **  ",
        "*  * ",
        "*  * ",
        "**** ",
        "*  * ",
        "*  * ",
    ] ),
    BlockLetter( letter: "R", visual: [
        "***  ",
        "*  * ",
        "*  * ",
        "***  ",
        "* *  ",
        "*  * ",
    ] ),
    BlockLetter( letter: "G", visual: [
        " **  ",
        "*  * ",
        "*    ",
        "* ** ",
        "*  * ",
        " *** ",
    ] ),
    BlockLetter( letter: "P", visual: [
        "***  ",
        "*  * ",
        "*  * ",
        "***  ",
        "*    ",
        "*    ",
    ] ),
    BlockLetter( letter: "H", visual: [
        "*  * ",
        "*  * ",
        "**** ",
        "*  * ",
        "*  * ",
        "*  * ",
    ] ),
    BlockLetter( letter: "Y", visual: [
        "*   *",
        "*   *",
        " * * ",
        "  *  ",
        "  *  ",
        "  *  ",
    ] ),
] )


struct Screen {
    let width = 50
    let height = 6
    let letterWidth = 5
    let pixels: [[Bool]]
    
    init( lines: [String] ) {
        var screen = Array( repeating: Array( repeating: false, count: 50 ), count: 6 )

        for line in lines {
            let words = line.split( separator: " " )
            
            switch words[0] {
            case "rect":
                let size = words[1].split( separator: "x" )
                
                if size.count != 2 {
                    print( "Invalid input \(words[1])" )
                } else {
                    let ( cols, rows ) = ( Int( size[0] )!, Int( size[1] )! )

                    for row in 0 ..< rows {
                        for col in 0 ..< cols {
                            screen[row][col] = true
                        }
                    }
                }
            case "rotate":
                switch words[1] {
                case "row":
                    let rowRep = words[2].split( separator: "=" )
                    
                    if rowRep.count != 2 {
                        print( "Invalid input \(words[2])" )
                    } else {
                        let row = Int( rowRep[1] )!
                        let amount = Int( words[4] )!
                        let front = Array( screen[row].prefix( screen[row].count - amount ) )
                        let back = Array( screen[row].suffix( amount ) )
                        
                        screen[row] = back
                        screen[row].append( contentsOf: front )
                    }
                case "column":
                    let colRep = words[2].split( separator: "=" )
                    
                    if colRep.count != 2 {
                        print( "Invalid input \(words[2])" )
                    } else {
                        let col = Int( colRep[1] )!
                        let amount = Int( words[4] )!
                        let breakpoint = screen.count - amount
                        var newCol: [Bool] = []

                        for i in breakpoint ..< screen.count {
                            newCol.append( screen[i][col] )
                        }
                        for i in 0 ..< breakpoint {
                            newCol.append( screen[i][col] )
                        }
                        for i in 0 ..< screen.count {
                            screen[i][col] = newCol[i]
                        }
                    }
                default:
                    print( "Invalid input \(words[1])" )
                }
            default:
                print( "Invalid input \(words[0])" )
            }
        }
        pixels = screen
    }
    
    var letters: [[String]] {
        var result = [[String]]()
        
        for x in stride( from: 0, to: pixels[0].count, by: letterWidth ) {
            var letter = [String]()
            
            for y in 0 ..< pixels.count {
                letter.append( pixels[y][x..<x+letterWidth].map { $0 ? "*" : " " }.joined() )
            }
            result.append( letter )
        }
        
        return result
    }
}


func parse( input: AOCinput ) -> Screen {
    return Screen( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    let screen = parse( input: input )
    return "\(screen.pixels.flatMap{ $0 }.reduce( 0, { $0 + ( $1 ? 1 : 0 ) } ) )"
}


func part2( input: AOCinput ) -> String {
    let screen = parse( input: input )
    let answer = screen.letters.map { blockLetterDictionary[ makeBlockLetterCode(visual: $0 ) ] ?? "?" }
    return "\(String(answer))"
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
