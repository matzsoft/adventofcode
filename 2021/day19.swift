//
//         FILE: main.swift
//  DESCRIPTION: day19 - Beacon Scanner
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/18/21 22:18:45
//

import Foundation

let overlapThreshold = 12

typealias Orientation = Int
struct OtherBeacon {
    let position: Point3D
    let distance: Int
}

struct Beacon {
    let position: Point3D
    let others: [OtherBeacon]
    
    func matches( other: Beacon ) -> [ ( Point3D, Point3D ) ]? {
        var index = 0
        var otherIndex = 0
        var matches = [ ( position, other.position ) ]
        
        while index < others.count && otherIndex < other.others.count {
            if others[index].distance == other.others[otherIndex].distance {
                matches.append( ( others[index].position, other.others[otherIndex].position ) )
                index += 1
                otherIndex += 1
            } else if others[index].distance < other.others[otherIndex].distance {
                index += 1
            } else {
                otherIndex += 1
            }
        }
        
        return matches.count >= overlapThreshold ? matches : nil
    }
}

struct Scanner: CustomStringConvertible {
    var description: String {
        let lines = [ "Scanner number \(number)" ] + beacons.map { "\( $0.position )" }
        return lines.joined( separator: "\n" )
    }
    
    let number: Int
    let beacons: [Beacon]
    let orientation: Orientation
    
    init( lines: [String] ) {
        number = Int( lines[0].split( separator: " " )[2] )!
        orientation = 0
        let beacons = lines.dropFirst().map { line -> Point3D in
            let words = line.split( separator: "," )
            return Point3D( x: Int( words[0] )!, y: Int( words[1] )!, z: Int( words[2] )! )
        }
        
        self.beacons = beacons.map { beacon in
            let otherBeacons = beacons.compactMap { other in
                return beacon == other ? nil : OtherBeacon( position: other, distance: beacon.distance( other: other ) )
            }.sorted( by: { $0.distance < $1.distance } )
            return Beacon( position: beacon, others: otherBeacons )
        }
    }
    
    func matches( other: Scanner ) -> [ ( Point3D, Point3D ) ]? {
        for beaconIndex in 0 ... ( beacons.count - overlapThreshold ) {
            for otherIndex in other.beacons.indices {
                if let matches = beacons[beaconIndex].matches( other: other.beacons[otherIndex] ) {
                    return matches
                }
            }
        }
        return nil
    }
}


struct Region {
    var scanners: [Point3D]
    var beacons: Set<Point3D>
    
    init( scanner: Scanner ) {
        scanners = [ Point3D( x: 0, y: 0, z: 0 ) ]
        beacons = Set( scanner.beacons.map { $0.position } )
    }
    
    mutating func addScanner( scanner: Scanner, transformation: Matrix3D ) -> Void {
        let scannerX = transformation.transform( point: Point3D( x: 0, y: 0, z: 0 ) )
        let beaconsX = scanner.beacons.map { transformation.transform( point: $0.position ) }
//        print( "After transform" )
//        print( beaconsX.map { "\($0)" }.joined( separator: "\n" ) )
        scanners.append( scannerX )
        beacons.formUnion( beaconsX )
    }
}


func buildTrials() -> [Matrix3D] {
    var trials = [Matrix3D]()
    
    for rotX in Turn.allCases {
        for rotZ in Turn.allCases {
            let matrix = Matrix3D.rotate( aroundX: rotX, aroundY: .straight, aroundZ: rotZ )
            trials.append( matrix )
        }
    }
    
    for roty in [ Turn.left, Turn.right ] {
        for rotZ in Turn.allCases {
            let matrix = Matrix3D.rotate( aroundX: .straight, aroundY: roty, aroundZ: rotZ )
            trials.append( matrix )
        }
    }
    
    return trials
}

func findIt( trials: [Matrix3D], matches: [ ( Point3D, Point3D ) ] ) -> Matrix3D {
    let threshold = 9
    for trial in trials {
        let translationVectors = matches[..<threshold].map { $0.0 - trial.transform( point: $0.1 ) }
        let matching = translationVectors.filter { $0 == translationVectors[0] }
        if matching.count >= threshold { return trial }
    }
    print( "No trial match." )
    exit( 1 )
}


func parse( input: AOCinput ) -> [Scanner] {
    return input.paragraphs.map { Scanner( lines: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let scanners = parse( input: input )
    let trials = buildTrials()
    var regions = [ Int : [ Int : [ ( Point3D, Point3D ) ] ] ]()
    var matrices = [ 0 : Matrix3D.identity ]
    
    for scannerIndex in scanners.indices.dropLast( 1 ) {
        for candidateIndex in scanners.indices.dropFirst( scannerIndex + 1 ) {
            if let matches = scanners[scannerIndex].matches( other: scanners[candidateIndex] ) {
                regions[ scannerIndex, default: Dictionary() ][candidateIndex] = matches
                regions[ candidateIndex, default: Dictionary() ][scannerIndex] = matches
            }
        }
    }
    
    func makeMatrix( scannerIndex: Int, seen: Set<Int> ) -> Matrix3D? {
        if let final = matrices[scannerIndex] { return final }
        if let matches = regions[scannerIndex]![0] {
            let matrix = findIt( trials: trials, matches: matches )
            let translation = matches[0].0 - matrix.transform( point: matches[0].1 )
            let final = matrix.addTranslation( translation: translation )
            matrices[scannerIndex] = final
            return final
        } else {
            for nextIndex in regions[scannerIndex]!.filter( { !seen.contains( $0.key ) } ).map( { $0.key } ) {
                let newSeen = seen.union( [ scannerIndex ] )
                if let intermediate = makeMatrix( scannerIndex: nextIndex, seen: newSeen ) {
                    let matches = nextIndex < scannerIndex
                        ? regions[scannerIndex]![nextIndex]!
                        : regions[scannerIndex]![nextIndex]!.map { ( $0.1, $0.0 ) }
                    let matrix = findIt( trials: trials, matches: matches )
                    let translation = matches[0].0 - matrix.transform( point: matches[0].1 )
                    let final = matrix.addTranslation( translation: translation ).multiply( by: intermediate )
                    matrices[scannerIndex] = final
                    return final
                }
            }
        }
        return nil
    }
    
    for scannerIndex in scanners.indices where matrices[scannerIndex] == nil {
        _ = makeMatrix( scannerIndex: scannerIndex, seen: Set() )
    }
    
    let region = scanners.indices.dropFirst().reduce( into: Region( scanner: scanners[0] ) ) {
        $0.addScanner( scanner: scanners[$1], transformation: matrices[$1]! )
    }
    
    return "\( region.beacons.count )"
}


func part2( input: AOCinput ) -> String {
    let something = parse( input: input )
    return ""
}


try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
