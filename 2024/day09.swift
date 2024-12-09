//
//         FILE: day09.swift
//  DESCRIPTION: Advent of Code 2024 Day 9: Disk Fragmenter
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/08/24 21:00:00
//

import Foundation
import Library

struct Disk {
    var blocks: [Int?]
    
    init( line: String ) {
        enum State { case file, freespace }
        var state = State.file
        var fileID = 0
        blocks = []
        
        for character in line {
            let size = Int( String( character ) )!
            switch state {
            case .file:
                blocks.append( contentsOf: Array( repeating: fileID, count: size ) )
                fileID += 1
                state = .freespace
            case .freespace:
                blocks.append( contentsOf: Array( repeating: nil, count: size ) )
                state = .file
            }
        }
    }
    
    var dump: String {
        blocks.map {
            if let char = $0 { return String( char ) }
            return "."
        }.joined()
    }
    
    mutating func jamPack() -> Void {
        var firstFree = blocks.firstIndex( of: nil )!
        var lastUsed = blocks.lastIndex { $0 != nil}!
        
        while firstFree < lastUsed {
            blocks[firstFree] = blocks[lastUsed]
            blocks[lastUsed] = nil
            
            firstFree = blocks[firstFree...].firstIndex( of: nil )!
            lastUsed = blocks[..<lastUsed].lastIndex { $0 != nil}!
        }
    }
    
    var checksum: Int {
        blocks.indices.reduce( 0 ) {
            guard let value = blocks[$1] else { return $0 }
            return $0 + $1 * value
        }
    }
}


struct Disk2 {
    struct Chunk {
        var block: Int
        var size: Int
    }
    
    var files: [Chunk]
    var free: [Chunk]
    
    init( line: String ) {
        enum State { case file, freespace }
        var state = State.file
        var fileID = 0
        var block = 0
        files = []
        free = []
        
        for character in line {
            let size = Int( String( character ) )!
            switch state {
            case .file:
                files.append( Chunk( block: block, size: size ) )
                fileID += 1
                state = .freespace
            case .freespace:
                free.append( Chunk( block: block, size: size ) )
                state = .file
            }
            block += size
        }
    }
    
    mutating func smartPack() -> Void {
        for fileID in files.indices.reversed() {
            let file = files[fileID]
            let available = free.prefix { $0.block < file.block }
            if let freeIndex = available.firstIndex( where: { file.size <= $0.size } ) {
                files[fileID].block = free[freeIndex].block
                if file.size < free[freeIndex].size {
                    free[freeIndex].block += file.size
                    free[freeIndex].size -= file.size
                } else {
                    free.remove( at: freeIndex )
                }
            }
        }
    }
    
    var checksum: Int {
        files.indices.reduce( 0 ) {
            let file = files[$1]
            let blockSum = ( file.block ..< file.block + file.size ).reduce( 0, + )
            return $0 + $1 * blockSum
        }
    }
}


func parse( input: AOCinput ) -> Any? {
    return nil
}


func part1( input: AOCinput ) -> String {
    var disk = Disk( line: input.line )
    disk.jamPack()
    return "\(disk.checksum)"
}


func part2( input: AOCinput ) -> String {
    var disk = Disk2( line: input.line )
    disk.smartPack()
    return "\(disk.checksum)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
