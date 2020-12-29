//
//  main.swift
//  day20
//
//  Created by Mark Johnson on 12/19/20.
//  Copyright © 2020 matzsoft. All rights reserved.
//

import Foundation

struct Pattern {
    struct Element {
        let spaces: Int
        let hashes: Int
        var regex: String { ".{\(spaces)}#{\(hashes)}" }
        var string: String {
            Array( repeating: " ", count: spaces ).joined() + Array( repeating: "#", count: hashes ).joined()
        }
    }

    struct Line {
        let elements: [Element]
        var regex: String { elements.map { $0.regex }.joined() }
        var string: String { elements.map { $0.string }.joined() }
    }
    
    struct Match {
        let index: Int
        let range: Range<String.Index>
    }
    
    let lines: [Line]
    var string: String { lines.map { $0.string }.joined( separator: "\n" ) }
    
    func match( image: [String]) -> [Match] {
        var matches: [ Match ] = []

        for rowIndex in 0 ... image.count - lines.count {
            var startIndex = image[rowIndex].startIndex
            let offset = lines[0].string.count + 1
            let limitIndex = image[rowIndex].index( image[rowIndex].endIndex, offsetBy: -offset )
            
            while startIndex < limitIndex {
                let outerRange = startIndex ..< image[rowIndex].endIndex
                let result = image[rowIndex].range(
                    of: lines[0].regex,
                    options: .regularExpression,
                    range: outerRange
                )
                
                guard let range = result else { break }
                
                var found = true
                for index1 in 1 ..< lines.count {
                    let index2 = rowIndex + index1
                    
                    if image[index2].range(
                        of: lines[index1].regex,
                        options: .regularExpression,
                        range: range
                    ) == nil {
                        found = false
                        break
                    }
                }
                if found {
                    matches.append( Match( index: rowIndex, range: range ) )
                }
                startIndex = image[rowIndex].index( range.lowerBound, offsetBy: 1 )
            }
        }
        return matches
    }
    
    func clear( image: [String], match: Match ) -> [String] {
        var image = image
        
        for index1 in 0 ..< lines.count {
            var startIndex = match.range.lowerBound
            
            for element in lines[index1].elements {
                startIndex = image[ match.index + index1 ].index( startIndex, offsetBy: element.spaces )
                let endIndex = image[ match.index + index1 ].index( startIndex, offsetBy: element.hashes )
                let range = startIndex ..< endIndex
                
                image[ match.index + index1 ].replaceSubrange( range, with: Array( repeating: "O", count: element.hashes ) )
                startIndex = image[ match.index + index1 ].index( startIndex, offsetBy: element.hashes )
            }
        }
        return image
    }
}

//let seaMonster = """
//                  #
//#    ##    ##    ###
// #  #  #  #  #  #
//"""
let seaMonster = Pattern( lines: [
    Pattern.Line( elements: [
        Pattern.Element( spaces: 18, hashes: 1 ),
        Pattern.Element( spaces: 1, hashes: 0 ),
    ] ),
    Pattern.Line(elements: [
        Pattern.Element( spaces: 0, hashes: 1 ),
        Pattern.Element( spaces: 4, hashes: 2 ),
        Pattern.Element( spaces: 4, hashes: 2 ),
        Pattern.Element( spaces: 4, hashes: 3 ),
    ] ),
    Pattern.Line(elements: [
        Pattern.Element( spaces: 1, hashes: 1 ),
        Pattern.Element( spaces: 2, hashes: 1 ),
        Pattern.Element( spaces: 2, hashes: 1 ),
        Pattern.Element( spaces: 2, hashes: 1 ),
        Pattern.Element( spaces: 2, hashes: 1 ),
        Pattern.Element( spaces: 2, hashes: 1 ),
        Pattern.Element( spaces: 3, hashes: 0 ),
    ] ),
] )


struct Orientation: Hashable {
    let flipped: Bool
    let rotation: Int
    
    init( flipped: Bool, rotation: Int ) {
        let rotation = rotation % 4
        
        self.flipped = flipped
        self.rotation = rotation < 0 ? rotation + 4 : rotation
    }
    
    func rotated( by: Int ) -> Orientation {
        return Orientation( flipped: flipped, rotation: rotation + by )
    }
    
    var flip: Orientation {
        return Orientation( flipped: !flipped, rotation: rotation )
    }
    
    func offsetRotation( offset: Int ) -> Orientation {
        return Orientation( flipped: flipped, rotation: offset - rotation )
    }
}


