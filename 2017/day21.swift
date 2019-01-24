//
//  main.swift
//  day21
//
//  Created by Mark Johnson on 1/21/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let initial = ".#./..#/###"
let testInput = """
../.# => ##./#../...
.#./..#/### => #..#/..../..../#..#
"""
let input = """
../.. => .#./###/##.
#./.. => ..#/.#./#.#
##/.. => ###/#../...
.#/#. => .#./..#/##.
##/#. => ..#/#.#/###
##/## => .##/.##/.#.
.../.../... => #.#./..##/##../###.
#../.../... => .###/.##./.##./....
.#./.../... => ####/..../..../.#.#
##./.../... => #.../#..#/#.../###.
#.#/.../... => ..##/###./..#./.#..
###/.../... => #.../#.#./..#./#.#.
.#./#../... => #.#./..#./.#../...#
##./#../... => ###./.###/#.##/.#..
..#/#../... => .##./.##./####/####
#.#/#../... => ..##/.#.#/##../#.##
.##/#../... => ...#/..##/...#/#...
###/#../... => ..../##.#/..#./###.
.../.#./... => ###./..##/#..#/#.#.
#../.#./... => #..#/..#./#.##/#..#
.#./.#./... => ##.#/..../...#/....
##./.#./... => #.#./.##./.###/####
#.#/.#./... => ####/.##./.#../##.#
###/.#./... => #.##/..../.#.#/.##.
.#./##./... => ##.#/#.##/#.##/..##
##./##./... => .###/..../#.../..#.
..#/##./... => ..../.#../..#./##..
#.#/##./... => #.##/##../..##/.#.#
.##/##./... => ..../..#./#..#/....
###/##./... => #..#/#.##/##.#/..##
.../#.#/... => ..../#.#./.##./.#.#
#../#.#/... => .###/.#.#/#.#./..#.
.#./#.#/... => ####/#.../.#../.##.
##./#.#/... => ..##/..#./.#.#/#.#.
#.#/#.#/... => #.##/##../##../#..#
###/#.#/... => .###/.##./.##./.#.#
.../###/... => ##.#/..##/...#/..##
#../###/... => ..##/####/..#./.###
.#./###/... => #.##/#.##/.##./..##
##./###/... => #.../.#.#/####/..##
#.#/###/... => #.../.###/..../.###
###/###/... => .##./####/##../..#.
..#/.../#.. => #..#/.###/.#.#/##.#
#.#/.../#.. => ###./.##./.##./##..
.##/.../#.. => .###/.#../...#/.#.#
###/.../#.. => ###./..##/..##/.#.#
.##/#../#.. => ##.#/...#/####/#.##
###/#../#.. => .#.#/...#/.###/#..#
..#/.#./#.. => #.#./.###/##../#...
#.#/.#./#.. => ####/..#./.###/##..
.##/.#./#.. => #.#./##../..../#.#.
###/.#./#.. => .#.#/#.#./#.../#.#.
.##/##./#.. => ##../.#../...#/..#.
###/##./#.. => ##../#.../.###/..#.
#../..#/#.. => ##../####/##.#/#.##
.#./..#/#.. => #..#/..../..#./#...
##./..#/#.. => ..#./..##/#.##/#.##
#.#/..#/#.. => #.##/..#./.#.#/.#..
.##/..#/#.. => ###./##../.#.#/##..
###/..#/#.. => #.#./.#.#/.#.#/#..#
#../#.#/#.. => #..#/.#.#/####/.#.#
.#./#.#/#.. => #.../#.##/#.../#.#.
##./#.#/#.. => .##./.#../.#.#/..#.
..#/#.#/#.. => ##.#/.###/#..#/#...
#.#/#.#/#.. => .#.#/.###/#..#/.#..
.##/#.#/#.. => ..#./####/.#../...#
###/#.#/#.. => .###/.#../.##./.#.#
#../.##/#.. => ..##/##.#/#.#./.###
.#./.##/#.. => ####/.##./..../.##.
##./.##/#.. => ...#/##../..##/..##
#.#/.##/#.. => .###/##.#/.###/..#.
.##/.##/#.. => ..#./##../..##/...#
###/.##/#.. => ###./.#.#/.###/.###
#../###/#.. => .##./##.#/##.#/..#.
.#./###/#.. => ...#/...#/##.#/#.##
##./###/#.. => .#../.#.#/.#.#/..#.
..#/###/#.. => ####/.#.#/..../##.#
#.#/###/#.. => ..../.###/.##./#.#.
.##/###/#.. => #.#./..##/.##./##..
###/###/#.. => .###/##.#/#.#./#.##
.#./#.#/.#. => ...#/###./..../####
##./#.#/.#. => ..../###./#.##/..##
#.#/#.#/.#. => #.../###./##.#/#...
###/#.#/.#. => #.../##../..#./..#.
.#./###/.#. => ###./..../.#.#/..#.
##./###/.#. => ##.#/..../.##./###.
#.#/###/.#. => #.##/##../...#/....
###/###/.#. => .##./####/##../.#..
#.#/..#/##. => .#.#/#.#./##.#/#.##
###/..#/##. => ####/##../..##/####
.##/#.#/##. => .#.#/#..#/####/##..
###/#.#/##. => #.##/.#../.###/.#..
#.#/.##/##. => ...#/.#.#/#.#./....
###/.##/##. => ..#./#.#./.###/###.
.##/###/##. => .###/.###/.##./.#..
###/###/##. => #.../#.../#.##/.#..
#.#/.../#.# => ..#./..../##../#.##
###/.../#.# => ..#./#.##/####/...#
###/#../#.# => #.../###./#.../...#
#.#/.#./#.# => ..##/#.##/.#.#/.#..
###/.#./#.# => #.../.#.#/#.#./##..
###/##./#.# => ##../.###/.#../...#
#.#/#.#/#.# => ..##/#.#./#.##/##..
###/#.#/#.# => .###/..##/..#./.###
#.#/###/#.# => ##.#/.###/..../.###
###/###/#.# => ##.#/#.##/##../..#.
###/#.#/### => ##../.#../#.#./##.#
###/###/### => .##./##../..#./.###
"""

