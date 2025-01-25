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

struct DoublyLinkedList<Value> {
    struct Node {
        let value: Value
        let prev: Int?
        let next: Int?
        
        func change( value: Value ) -> Node {
            Node( value: value, prev: prev, next: next )
        }
        
        func change( prev: Int? ) -> Node {
            Node( value: value, prev: prev, next: next )
        }

        func change( next: Int? ) -> Node {
            Node( value: value, prev: prev, next: next )
        }
    }
    
    var head: Int?
    var tail: Int?
    var list: [Node]
    
    init( values: [Value] ) {
        head = nil
        tail = nil
        list = []
        
        values.forEach { append( $0 ) }
    }
    
    subscript( _ index: Int ) -> Value {
        get { list[index].value }
        set { list[index] = list[index].change( value: newValue ) }
    }
    
    mutating func append( _ value: Value ) -> Void {
        list.append( Node( value: value, prev: tail, next: nil ) )
        if head == nil {
            head = list.endIndex - 1
            tail = head
        } else {
            list[tail!] = list[tail!].change( next: list.endIndex - 1 )
            tail = list.endIndex - 1
        }
    }
    
    func firstIndex( where predicate: ( Value ) -> Bool, stop: ( Value ) -> Bool ) -> Int? {
        var current = head
        while let index = current {
            if stop( list[index].value ) { return nil }
            if predicate( list[index].value ) { return index }
            current = list[index].next
        }
        
        return nil
    }
    
    mutating func delete( at index: Int ) -> Void {
        if head == nil { fatalError( "List is empty" ) }
        let node = list[index]
        
        if head == index {
            if tail == index {
                head = nil
                tail = nil
                list = []
            } else {
                head = node.next
                list[head!] = list[head!].change( prev: nil )
            }
        } else if tail == index {
            tail = node.prev
            list[tail!] = list[tail!].change( next: nil )
        } else {
            list[node.prev!] = list[node.prev!].change( next: node.next )
            list[node.next!] = list[node.next!].change( prev: node.prev )
        }
    }
}


struct Disk {
    struct Chunk {
        let id: Int
        let block: Int
        let size: Int
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
        var moved = [Chunk]()

        free = free.reversed()
        while let file = files.last {
            guard let space = free.last else { break }
            guard space.block < file.block else { break }
            
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
        files.append( contentsOf: moved )
    }
    
    mutating func compact() -> Void {
        var freeList = DoublyLinkedList( values: free )
        var moved = [Chunk]()

        for file in files.reversed() {
            let freeIndex = freeList.firstIndex(
                where: { file.size <= $0.size }, stop: { file.block < $0.block }
            )
            guard let freeIndex else {
                moved.append( file )
                continue
            }
            let free = freeList[freeIndex]
            moved.append( Chunk( id: file.id, block: free.block, size: file.size ) )
            if free.size == file.size {
                freeList.delete( at: freeIndex )
            } else {
                freeList[freeIndex] = Chunk(
                    id: 0, block: free.block + file.size, size: free.size - file.size
                )
            }
        }
        files = moved
    }
    
    var checksum: Int {
        files.reduce( 0 ) {
            return $0 + $1.id * ( $1.block ..< $1.block + $1.size ).reduce( 0, + )
        }
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
