//
//         FILE: main.swift
//  DESCRIPTION: day22 - Grid Computing
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/09/21 17:23:16
//

import Foundation
import Library

struct Move {
    let from: Point2D
    let to: Point2D
}

class Disk {
    let position: Point2D
    let size: Int
    var used: Int
    
    init( position: Point2D, size: Int, used: Int ) {
        self.position = position
        self.size = size
        self.used = used
    }
    
    func canMove( to other: Disk ) -> Bool {
        guard used > 0 else { return false }

        return used <= other.size - other.used
    }
    
    func move( to: Disk ) -> Void {
        ( used, to.used ) = ( to.used, used )
    }
}

class Grid {
    let disks:  [Disk]
    let layout: [[Disk]]

    init( lines: [String] ) {
        disks = lines.compactMap { ( line ) -> Disk? in
            let words = line.split( whereSeparator: { "@x-y T".contains($0) } )

            guard words[0] == "/dev/grid/node" else { return nil }
            
            let x = Int( words[1] )!
            let y = Int( words[2] )!
            let size = Int( words[3] )!
            let used = Int( words[4] )!

            return Disk( position: Point2D( x: x, y: y ), size: size, used: used )
        }
        layout = disks.reduce( into: [[Disk]]() ) { ( array, disk ) in
            if disk.position.y == array.count {
                array.append( [] )
            }
            array[disk.position.y].append( disk )
        }
    }

    subscript( point: Point2D ) -> Disk? {
        guard 0 <= point.x && point.x < layout[0].count else { return nil }
        guard 0 <= point.y && point.y < layout.count else { return nil }

        return layout[point.y][point.x]
    }
    
    func canMove( to: Disk, direction: DirectionUDLR ) -> Disk? {
        guard let from = self[ to.position.move(direction: direction) ] else { return nil }
        
        return from.canMove( to: to ) ? from : nil
    }
    
    class MoveTracker {
        var empty: Disk
        var moves: Int
        
        init( grid: Grid ) {
            empty = grid.findEmpty()
            moves = 0
        }
        
        func move( to full: Disk ) -> Void {
            full.move( to: empty )
            empty = full
            moves += 1
        }
    }
    
    func keepMoving( tracker: MoveTracker, direction: DirectionUDLR ) -> Void {
        while let full = canMove( to: tracker.empty, direction: direction ) {
            tracker.move( to: full )
        }
    }
    
    func keepMoving( tracker: MoveTracker, direction: DirectionUDLR, blocked: DirectionUDLR ) -> Void {
        while canMove( to: tracker.empty, direction: blocked ) == nil {
            if let full = canMove( to: tracker.empty, direction: direction ) {
                tracker.move( to: full )
            }
        }
    }
    
    func moveSequence( tracker: MoveTracker, sequence: [DirectionUDLR] ) -> Void {
        for direction in sequence {
            if let full = canMove( to: tracker.empty, direction: direction ) {
                tracker.move( to: full )
            }
        }
    }

    func countViable() -> Int {
        var count = 0

        for ( index, disk1 ) in disks[ 0 ..< ( disks.count - 1 ) ].enumerated() {
            for disk2 in disks[ ( index + 1 )...] {
                if disk1.canMove( to: disk2 ) { count += 1 }
                if disk2.canMove( to: disk1 ) { count += 1 }
            }
        }

        return count
    }
    
    func summary() -> Void {
        let empties = disks.filter { $0.used == 0 }
        let avail = empties[0].size
        
        for y in 0 ..< layout.count {
            var line = ""
            
            for x in 0 ..< layout[y].count {
                if let disk = self[ Point2D( x: x, y: y ) ] {
                    if disk.used == 0 {
                        line += "_"
                    } else if disk.used > avail {
                        line += "#"
                    } else {
                        line += "."
                    }
                }
            }
            
            print(line)
        }
        
        print()
    }
    
    func findEmpty() -> Disk {
        guard let disk = disks.first( where: { $0.used == 0 } ) else {
            print( "No empty disk found" )
            exit(1)
        }
        
        return disk
    }
    
    func shuffle() -> Int {
        let tracker = MoveTracker( grid: self )
        
        keepMoving( tracker: tracker, direction: .up )
        keepMoving( tracker: tracker, direction: .left, blocked: .up )
        keepMoving( tracker: tracker, direction: .up )
        keepMoving( tracker: tracker, direction: .right )

        while tracker.empty.position.x > 1 {
            moveSequence( tracker: tracker, sequence: [ .down, .left, .left, .up, .right ] )
        }
        
        return tracker.moves
    }
}


func parse( input: AOCinput ) -> Grid {
    return Grid( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    let grid = parse( input: input )
    return "\(grid.countViable())"
}


func part2( input: AOCinput ) -> String {
    let grid = parse( input: input )
    return "\(grid.shuffle())"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
