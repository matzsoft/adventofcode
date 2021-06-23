//
//         FILE: main.swift
//  DESCRIPTION: day06 - Universal Orbit Map
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 06/01/21 11:42:17
//

import Foundation

class TreeNode {
    let name: String
    weak var parent: TreeNode?
    var children: [TreeNode]
    
    init<T>( name: T ) where T: StringProtocol {
        self.name = String( name )
        parent = nil
        children = []
    }
}

struct Tree {
    let head: TreeNode
    var nodes = [ String : TreeNode ]()
    
    init( lines: [String] ) {
        let names = lines.first!.split( separator: ")" ).map { String( $0 ) }

        head = TreeNode( name: names[0] )
        nodes[names[0]] = head
        
        for line in lines {
            let names = line.components( separatedBy: ")" )
            let major = add( name: names[0] )
            let minor = add( name: names[1] )
            
            major.children.append( minor )
            minor.parent = major
        }
    }
    
    mutating func add( name: String ) -> TreeNode {
        if let node = nodes[name] {
            return node
        }
        
        let node = TreeNode( name: name )
        
        nodes[name] = node
        return node
    }
    
    func path( name: String ) -> [TreeNode] {
        guard let start = nodes[name] else { return [] }
        
        var path = [ start ]
        
        while let parent = path.last!.parent {
            path.append( parent )
        }
        
        return path.reversed()
    }
}


func parse( input: AOCinput ) -> Tree {
    return Tree( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    let tree = parse( input: input )
    return "\( tree.nodes.keys.reduce( 0, { $0 + tree.path( name: $1 ).count - 1 } ) )"
}


func part2( input: AOCinput ) -> String {
    let tree = parse( input: input )
    let pathToMe = tree.path( name: "YOU" )
    let pathToSanta = tree.path( name: "SAN" )

    for index in 0 ..< min( pathToMe.count, pathToSanta.count ) {
        if pathToMe[index] !== pathToSanta[index] {
            return "\( pathToMe.count - index - 1 + pathToSanta.count - index - 1 )"
        }
    }

    return "Failure"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