enum BlockSize: Int {
    case two = 2, three = 3, four = 4
}

struct Block {
    static let stringTwos = [ "..", ".#", "#.", "##" ]
    static let stringThrees = [ "...", "..#", ".#.", ".##", "#..", "#.#", "##.", "###" ]
    
    let size: BlockSize
    let value: Int
    
    init<T>( input: T ) where T: StringProtocol {
        let rows = input.split(separator: "/")
        var result = 0

        if rows.count == 2 {
            size = .two
        } else if rows.count == 3 {
            size = .three
        } else {
            size = .four
        }

        for row in rows {
            for char in row {
                result <<= 1
                if char == "#" {
                    result |= 1
                }
            }
        }
        
        value = result
    }
    
    init( size: BlockSize, value: Int ) {
        self.size = size
        self.value = value
    }
    
    func flipHorizontal() -> Block {
        switch size {
        case .two:
            let first  = ( value & 0xA ) >> 1
            let second = ( value & 0x5 ) << 1
            
            return Block(size: size, value: first | second )
        case .three:
            let first  = ( value & 0x124 ) >> 2
            let second = ( value & 0x049 ) << 2
            let third  = ( value & 0x092 )
            
            return Block(size: size, value: first | second | third )
        case .four:
            // Not used - not implemented
            return self
        }
    }

    func flipVertical() -> Block {
        switch size {
        case .two:
            let first  = ( value & 0xC ) >> 2
            let second = ( value & 0x3 ) << 2
            
            return Block(size: size, value: first | second )
        case .three:
            let first  = ( value & 0x1C0 ) >> 6
            let second = ( value & 0x007 ) << 6
            let third  = ( value & 0x038 )
            
            return Block(size: size, value: first | second | third )
        case .four:
            // Not used - not implemented
            return self
        }
    }
    
    func rotate() -> Block {
        switch size {
        case .two:
            let first  = ( value & 8 ) >> 1
            let second = ( value & 4 ) >> 2
            let third  = ( value & 2 ) << 2
            let fourth = ( value & 1 ) << 1
            
            return Block(size: size, value: first | second | third | fourth )
        case .three:
            let first   = ( value & 0x100 ) >> 2
            let second  = ( value & 0x080 ) >> 4
            let third   = ( value & 0x040 ) >> 6
            let fourth  = ( value & 0x020 ) << 2
            let fifth   = ( value & 0x010 )
            let sixth   = ( value & 0x008 ) >> 2
            let seventh = ( value & 0x004 ) << 6
            let eighth  = ( value & 0x002 ) << 4
            let ninth   = ( value & 0x001 ) << 2
            let new = first | second | third | fourth | fifth | sixth | seventh | eighth | ninth
            
            return Block(size: size, value: new )
        case .four:
            // Not used - not implemented
            return self
        }
    }
    
