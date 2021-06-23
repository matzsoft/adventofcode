//
//         FILE: main.swift
//  DESCRIPTION: day18 - Settlers of The North Pole
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 05/27/21 10:45:28
//

import Foundation

enum Acre: String { case open = ".", trees = "|", lumberyard = "#" }

struct Area: Hashable {
    var map: [[Acre]]
    
    init( lines: [String] ) {
        map = lines.map { $0.map {
            switch $0 {
            case ".":
                return .open
            case "|":
                return .trees
            case "#":
                return .lumberyard
            default:
                print( "Invalid input '\($0)'" )
                exit( 1 )
            }
        } }
    }
    
    init( map: [[Acre]] ) {
        self.map = map
    }
    
    func count( of type: Acre ) -> Int {
        return map.reduce( 0 ) { $0 + $1.reduce( 0, { if case type = $1 { return $0 + 1 }; return $0 } ) }
    }
    
    func count( adjacent type: Acre, row: Int, col: Int ) -> Int {
        var count = 0

        for row in max( row - 1, 0 ) ..< min( row + 2, map.count ) {
            for col in max( col - 1, 0 ) ..< min( col + 2, map[row].count ) {
                if type == map[row][col] { count += 1 }
            }
        }

        return count
    }
    
    func printMap() -> Void {
        map.forEach { print( $0.map { $0.rawValue }.joined() ) }
        print()
    }
    
    var transition: Area {
        let new = ( 0 ..< map.count ).map { row in
            ( 0 ..< map[row].count ).map { col -> Acre in
                switch map[row][col] {
                case .open:
                    return count( adjacent: .trees, row: row, col: col ) >= 3 ? .trees : map[row][col]
                case .trees:
                    return count( adjacent: .lumberyard, row: row, col: col ) >= 3 ? .lumberyard : map[row][col]
                case .lumberyard:
                    let lumberyards = count( adjacent: .lumberyard, row: row, col: col )
                    let trees = count( adjacent: .trees, row: row, col: col )
                    
                    return lumberyards == 1 || trees == 0 ? .open : map[row][col]
                }
            }
        }
        
        return Area( map: new )
    }
}


func part1( input: AOCinput ) -> String {
    var area = Area( lines: input.lines )
    
    for _ in 1 ... 10 { area = area.transition }
    return "\(area.count( of: .trees ) * area.count( of: .lumberyard ))"
}


func part2( input: AOCinput ) -> String {
    let limit = 1000000000
    var area = Area( lines: input.lines )
    var history = [ Area : Int ]()
    var minute = 0
    
    while minute < limit {
        minute += 1
        area = area.transition
        
        if let firstMinute = history.updateValue( minute, forKey: area ) {
            let remaining = limit - minute
            let offset = remaining % ( minute - firstMinute )
            
            if let final = history.first(where: { $1 == firstMinute + offset } ) {
                area = final.key
                break
            }
            print( "Unexpected error" )
            break
        }
    }
    
    return "\(area.count( of: .trees ) * area.count( of: .lumberyard ))"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
