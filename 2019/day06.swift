//
//  main.swift
//  day06
//
//  Created by Mark Johnson on 12/6/19.
//  Copyright © 2019 matzsoft. All rights reserved.
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
    var nodes: [ String : TreeNode ]
    
    init( input: String ) {
        let lines = input.split( separator: "\n" )
        let names = lines.first!.split( separator: ")" ).map { String( $0 ) }

        nodes = [:]
        head = TreeNode( name: names[0] )
        nodes[names[0]] = head
        
        for line in lines {
            let names = line.split( separator: ")" ).map { String( $0 ) }
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

let inputFile = "/Users/markj/Development/adventofcode/2019/input/day06.txt"
let tree = Tree( input: try String( contentsOfFile: inputFile ) )

print( "Part 1: \( tree.nodes.keys.reduce( 0, { $0 + tree.path( name: $1 ).count - 1 } ) )" )

let pathToMe = tree.path( name: "YOU" )
let pathToSanta = tree.path( name: "SAN" )

for index in 0 ..< min( pathToMe.count, pathToSanta.count ) {
    if pathToMe[index] !== pathToSanta[index] {
        print( "Part 2: \( pathToMe.count - index - 1 + pathToSanta.count - index - 1 )" )
        exit(0)
    }
}

print( "Part 2: failed" )
exit(1)
