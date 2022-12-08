//
//         FILE: main.swift
//  DESCRIPTION: day07 - No Space Left On Device
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2022 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/06/22 21:00:20
//

import Foundation

struct File {
    let name: String
    let size: Int
}

class Directory {
    let name: String
    let parent: Directory?
    var directories: [Directory]
    var files: [File]
    var size: Int
    
    var flatten: [Directory] {
        [ self ] + directories.flatMap { $0.flatten }
    }
    
    internal init( name: String, parent: Directory? ) {
        self.name = name
        self.parent = parent
        self.directories = []
        self.files = []
        self.size = 0
    }
    
    func usage() -> Int {
        size = files.reduce( 0, { $0 + $1.size } ) + directories.reduce( 0 ) { $0 + $1.usage() }
        return size
    }
}


func parse( input: AOCinput ) -> Directory {
    let root = Directory( name: "/", parent: nil )
    var cwd = root
    
    for line in input.lines {
        let words = line.split( separator: " " ).map { String( $0 ) }
        
        switch words[0] {
        case "dir":
            cwd.directories.append( Directory( name: words[1], parent: cwd ) )
        case "$":
            if words[1] == "cd" {
                switch words[2] {
                case "/":
                    cwd = root
                case "..":
                    cwd = cwd.parent!
                default:
                    cwd = cwd.directories.first( where: { $0.name == words[2] } )!
                }
            }
        default:
            cwd.files.append( File( name: words[1], size: Int( words[0] )! ) )
        }
    }
    
    return root
}


func part1( input: AOCinput ) -> String {
    let root = parse( input: input )
    _ = root.usage()
    let answer = root.flatten.filter { $0.size <= 100000 }.reduce( 0, { $0 + $1.size } )
    
    return "\(answer)"
}


func part2( input: AOCinput ) -> String {
    let capacity = 70000000
    let required = 30000000
    let root = parse( input: input )
    let unused = capacity - root.usage()
    let needed = required - unused
    let directories = root.flatten.sorted( by: { $0.size < $1.size } )
    let target = directories.first( where: { $0.size >= needed } )!
    return "\(target.size)"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
