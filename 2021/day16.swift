//
//         FILE: main.swift
//  DESCRIPTION: day16 - Packet Decoder
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/15/21 21:00:12
//

import Foundation

struct HexTable {
    let mapping: [ Character : [Int] ]
    
    subscript( hexDigit: Character ) -> [Int]? { return mapping[hexDigit] }

    init() {
        mapping = [
            "0" : [ 0, 0, 0, 0 ], "1" : [ 0, 0, 0, 1 ], "2" : [ 0, 0, 1, 0 ], "3" : [ 0, 0, 1, 1 ],
            "4" : [ 0, 1, 0, 0 ], "5" : [ 0, 1, 0, 1 ], "6" : [ 0, 1, 1, 0 ], "7" : [ 0, 1, 1, 1 ],
            "8" : [ 1, 0, 0, 0 ], "9" : [ 1, 0, 0, 1 ], "A" : [ 1, 0, 1, 0 ], "B" : [ 1, 0, 1, 1 ],
            "C" : [ 1, 1, 0, 0 ], "D" : [ 1, 1, 0, 1 ], "E" : [ 1, 1, 1, 0 ], "F" : [ 1, 1, 1, 1 ]
        ]
    }
}

let hexTable = HexTable()

struct Packet {
    enum Kind: Int { case sum, product, minimum, maximum, literal, greater, less, equal }
    
    let version: Int
    let type: Kind
    let literalValue: Int?
    let subpackets: [ Packet ]
    
    var versionSum: Int { version + subpackets.reduce( 0 ) { $0 + $1.versionSum } }
    var value: Int {
        switch type {
        case .sum:
            return subpackets.reduce( 0 ) { $0 + $1.value }
        case .product:
            return subpackets.reduce( 1 ) { $0 * $1.value }
        case .minimum:
            return subpackets.map { $0.value }.min()!
        case .maximum:
            return subpackets.map { $0.value }.max()!
        case .literal:
            return literalValue!
        case .greater:
            return subpackets[0].value > subpackets[1].value ? 1 : 0
        case .less:
            return subpackets[0].value < subpackets[1].value ? 1 : 0
        case .equal:
            return subpackets[0].value == subpackets[1].value ? 1 : 0
        }
    }
    
    init( bits: Bits ) throws {
        version = bits.getChunk( size: 3 )
        type = Kind( rawValue: bits.getChunk( size: 3 ) )!
        
        switch type {
        case .literal:
            literalValue = bits.getLiteral()
            subpackets = []
        default:
            literalValue = nil
            
            // lengthTypeID = bits.getChunk( size: 1 )
            switch bits.getChunk( size: 1 ) {
            case 0:
                let totalLength = bits.getChunk( size: 15 )
                let targetCount = bits.count - totalLength
                
                var subpackets = [Packet]()
                while bits.count > targetCount {
                    try subpackets.append( Packet( bits: bits ) )
                }
                self.subpackets = subpackets
            case 1:
                let numberOfSubPackets = bits.getChunk( size: 11 )
                subpackets = try ( 1 ... numberOfSubPackets ).map { _ in try Packet( bits: bits ) }
            default:
                throw RuntimeError( "Invalid lengthTypeID" )
            }
        }
    }
}


class Bits {
    var bits: [Int]
    
    var count: Int { bits.count }
    
    init( line: String ) {
        bits = line.flatMap { hexTable[$0]! }
    }
    
    func getChunk( size: Int ) -> Int {
        let chunk = bits.dropLast( bits.count - size )
        bits.removeFirst( size )
        return Int( chunk.map { String( $0 ) }.joined(), radix: 2 )!
    }
    
    func getLiteral() -> Int {
        var hex = [Int]()
        var notLast = 1
        
        while notLast == 1 {
            notLast = getChunk( size: 1 )
            hex.append( getChunk( size: 4 ) )
        }
        
        return hex.reduce( 0 ) { 16 * $0 + $1 }
    }
}


func part1( input: AOCinput ) -> String {
    let bits = Bits( line: input.line )
    let packet = try! Packet( bits: bits )
    return "\( packet.versionSum )"
}


func part2( input: AOCinput ) -> String {
    let bits = Bits( line: input.line )
    let packet = try! Packet( bits: bits )
    return "\( packet.value )"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
