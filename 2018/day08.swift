//
//         FILE: main.swift
//  DESCRIPTION: day08 - Memory Maneuver
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/13/21 20:04:38
//

import Foundation

struct OffsetList<Element> {
    let offset: Int
    let numbers: [Element]
    
    subscript( offset: Int ) -> Element {
        numbers[ self.offset + offset ]
    }
    
    subscript( range: Range<Int> ) -> ArraySlice<Element> {
        numbers[ offset + range.startIndex ..< offset + range.endIndex ]
    }
    
    func advance( by: Int ) -> OffsetList {
        OffsetList( offset: offset + by, numbers: numbers )
    }
}


struct Node {
    let children: [Node]
    let metadata: [Int]
    let used: Int
    
    init( offsetList: OffsetList<Int> ) {
        var children = [Node]()
        var used = 2
        
        for _ in 0 ..< offsetList[0] {
            children.append( Node( offsetList: offsetList.advance( by: used ) ) )
            used += children.last!.used
        }
        self.children = children
        
        self.used = used + offsetList[1]
        metadata = Array( offsetList[ used ..< self.used ] )
    }
    
    var sumMetadata: Int {
        metadata.reduce( 0, + ) + children.reduce( 0 ) { $0 + $1.sumMetadata }
    }
    
    var value: Int {
        if children.count == 0 {
            return metadata.reduce( 0, + )
        }
        
        let eligible = metadata.filter { 0 < $0 && $0 <= children.count }
        
        return eligible.reduce( 0, { $0 + children[ $1 - 1 ].value } )
    }
}


func parse( input: AOCinput ) -> Node {
    let numbers = input.line.split( separator: " " ).map { Int( $0 )! }
    
    return Node( offsetList: OffsetList( offset: 0, numbers: numbers ) )
}


func part1( input: AOCinput ) -> String {
    let root = parse( input: input )
    return "\(root.sumMetadata)"
}


func part2( input: AOCinput ) -> String {
    let root = parse( input: input )
    return "\(root.value)"
}


try runTests( part1: part1, part2: part2 )
try runSolutions( part1: part1, part2: part2 )
