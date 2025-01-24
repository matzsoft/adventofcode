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
    struct Chunk {
        let id: Int
        var block: Int
        var size: Int
    }
    
    var files: [Chunk]
    var free: [Chunk]
    var moved: [Chunk]
    
    init( line: String ) {
        enum State { case file, freespace }
        var state = State.file
        var fileID = 0
        var block = 0
        files = []
        free = []
        moved = []
        
        for character in line {
            let size = Int( String( character ) )!
            switch state {
            case .file:
                files.append( Chunk( id: fileID, block: block, size: size ) )
                fileID += 1
                state = .freespace
            case .freespace:
                free.append( Chunk( id: 0, block: block, size: size ) )
                state = .file
            }
            block += size
        }
    }
    
    mutating func jamPack() -> Void {
        free = free.reversed()
        while let file = files.last {
            guard let space = free.last else { return }
            guard space.block < file.block else { return }
            
            if space.size == file.size {
                let newFile = Chunk( id: file.id, block: space.block, size: file.size )
                moved.append( newFile )
                files.removeLast()
                free.removeLast()
            } else if space.size > file.size {
                let newFile = Chunk( id: file.id, block: space.block, size: file.size )
                let newSpace = Chunk(
                    id: 0, block: space.block + file.size, size: space.size - file.size
                )
                moved.append( newFile )
                files.removeLast()
                free.removeLast()
                free.append( newSpace )
            } else /* space.size < file.size */ {
                let front = Chunk( id: file.id, block: space.block, size: space.size )
                let back = Chunk( id: file.id, block: file.block, size: file.size - space.size )
                moved.append( front )
                files.removeLast()
                free.removeLast()
                files.append( back )
            }
        }
    }
    
    mutating func compact() -> Void {
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
        let unmoved = files.reduce( 0 ) {
            return $0 + $1.id * ( $1.block ..< $1.block + $1.size ).reduce( 0, + )
        }
        let wasmoved = moved.reduce( 0 ) {
            return $0 + $1.id * ( $1.block ..< $1.block + $1.size ).reduce( 0, + )
        }
        
        return unmoved + wasmoved
    }
}


func part1( input: AOCinput ) -> String {
    var disk = Disk( line: input.line )
    disk.jamPack()
    return "\(disk.checksum)"
}


func part2( input: AOCinput ) -> String {
    var disk = Disk( line: input.line )
    disk.compact()
    return "\(disk.checksum)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