struct Tile {
    let id: Int
    let image: [String]
    let tops: [ String : Orientation ]
    let borders: Set<String>

    var finalImage: [String] {
        return image.dropFirst().dropLast().map { String( $0.dropFirst().dropLast() ) }
    }
    
    static func rotated( by: Int, image: [String] ) -> String {
        let by = by % 4
        
        switch by {
        case 0:
            return image.first!
        case 1:
            return String( image.map { String( $0.first! ) }.joined().reversed() )
        case 2:
            return String( image.last!.reversed() )
        case 3:
            return image.map { String( $0.last! ) }.joined()
        default:
            return ""
        }
    }
    
    init( input: String ) {
        let lines = input.split( separator: "\n" )
        var tops: [ String : Orientation ] = [:]
        
        id = Int( lines[0].dropFirst( 5 ).dropLast() )!
        image = lines.dropFirst().map { String( $0 ) }
        
        tops[ Tile.rotated( by: 0, image: image ) ] = Orientation( flipped: false, rotation: 0 )
        tops[ Tile.rotated( by: 1, image: image ) ] = Orientation( flipped: false, rotation: 1 )
        tops[ Tile.rotated( by: 2, image: image ) ] = Orientation( flipped: false, rotation: 2 )
        tops[ Tile.rotated( by: 3, image: image ) ] = Orientation( flipped: false, rotation: 3 )
        
        let flipped = image.map { String( $0.reversed() ) }
        
        tops[ Tile.rotated( by: 0, image: flipped ) ] = Orientation( flipped: true, rotation: 0 )
        tops[ Tile.rotated( by: 1, image: flipped ) ] = Orientation( flipped: true, rotation: 1 )
        tops[ Tile.rotated( by: 2, image: flipped ) ] = Orientation( flipped: true, rotation: 2 )
        tops[ Tile.rotated( by: 3, image: flipped ) ] = Orientation( flipped: true, rotation: 3 )
        
        self.tops = tops
        borders = Set( tops.keys )
    }
}

struct Node {
    let tile: Tile
    let neighbors: Set<Int>
    
    var isCorner: Bool { neighbors.count == 2 }
    var isEdge: Bool { neighbors.count == 3 }
    var isMiddle: Bool { neighbors.count == 4 }

    init( tile: Tile, tiles: [Tile] ) {
        let others = tiles.filter { $0.id != tile.id }
        
        self.tile = tile
        neighbors = others.reduce( into: Set<Int>(), { set, other in
            if !tile.borders.intersection( other.borders ).isEmpty { set.insert( other.id ) }
        } )
    }
    
    func image( orientation: Orientation ) -> [String] {
        return orient( image: tile.finalImage, orientation: orientation )
    }
}


func place( node left: Node, leftOf right: Node ) -> Set<Orientation> {
    let common = left.tile.borders.intersection( right.tile.borders ).map { left.tile.tops[$0]! }
    
    return Set( common.map { $0.rotated( by: 1 ) } )
}

func place( node top: Node, above bottom: Node ) -> Set<Orientation> {
    let common = top.tile.borders.intersection( bottom.tile.borders ).map { top.tile.tops[$0]! }
    
    return Set( common.map { $0.rotated( by: 2 ) } )
}

class Piece {
    let node: Node
    let orientation: Orientation
    var right: Piece?
    var below: Piece?
    
    var image: [String] { return node.image( orientation: orientation ) }
    var size: Int { return node.tile.image.count - 2 }
    
    init( nodes: [ Int : Node ], node: Node, connected: Set<Int> ) {
        let right = nodes[ connected.first! ]!
        let below = nodes[ connected.first( where: { $0 != right.tile.id } )! ]!
        let rightPossible = place( node: node, leftOf: right )
        let belowPossible = place( node: node, above: below )
        
        self.node = node
        orientation = rightPossible.intersection( belowPossible ).first!
        self.right = self.link( onright: right )
        self.below = self.link( below: below )
    }
    
    init( nodes: [ Int : Node ], piece: Piece, connected: Set<Int> ) {
        self.node = piece.node
        orientation = piece.orientation

        let leftOrientation = piece.orientation.rotated( by: -1 )
        let leftBorder = piece.node.tile.tops.first( where: { $0.value == leftOrientation } )!.key
        
        if let rightID = connected.first( where: { nodes[$0]!.tile.borders.contains( leftBorder ) } ) {
            self.right = self.link( onright: nodes[rightID]! )
        }
        
        let aboveOrientation = piece.orientation.flip.offsetRotation( offset: 2 )
        let aboveBorder = piece.node.tile.tops.first( where: { $0.value == aboveOrientation } )!.key
        
        if let belowID = connected.first( where: { nodes[$0]!.tile.borders.contains( aboveBorder ) } ) {
            self.below = self.link( below: nodes[belowID]! )
        }
    }
    
