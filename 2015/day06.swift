//
//         FILE: main.swift
//  DESCRIPTION: day06 - Probably a Fire Hazard
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2021 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 07/05/21 11:47:42
//

import Foundation
import Library
import CoreGraphics
import ImageIO

public struct PixelData {
    var a:UInt8 = 255
    var r:UInt8
    var g:UInt8
    var b:UInt8
}


public func imageFromARGB32Bitmap( pixels: [PixelData], width: Int, height: Int ) -> CGImage? {
    assert( pixels.count == Int( width * height ) )
    
    var data = pixels // Copy to mutable []
    let providerRef = CGDataProvider(
        data: NSData( bytes: &data, length: data.count * MemoryLayout<PixelData>.size )
    )!

    return CGImage(
        width: width,
        height: height,
        bitsPerComponent: 8,
        bitsPerPixel: 32,
        bytesPerRow: width * MemoryLayout<PixelData>.size,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGBitmapInfo( rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue ),
        provider: providerRef,
        decode: nil,
        shouldInterpolate: true,
        intent: CGColorRenderingIntent.defaultIntent
    )
}


@discardableResult func writeCGImage( _ image: CGImage, to destinationURL: URL ) -> Bool {
    guard let destination = CGImageDestinationCreateWithURL(
        destinationURL as CFURL, "public.png" as CFString, 1, nil
    ) else { return false }
    CGImageDestinationAddImage( destination, image, nil )
    return CGImageDestinationFinalize( destination )
}


struct Instruction {
    enum Action { case turnOn, turnOff, toggle }
    
    let action: Action
    let upperLeft: Point2D
    let lowerRight: Point2D
    
    init( input: String ) throws {
        let words = input.split( whereSeparator: { " ,".contains( $0 ) } )
        
        switch words[0] {
        case "toggle":
            action = .toggle
            upperLeft = Point2D(x: Int( words[1] )!, y: Int( words[2] )! )
            lowerRight = Point2D(x: Int( words[4] )!, y: Int( words[5] )! )
        case "turn":
            upperLeft = Point2D(x: Int( words[2] )!, y: Int( words[3] )! )
            lowerRight = Point2D(x: Int( words[5] )!, y: Int( words[6] )! )
            switch words[1] {
            case "on":
                action = .turnOn
            case "off":
                action = .turnOff
            default:
                throw RuntimeError( "Invalid modifier '\(words[1])' for turn." )
            }
        default:
            throw RuntimeError( "Invalid action '\(words[0])'." )
        }
    }
}


struct Image {
    var image = Array( repeating: Array( repeating: 0, count: 1000 ), count: 1000 )
    var count: Int { image.flatMap { $0 }.reduce( 0, + ) }
    
    mutating func basic( action: Instruction ) -> Void {
        for y in action.upperLeft.y ... action.lowerRight.y {
            for x in action.upperLeft.x ... action.lowerRight.x {
                switch action.action {
                case .turnOn:
                    image[y][x] = 1
                case .turnOff:
                    image[y][x] = 0
                case .toggle:
                    image[y][x] = image[y][x] == 0 ? 1 : 0
               }
            }
        }
    }
    
    mutating func advanced( action: Instruction ) -> Void {
        for y in action.upperLeft.y ... action.lowerRight.y {
            for x in action.upperLeft.x ... action.lowerRight.x {
                switch action.action {
                case .turnOn:
                    image[y][x] += 1
                case .turnOff:
                    image[y][x] -= image[y][x] == 0 ? 0 : 1
                case .toggle:
                    image[y][x] += 2
               }
            }
        }
    }
    
    func write( toPath path: String ) throws -> Void {
        let url = URL( fileURLWithPath: path )
        let topEnd = image.flatMap { $0 }.max()!
        let pixels = image.flatMap { $0.map { cell -> PixelData in
            let grey = UInt8( CGFloat( cell ) / CGFloat( topEnd ) * 255 )
            return PixelData( r: grey, g: grey, b: grey )
        } }
        let cgImage = imageFromARGB32Bitmap( pixels: pixels, width: image[0].count, height: image.count )
        
        guard let realImage = cgImage else { throw RuntimeError( "Can't create image." ) }
        
        writeCGImage( realImage, to: url )
    }
}


func constructFilePath( name: String ) throws -> String {
    let outputDirectory = try findDirectory( name: "output" )
    let project = URL( fileURLWithPath: #filePath ).deletingLastPathComponent().lastPathComponent
    
    return "\(outputDirectory)/\(project)-\(name).png"
}


func parse( input: AOCinput ) -> [Instruction] {
    return input.lines.map { try! Instruction( input: $0 ) }
}


func part1( input: AOCinput ) -> String {
    let instructions = parse( input: input )
    var image = Image()
    
    for instruction in instructions {
        image.basic( action: instruction )
    }
    
    try! image.write( toPath: constructFilePath( name: "part1" ) )
    return "\( image.count )"
}


func part2( input: AOCinput ) -> String {
    let instructions = parse( input: input )
    var image = Image()
    
    for instruction in instructions {
        image.advanced( action: instruction )
    }
    
    try! image.write( toPath: constructFilePath( name: "part2" ) )
    return "\( image.count )"
}


try print( projectInfo() )
try runTests( part1: part1 )
try runTests( part2: part2 )
try solve( part1: part1 )
try solve( part2: part2 )