    func extract( mask1: Int, shift1: Int, mask2: Int, shift2: Int ) -> Int {
        let first  = ( value & mask1 ) >> shift1
        let second = ( value & mask2 ) >> shift2
        
        return first | second
    }
    
    func countBits() -> Int {
        var temp = value
        var count = 0
        
        while temp > 0 {
            if temp & 1 == 1 {
                count += 1
            }
            temp >>= 1
        }
        
        return count
    }
    
    func stringify() -> [String] {
        switch size {
        case .two:
            let row1 = ( value & 0xC ) >> 2
            let row2 = value & 3
            
            return [ Block.stringTwos[row1], Block.stringTwos[row2] ]
        case .three:
            let row1 = ( value & 0x1C0 ) >> 6
            let row2 = ( value & 0x038 ) >> 3
            let row3 = ( value & 0x007 )
            
            return [ Block.stringThrees[row1], Block.stringThrees[row2], Block.stringThrees[row3] ]
        default:
            // Not used - not implemented
            return [ "" ]
        }
    }
}

struct Image {
    static let enhanceTwos = buildEnhancements( input: input, tableSize: 16, blockSize: .two )
    static let enhanceThrees = buildEnhancements( input: input, tableSize: 512, blockSize: .three )
    
    var grid = [ [ Block( input: initial ) ] ]
    
    static func buildEnhancements( input: String, tableSize: Int, blockSize: BlockSize ) -> [Block] {
        var table = Array( repeating: Block( size: blockSize, value: 0 ), count: tableSize )
        
        for line in input.split(separator: "\n") {
            let words = line.split( whereSeparator: { " =>".contains( $0 ) } )
            let lhs = Block( input: words[0] )
            let rhs = Block( input: words[1] )
            
            if lhs.size == blockSize {
                buildRotations( table: &table, pattern: lhs, target: rhs )
                buildRotations( table: &table, pattern: lhs.flipHorizontal(), target: rhs )
                buildRotations( table: &table, pattern: lhs.flipVertical(), target: rhs )
            }
        }
        
        return table
    }
    
    static func buildRotations( table: inout [Block], pattern: Block, target: Block ) -> Void {
        var next = pattern
        
        table[next.value] = target
        for _ in 1 ... 3 {
            next = next.rotate()
            table[next.value] = target
        }
    }
    
    mutating func enhance() -> Void {
        switch grid[0][0].size {
        case .two:
            enhanceTwo()
        case .three:
            enhanceThree()
        default:
            // Should never happen
            break
        }
    }
    