    init( node: Node, orientation: Orientation, right: Piece? = nil, below: Piece? = nil ) {
        self.node = node
        self.orientation = orientation
        self.right = right
        self.below = below
    }
    
    func link( onright node: Node ) -> Piece {
        let leftOrientation = self.orientation.rotated( by: -1 )
        let border = self.node.tile.tops.first( where: { $0.value == leftOrientation } )!.key
        let rightOrientation = node.tile.tops[border]!.flip.offsetRotation( offset: 3 )
        
        return Piece( node: node, orientation: rightOrientation )
    }

    func link( below node: Node ) -> Piece {
        let aboveOrientation = self.orientation.flip.offsetRotation( offset: 2 )
        let border = self.node.tile.tops.first( where: { $0.value == aboveOrientation } )!.key
        let belowOrientation = node.tile.tops[border]!
        
        return Piece( node: node, orientation: belowOrientation )
    }
}


struct Puzzle {
    let pieces: [[Piece]]
    var image: [String] {
        return pieces.reduce( into: Array<String>(), { array, row in
            array.append( contentsOf: row.reduce(
                            into: Array( repeating: "", count: row[0].size ), { lines, piece in
                                lines = lines.indices.reduce( into: Array<String>() ) {
                                    $0.append( lines[$1] + piece.image[$1] )
                                }
                            } ) )
        } )
    }
    
    init( nodes: [ Int : Node ] ) {
        var pieces: [[Piece]] = []
        var placed: Set<Int> = Set()
        
        // Start the first row
        let corner = nodes.values.first { $0.isCorner }!
        
        pieces.append( [ Piece( nodes: nodes, node: corner, connected: corner.neighbors ) ] )
        placed.insert( corner.tile.id )

        while nodes.count > placed.count {
            let previous = pieces.last!.last!
            
            if let piece = previous.right {
                // Continue with the current row
                let connected = piece.node.neighbors.subtracting( placed )
                let piece = Piece( nodes: nodes, piece: piece, connected: connected )
                
                pieces[ pieces.count - 1 ].append( piece )
                placed.insert( piece.node.tile.id )
            } else if let piece = pieces.last!.first!.below {
                // Start the next row
                let connected = piece.node.neighbors.subtracting( placed )
                let piece = Piece( nodes: nodes, piece: piece, connected: connected )
                
                pieces.append( [ piece ] )
                placed.insert( piece.node.tile.id )
            }
        }
        self.pieces = pieces
    }
    
    func image( orientation: Orientation ) -> [String] {
        return orient( image: image, orientation: orientation )
    }
}


func orient( image: [String], orientation: Orientation ) -> [String] {
    switch orientation.flipped {
    case false:
        switch orientation.rotation {
        case 0:
            return image
        case 1:
            return ( 0 ..< image[0].count ).map { ( col ) -> String in
                ( 0 ..< image.count ).reversed().map { ( row ) -> String in
                    String( image[row][ image[row].index( image[row].startIndex, offsetBy: col ) ] )
                }.joined()
            }
        case 2:
            return image.map { String( $0.reversed() ) }.reversed()
        case 3:
            return ( 0 ..< image[0].count ).reversed().map { ( col ) -> String in
                ( 0 ..< image.count ).map { ( row ) -> String in
                    String( image[row][ image[row].index( image[row].startIndex, offsetBy: col ) ] )
                }.joined()
            }
        default:
            print( "Invalid rotation \(orientation.rotation)" )
            exit( 0 )
        }
    case true:
        switch orientation.rotation {
        case 0:
            return image.map { String( $0.reversed() ) }
        case 1:
            return ( 0 ..< image[0].count ).reversed().map { ( col ) -> String in
                ( 0 ..< image.count ).reversed().map { ( row ) -> String in
                    String( image[row][ image[row].index( image[row].startIndex, offsetBy: col ) ] )
                }.joined()
            }
        case 2:
            return image.reversed()
        case 3:
            return ( 0 ..< image[0].count ).map { ( col ) -> String in
                ( 0 ..< image.count ).map { ( row ) -> String in
                    String( image[row][ image[row].index( image[row].startIndex, offsetBy: col ) ] )
                }.joined()
            }
      default:
            print( "Invalid rotation \(orientation.rotation)" )
            exit( 0 )
        }
    }
}


