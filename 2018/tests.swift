//
//  main.swift
//  tests
//
//  Created by Mark Johnson on 12/23/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

var list = [ 0, 1, 2, 3, 2, 3, 4, 3, 5 ]

for i in ( 1 ..< list.count ).reversed() {
    if let j = list.firstIndex(of: list[i]) {
        if j < i {
            list.remove(at: i)
        }
    }
}

print(list)
