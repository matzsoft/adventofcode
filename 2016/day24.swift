//
//         FILE: main.swift
//  DESCRIPTION: day24 - Air Duct Spelunking
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 04/10/21 16:23:42
//

import Foundation

class Location: Hashable {
    enum LocationType: String, CaseIterable { case open = ".", wall = "#" }

    let type: LocationType
    let point: Point2D
    var distance = Int.max
    
    init( type: LocationType, point: Point2D ) {
        self.type = type
        self.point = point
    }

    static func == ( lhs: Location, rhs: Location ) -> Bool {
        return lhs.type == rhs.type && lhs.point == rhs.point
    }
    
    func hash( into hasher: inout Hasher ) {
        hasher.combine( type )
        hasher.combine( point )
    }
}

class Ducts {
    var layout: [[Location]]
    let destinations: [Location]
    var distanceMap = [[Int]]()
    
    init( lines: [String] ) {
        var destinations: [ Int : Location ] = [:]
        
        layout = []
        for ( y, line ) in lines.enumerated() {
            var row: [Location] = []
            
            for ( x, char ) in line.enumerated() {
                let point = Point2D( x: x, y: y )
                
                switch char {
                case ".":
                    row.append( Location( type: .open, point: point ) )
                case "#":
                    row.append( Location( type: .wall, point: point ) )
                case "0"..."9":
                    let location = Location( type: .open, point: point )
                    
                    row.append( location )
                    destinations[ Int( String( char ) )! ] = location
                default:
                    print( "Invalid charcter '\(char) in input" )
                    exit(1)
                }
            }
            layout.append( row )
        }
        
        self.destinations = destinations.sorted { $0.key < $1.key }.map { $0.value }
        distanceMap = findDistances()
    }
    
    subscript( point: Point2D ) -> Location? {
        guard 0 <= point.x && point.x < layout[0].count else { return nil }
        guard 0 <= point.y && point.y < layout.count else { return nil }

        return layout[point.y][point.x]
    }
    
    func printLayout() -> Void {
        for row in layout {
            let line = row.map { ( location ) -> String in
                if let index = destinations.firstIndex( of: location ) {
                    return String( index )
                } else {
                    return location.type.rawValue
                }
            }.joined()
            
            print(line)
        }
        
        print()
    }
    
    func reset() -> Void {
        layout.forEach { $0.forEach { $0.distance = Int.max } }
    }
    
    func possibleMoves( position: Location ) -> [Location] {
        return DirectionUDLR.allCases.compactMap { ( direction ) -> Location? in
            let nextPoint = position.point.move( direction: direction )
            
            if let nextLocation = self[nextPoint], nextLocation.type == .open {
                return nextLocation
            }
            return nil
        }
    }
    
    func findRoute( begin: Location, end: Location ) -> Int {
        var queue = [ begin ]
        
        reset()
        begin.distance = 0
        while let next = queue.first {
            queue.removeFirst()
            
            if next == end { return next.distance }
            
            for move in possibleMoves( position: next ) {
                if move.distance == Int.max {
                    move.distance = next.distance + 1
                    queue.append( move )
                }
            }
        }
        
        return Int.max
    }
    
    func pathDistance( current: Int, remaining: Set<Int> ) -> ( Int, Int ) {
        let remaining = remaining.subtracting( [ current ] )
        guard remaining.count > 1 else {
            let last = remaining.first!
            return ( distanceMap[current][last], last )
        }
        
        var distance = Int.max
        var last = 0
        
        for next in remaining {
            let ( nextDistance, end ) = pathDistance( current: next, remaining: remaining )
            
            if nextDistance + distanceMap[current][next] < distance {
                distance = nextDistance + distanceMap[current][next]
                last = end
            }
        }
        
        return ( distance, last )
    }
    
    func findDistances() -> [[Int]] {
        var map = Array( repeating: Array( repeating: 0, count: destinations.count ), count: destinations.count )
        
        for i in 0 ..< destinations.count - 1 {
            for j in i + 1 ..< destinations.count {
                let distance = findRoute( begin: destinations[i], end: destinations[j] )
                
                map[i][j] = distance
                map[j][i] = distance
            }
        }
        
        return map
    }

    func openEndedDistance() -> Int {
        let remaining = Set( 0 ..< destinations.count )
        let ( distance, _ ) = pathDistance( current: 0, remaining: remaining )
        
        return distance
    }
    
    func returnDistance() -> Int {
        let remaining = Set( 1 ..< destinations.count )
        var distance = Int.max
        
        for next in remaining {
            let ( nextDistance, end ) = pathDistance( current: next, remaining: remaining )
            let trialDistance = nextDistance + distanceMap[0][next] + distanceMap[0][end]
            
            if trialDistance < distance { distance = trialDistance }
        }
        
        return distance
    }
}



func parse( input: AOCinput ) -> Ducts {
    return Ducts( lines: input.lines )
}


func part1( input: AOCinput ) -> String {
    let ducts = parse( input: input )
    return "\(ducts.openEndedDistance())"
}


func part2( input: AOCinput ) -> String {
    let ducts = parse( input: input )
    return "\(ducts.returnDistance())"
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