func count( character: Character, in image: [String] ) -> Int {
    return image.reduce( 0 ) { $0 + $1.filter { $0 == character }.count }
}


func part1( nodes: [ Int: Node ] ) -> Int {
    return nodes.values.filter { $0.isCorner }.reduce( 1 ) { $0 * $1.tile.id }
}


func part2( nodes: [ Int: Node ] ) -> Int {
    let puzzle = Puzzle( nodes: nodes )
    let images = [
        puzzle.image( orientation: Orientation( flipped: false, rotation: 0 ) ),
        puzzle.image( orientation: Orientation( flipped: false, rotation: 1 ) ),
        puzzle.image( orientation: Orientation( flipped: false, rotation: 2 ) ),
        puzzle.image( orientation: Orientation( flipped: false, rotation: 3 ) ),
        puzzle.image( orientation: Orientation( flipped: true, rotation: 0 ) ),
        puzzle.image( orientation: Orientation( flipped: true, rotation: 1 ) ),
        puzzle.image( orientation: Orientation( flipped: true, rotation: 2 ) ),
        puzzle.image( orientation: Orientation( flipped: true, rotation: 3 ) ),
    ].map { ( $0, seaMonster.match( image: $0 ) ) }.max { $0.1.count < $1.1.count }!
    
    let clearedImage = images.1.reduce( into: images.0 ) {
        $0 = seaMonster.clear( image: $0, match: $1 )
    }
    return count( character: "#", in: clearedImage )
}


let inputFile = "/Users/markj/Development/adventofcode/2020/input/day20.txt"
let groups =  try String( contentsOfFile: inputFile ).components( separatedBy: "\n\n" )
let tiles =  groups.map { Tile( input: $0 ) }
var nodes = tiles.reduce(into: [ Int : Node ](), { $0[$1.id] = Node( tile: $1, tiles: tiles ) } )

print( seaMonster.string )
print( "Part 1: \( part1( nodes: nodes ) )" )
print( "Part 2: \( part2( nodes: nodes ) )" )


let test = """
.#.#..#.##...#.##..#####
###....#.#....#..#......
##.##.###.#.#..######...
###.#####...#.#####.#..#
##.#....#.##.####...#.##
...########.#....#####.#
....#..#...##..#.#.###..
.####...#..#.....#......
#..#.##..#..###.#.##....
#.####..#.####.#.#.###..
###.#.#...#.######.#..##
#.####....##..########.#
##..##.#...#...#.#.#.#..
...#..#..#.#.##..###.###
.#.#....#.##.#...###.##.
###.#...#..#.##.######..
.#.#.###.##.##.#..#.##..
.####.###.#...###.#..#.#
..#.#..#..#.#.#.####.###
#..####...#.#.#.###.###.
#####..#####...###....##
#.##..#..#...#..####...#
.#.###..##..##..####.##.
...###...##...#...#..###
""".split( separator: "\n" ).map { String( $0 ) }

//print( "----------- 0 -------------" )
//orient( image: test, orientation: Orientation( flipped: false, rotation: 0 ) ).forEach { print( $0 ) }
//print( "----------- 1 -------------" )
//orient( image: test, orientation: Orientation( flipped: false, rotation: 1 ) ).forEach { print( $0 ) }
//print( "----------- 2 -------------" )
//orient( image: test, orientation: Orientation( flipped: false, rotation: 2 ) ).forEach { print( $0 ) }
//print( "----------- 3 -------------" )
//orient( image: test, orientation: Orientation( flipped: false, rotation: 3 ) ).forEach { print( $0 ) }
//print( "----------- 4 -------------" )
//orient( image: test, orientation: Orientation( flipped: true, rotation: 0 ) ).forEach { print( $0 ) }
//print( "----------- 5 -------------" )
//orient( image: test, orientation: Orientation( flipped: true, rotation: 1 ) ).forEach { print( $0 ) }
//print( "----------- 6 -------------" )
//orient( image: test, orientation: Orientation( flipped: true, rotation: 2 ) ).forEach { print( $0 ) }
//print( "----------- 7 -------------" )
//orient( image: test, orientation: Orientation( flipped: true, rotation: 3 ) ).forEach { print( $0 ) }
