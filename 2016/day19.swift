//
//  main.swift
//  day19
//
//  Created by Mark Johnson on 1/5/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation

let tests = [
    ( in: 5, out: 3 )
]
let input = 3012210

func reduceLeft( list: [Int] ) -> Int {
    guard list.count > 2 else { return list[0] }
    guard list.count > 3 else { return list[2] }
    
    let start = 2 * ( list.count & 1 )
    
    return reduceLeft( list: stride( from: start, to: list.count, by: 2 ).map { list[$0] } )
}

func reduceCenter( list: [Int] ) -> Int {
    guard list.count > 2 else { return list[0] }
    guard list.count > 3 else { return list[2] }
    
    var list = list
    var i = 0
    
    while list.count > 1 {
        let j = ( i + list.count / 2 ) % list.count
        
        list.remove(at: j)
        if i < j { i += 1 }
        i %= list.count
    }
    
    return list[0]
}

func fastCenter( count: Int ) -> Int {
    guard count > 2 else { return 1 }
    guard count > 3 else { return 3 }
    
    var powerOf3 = 1
    
    while powerOf3 * 3 < count { powerOf3 *= 3 }
    
    if count <= 2 * powerOf3 { return count - powerOf3 }
    
    return powerOf3 + 2 * ( count - 2 * powerOf3 )
}

//for i in 1 ... 100 {
//    print( "\(i): \(reduceCenter(list: ( 1 ... i ).map { $0 } ) )" )
//}

print( "Part1:", reduceLeft(list: ( 1 ... input).map { $0 } ) )
print( "Part2:", fastCenter(count: input) )