    mutating func enhanceTwo() -> Void {
        grid = grid.map { $0.map { Image.enhanceTwos[$0.value] } }
        
        if ( grid[0][0].size.rawValue * grid.count ) % 2 == 0 {
            // split each 2x2 group of 3x3 blocks into a 3x3 group of 2x2 blocks
            //     Change this        to this
            //      ┌───┬───┐       ┌──┬──┬──┐
            //      │012│345│       │01│23│45│
            //      │678│9AB│       │67│89│AB│
            //      │CDE│FGH│       ├──┼──┼──┤
            //      ├───┼───┤       │CD│EF│GH│
            //      │IJK│LMN│       │IJ│KL│MN│
            //      │OPQ│RST│       ├──┼──┼──┤
            //      │UVW│XYZ│       │OP│QR│ST│
            //      └───┴───┘       │UV│WX│YZ│
            //                      └──┴──┴──┘
            let newGrid = grid
            
            grid = []
            for i in stride( from: 0, to: newGrid.count, by: 2 ) {
                var newRow1: [Block] = []
                var newRow2: [Block] = []
                var newRow3: [Block] = []

                for j in stride( from: 0, to: newGrid.count, by: 2 ) {
                    let ul = newGrid[j][i]
                    let ur = newGrid[j][i+1]
                    let ll = newGrid[j+1][i]
                    let lr = newGrid[j+1][i+1]
                    let b0167 = ul.extract( mask1: 0x180, shift1:  5, mask2: 0x030, shift2:  4 )
                    let b45AB = ur.extract( mask1: 0x0C0, shift1:  4, mask2: 0x018, shift2:  3 )
                    let bOPUV = ll.extract( mask1: 0x030, shift1:  2, mask2: 0x006, shift2:  1 )
                    let bSTYZ = lr.extract( mask1: 0x018, shift1:  1, mask2: 0x003, shift2:  0 )
                    let b2x8x = ul.extract( mask1: 0x040, shift1:  3, mask2: 0x008, shift2:  2 )
                    let bx3x9 = ur.extract( mask1: 0x100, shift1:  6, mask2: 0x020, shift2:  5 )
                    let bCDxx = ul.extract( mask1: 0x006, shift1: -1, mask2: 0x000, shift2:  0 )
                    let bxxIJ = ll.extract( mask1: 0x180, shift1:  7, mask2: 0x000, shift2:  0 )
                    let bGHxx = ur.extract( mask1: 0x003, shift1: -2, mask2: 0x000, shift2:  0 )
                    let bxxMN = lr.extract( mask1: 0x0C0, shift1:  6, mask2: 0x000, shift2:  0 )
                    let bQxWx = ll.extract( mask1: 0x008, shift1:  0, mask2: 0x001, shift2: -1 )
                    let bxRxX = lr.extract( mask1: 0x020, shift1:  3, mask2: 0x004, shift2:  2 )
                    let bExxx = ul.extract( mask1: 0x001, shift1: -3, mask2: 0x000, shift2:  0 )
                    let bxFxx = ur.extract( mask1: 0x004, shift1:  0, mask2: 0x000, shift2:  0 )
                    let bxxKx = ll.extract( mask1: 0x040, shift1:  5, mask2: 0x000, shift2:  0 )
                    let bxxxL = lr.extract( mask1: 0x100, shift1:  8, mask2: 0x000, shift2:  0 )
                    
                    newRow1.append( Block( size: .two, value: b0167 ) )
                    newRow1.append( Block( size: .two, value: b2x8x | bx3x9 ) )
                    newRow1.append( Block( size: .two, value: b45AB ) )
                    newRow2.append( Block( size: .two, value: bCDxx | bxxIJ ) )
                    newRow2.append( Block( size: .two, value: bExxx | bxFxx | bxxKx | bxxxL ) )
                    newRow2.append( Block( size: .two, value: bGHxx | bxxMN ) )
                    newRow3.append( Block( size: .two, value: bOPUV ) )
                    newRow3.append( Block( size: .two, value: bQxWx | bxRxX ) )
                    newRow3.append( Block( size: .two, value: bSTYZ ) )
                }
                
                grid.append( newRow1 )
                grid.append( newRow2 )
                grid.append( newRow3 )
            }
        }
    }
    
    mutating func enhanceThree() -> Void {
        let newGrid = grid.map { $0.map { Image.enhanceThrees[$0.value] } }
        
        // split each 4x4 block into a 2x2 group of 2x2 blocks
        //     Change this        to this
        //       ┌────┐           ┌──┬──┐
        //       │0123│           │01│23│
        //       │4567│           │45│67│
        //       │89AB│           ├──┼──┤
        //       │CDEF│           │89│AB│
        //       └────┘           │CD│EF│
        //                        └──┴──┘
        grid = []
        for row in newGrid {
            var newRow1: [Block] = []
            var newRow2: [Block] = []

            for block in row {
                let b0145 = block.extract( mask1: 0xC000, shift1: 12, mask2: 0x0C00, shift2: 10 )
                let b2367 = block.extract( mask1: 0x3000, shift1: 10, mask2: 0x0300, shift2:  8 )
                let b89CD = block.extract( mask1: 0x00C0, shift1:  4, mask2: 0x000C, shift2:  2 )
                let bABEF = block.extract( mask1: 0x0030, shift1:  2, mask2: 0x0003, shift2:  0 )

                newRow1.append( Block( size: .two, value: b0145 ) )
                newRow1.append( Block( size: .two, value: b2367 ) )
                newRow2.append( Block( size: .two, value: b89CD ) )
                newRow2.append( Block( size: .two, value: bABEF ) )
            }
            
            grid.append( newRow1 )
            grid.append( newRow2 )
        }
    }
    
    func countBits() -> Int {
        return grid.flatMap { $0 }.reduce( 0, { $0 + $1.countBits() } )
    }
    
    func printIt() -> Void {
        for row in grid {
            var strings = row[0].stringify()
            
            for i in 1 ..< row.count {
                let suffix = row[i].stringify()
                
                for j in 0 ..< strings.count {
                    strings[j] += suffix[j]
                }
            }
            
            strings.forEach { print( $0 ) }
        }
        print()
    }
}



var image = Image()

//image.printIt()
( 1 ... 5 ).forEach { _ in image.enhance()/*; image.printIt()*/ }
print( "Part1:", image.countBits() )
( 6 ... 18 ).forEach { _ in image.enhance()/*; image.printIt()*/ }
print( "Part2:", image.countBits() )
