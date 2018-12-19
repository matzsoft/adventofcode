//
//  main.swift
//  day16
//
//  Created by Mark Johnson on 12/17/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

let input = """
Before: [3, 0, 0, 1]
0 3 0 2
After:  [3, 0, 1, 1]

Before: [2, 0, 0, 2]
4 0 3 1
After:  [2, 1, 0, 2]

Before: [0, 1, 1, 1]
14 0 0 2
After:  [0, 1, 0, 1]

Before: [3, 0, 1, 1]
11 0 0 3
After:  [3, 0, 1, 1]

Before: [1, 2, 2, 0]
9 0 2 1
After:  [1, 0, 2, 0]

Before: [0, 2, 3, 3]
11 2 2 3
After:  [0, 2, 3, 1]

Before: [2, 0, 1, 2]
4 0 3 2
After:  [2, 0, 1, 2]

Before: [2, 0, 2, 2]
6 3 3 3
After:  [2, 0, 2, 0]

Before: [0, 1, 2, 2]
1 1 2 3
After:  [0, 1, 2, 0]

Before: [0, 3, 0, 0]
14 0 0 0
After:  [0, 3, 0, 0]

Before: [2, 2, 0, 2]
4 0 3 3
After:  [2, 2, 0, 1]

Before: [2, 3, 2, 1]
13 2 2 0
After:  [1, 3, 2, 1]

Before: [2, 1, 1, 2]
4 0 3 1
After:  [2, 1, 1, 2]

Before: [1, 2, 2, 1]
9 0 2 0
After:  [0, 2, 2, 1]

Before: [2, 2, 0, 2]
4 0 3 1
After:  [2, 1, 0, 2]

Before: [1, 0, 2, 3]
9 0 2 1
After:  [1, 0, 2, 3]

Before: [1, 1, 3, 2]
10 1 3 1
After:  [1, 0, 3, 2]

Before: [0, 2, 1, 3]
14 0 0 1
After:  [0, 0, 1, 3]

Before: [2, 1, 2, 1]
11 0 0 1
After:  [2, 1, 2, 1]

Before: [1, 1, 2, 2]
3 2 3 1
After:  [1, 2, 2, 2]

Before: [3, 0, 2, 3]
8 1 0 1
After:  [3, 0, 2, 3]

Before: [1, 3, 2, 2]
9 0 2 2
After:  [1, 3, 0, 2]

Before: [2, 0, 3, 2]
4 0 3 2
After:  [2, 0, 1, 2]

Before: [2, 1, 1, 2]
10 1 3 1
After:  [2, 0, 1, 2]

Before: [2, 1, 2, 3]
1 1 2 2
After:  [2, 1, 0, 3]

Before: [3, 1, 2, 1]
1 1 2 3
After:  [3, 1, 2, 0]

Before: [2, 2, 2, 3]
5 2 2 1
After:  [2, 2, 2, 3]

Before: [2, 0, 2, 2]
4 0 3 2
After:  [2, 0, 1, 2]

Before: [2, 3, 1, 1]
11 0 0 0
After:  [1, 3, 1, 1]

Before: [2, 3, 2, 2]
4 0 3 1
After:  [2, 1, 2, 2]

Before: [3, 1, 3, 0]
0 1 0 1
After:  [3, 1, 3, 0]

Before: [3, 1, 2, 3]
12 3 0 3
After:  [3, 1, 2, 1]

Before: [1, 0, 3, 1]
6 3 3 1
After:  [1, 0, 3, 1]

Before: [0, 1, 2, 3]
1 1 2 3
After:  [0, 1, 2, 0]

Before: [1, 2, 1, 3]
2 1 3 1
After:  [1, 0, 1, 3]

Before: [1, 2, 2, 3]
9 0 2 2
After:  [1, 2, 0, 3]

Before: [3, 3, 3, 2]
11 0 2 1
After:  [3, 1, 3, 2]

Before: [2, 1, 0, 2]
10 1 3 3
After:  [2, 1, 0, 0]

Before: [3, 3, 3, 3]
5 3 3 0
After:  [3, 3, 3, 3]

Before: [0, 3, 2, 0]
13 0 0 0
After:  [1, 3, 2, 0]

Before: [3, 0, 2, 2]
3 2 3 3
After:  [3, 0, 2, 2]

Before: [1, 3, 2, 1]
9 0 2 1
After:  [1, 0, 2, 1]

Before: [1, 1, 2, 3]
1 1 2 0
After:  [0, 1, 2, 3]

Before: [1, 1, 0, 2]
15 1 0 1
After:  [1, 1, 0, 2]

Before: [0, 1, 1, 3]
2 2 3 3
After:  [0, 1, 1, 0]

Before: [3, 1, 3, 3]
0 3 0 3
After:  [3, 1, 3, 3]

Before: [0, 0, 3, 3]
14 0 0 3
After:  [0, 0, 3, 0]

Before: [2, 1, 2, 2]
1 1 2 2
After:  [2, 1, 0, 2]

Before: [2, 1, 0, 2]
4 0 3 0
After:  [1, 1, 0, 2]

Before: [2, 1, 2, 1]
7 3 2 0
After:  [1, 1, 2, 1]

Before: [3, 1, 2, 2]
10 1 3 2
After:  [3, 1, 0, 2]

Before: [3, 1, 1, 3]
0 1 0 2
After:  [3, 1, 1, 3]

Before: [3, 0, 2, 1]
7 3 2 0
After:  [1, 0, 2, 1]

Before: [2, 2, 0, 2]
4 0 3 0
After:  [1, 2, 0, 2]

Before: [0, 3, 3, 3]
13 3 3 0
After:  [1, 3, 3, 3]

Before: [2, 1, 2, 3]
5 3 3 3
After:  [2, 1, 2, 3]

Before: [1, 1, 2, 1]
7 3 2 0
After:  [1, 1, 2, 1]

Before: [3, 0, 1, 3]
2 2 3 2
After:  [3, 0, 0, 3]

Before: [0, 2, 2, 1]
14 0 0 2
After:  [0, 2, 0, 1]

Before: [0, 3, 3, 1]
14 0 0 2
After:  [0, 3, 0, 1]

Before: [0, 1, 2, 2]
3 2 3 0
After:  [2, 1, 2, 2]

Before: [0, 3, 2, 0]
14 0 0 1
After:  [0, 0, 2, 0]

Before: [0, 1, 2, 2]
10 1 3 0
After:  [0, 1, 2, 2]

Before: [1, 3, 2, 1]
7 3 2 1
After:  [1, 1, 2, 1]

Before: [1, 0, 2, 3]
9 0 2 3
After:  [1, 0, 2, 0]

Before: [0, 3, 2, 2]
6 3 3 0
After:  [0, 3, 2, 2]

Before: [0, 0, 0, 3]
13 3 3 0
After:  [1, 0, 0, 3]

Before: [2, 0, 2, 2]
3 2 3 0
After:  [2, 0, 2, 2]

Before: [0, 0, 2, 2]
3 2 3 3
After:  [0, 0, 2, 2]

Before: [2, 2, 2, 1]
7 3 2 0
After:  [1, 2, 2, 1]

Before: [3, 3, 1, 3]
0 3 0 2
After:  [3, 3, 3, 3]

Before: [1, 1, 1, 1]
15 1 0 3
After:  [1, 1, 1, 1]

Before: [1, 2, 2, 0]
9 0 2 3
After:  [1, 2, 2, 0]

Before: [2, 2, 2, 1]
12 2 0 2
After:  [2, 2, 1, 1]

Before: [2, 1, 2, 2]
1 1 2 0
After:  [0, 1, 2, 2]

Before: [1, 0, 2, 2]
5 2 2 2
After:  [1, 0, 2, 2]

Before: [0, 0, 2, 2]
3 2 3 1
After:  [0, 2, 2, 2]

Before: [0, 1, 0, 2]
10 1 3 1
After:  [0, 0, 0, 2]

Before: [3, 1, 1, 3]
2 2 3 1
After:  [3, 0, 1, 3]

Before: [0, 2, 1, 0]
8 0 1 3
After:  [0, 2, 1, 0]

Before: [1, 1, 3, 3]
2 1 3 0
After:  [0, 1, 3, 3]

Before: [0, 0, 2, 2]
14 0 0 0
After:  [0, 0, 2, 2]

Before: [1, 2, 2, 3]
9 0 2 3
After:  [1, 2, 2, 0]

Before: [2, 2, 1, 3]
5 3 3 1
After:  [2, 3, 1, 3]

Before: [2, 2, 2, 2]
4 0 3 0
After:  [1, 2, 2, 2]

Before: [0, 0, 3, 0]
14 0 0 3
After:  [0, 0, 3, 0]

Before: [3, 2, 2, 0]
12 2 1 1
After:  [3, 1, 2, 0]

Before: [2, 1, 1, 2]
4 0 3 2
After:  [2, 1, 1, 2]

Before: [3, 2, 2, 3]
5 3 3 3
After:  [3, 2, 2, 3]

Before: [3, 2, 2, 2]
3 2 3 0
After:  [2, 2, 2, 2]

Before: [0, 0, 0, 1]
6 3 3 0
After:  [0, 0, 0, 1]

Before: [1, 1, 0, 0]
15 1 0 1
After:  [1, 1, 0, 0]

Before: [0, 0, 1, 1]
14 0 0 2
After:  [0, 0, 0, 1]

Before: [1, 3, 0, 3]
13 3 3 1
After:  [1, 1, 0, 3]

Before: [1, 1, 3, 1]
15 1 0 3
After:  [1, 1, 3, 1]

Before: [1, 1, 2, 1]
5 2 2 2
After:  [1, 1, 2, 1]

Before: [3, 2, 2, 1]
7 3 2 1
After:  [3, 1, 2, 1]

Before: [1, 1, 2, 0]
15 1 0 2
After:  [1, 1, 1, 0]

Before: [0, 0, 3, 0]
11 2 2 0
After:  [1, 0, 3, 0]

Before: [0, 2, 2, 3]
12 2 1 2
After:  [0, 2, 1, 3]

Before: [0, 0, 3, 2]
14 0 0 3
After:  [0, 0, 3, 0]

Before: [1, 3, 2, 3]
13 2 2 2
After:  [1, 3, 1, 3]

Before: [1, 1, 2, 1]
7 3 2 3
After:  [1, 1, 2, 1]

Before: [0, 1, 3, 0]
8 0 1 1
After:  [0, 0, 3, 0]

Before: [1, 0, 2, 2]
9 0 2 0
After:  [0, 0, 2, 2]

Before: [0, 1, 0, 3]
8 0 1 3
After:  [0, 1, 0, 0]

Before: [0, 2, 1, 3]
2 1 3 3
After:  [0, 2, 1, 0]

Before: [2, 3, 2, 3]
11 0 0 0
After:  [1, 3, 2, 3]

Before: [0, 0, 2, 1]
6 3 3 3
After:  [0, 0, 2, 0]

Before: [2, 2, 3, 2]
11 0 0 0
After:  [1, 2, 3, 2]

Before: [3, 1, 2, 1]
7 3 2 1
After:  [3, 1, 2, 1]

Before: [0, 2, 2, 1]
7 3 2 1
After:  [0, 1, 2, 1]

Before: [0, 1, 0, 3]
14 0 0 1
After:  [0, 0, 0, 3]

Before: [1, 1, 2, 1]
9 0 2 3
After:  [1, 1, 2, 0]

Before: [0, 3, 3, 3]
8 0 1 3
After:  [0, 3, 3, 0]

Before: [0, 3, 0, 3]
13 3 3 3
After:  [0, 3, 0, 1]

Before: [0, 2, 2, 3]
8 0 3 0
After:  [0, 2, 2, 3]

Before: [2, 3, 2, 1]
12 2 0 0
After:  [1, 3, 2, 1]

Before: [0, 3, 3, 0]
8 0 1 0
After:  [0, 3, 3, 0]

Before: [1, 1, 1, 2]
10 1 3 3
After:  [1, 1, 1, 0]

Before: [0, 3, 1, 1]
8 0 3 0
After:  [0, 3, 1, 1]

Before: [2, 1, 3, 3]
2 1 3 0
After:  [0, 1, 3, 3]

Before: [1, 1, 2, 3]
1 1 2 2
After:  [1, 1, 0, 3]

Before: [3, 3, 2, 3]
2 2 3 3
After:  [3, 3, 2, 0]

Before: [0, 1, 1, 3]
13 3 2 0
After:  [0, 1, 1, 3]

Before: [0, 2, 0, 2]
13 0 0 1
After:  [0, 1, 0, 2]

Before: [3, 1, 2, 3]
1 1 2 0
After:  [0, 1, 2, 3]

Before: [0, 3, 3, 3]
11 2 2 1
After:  [0, 1, 3, 3]

Before: [0, 2, 3, 2]
8 0 2 3
After:  [0, 2, 3, 0]

Before: [3, 1, 1, 0]
0 1 0 0
After:  [1, 1, 1, 0]

Before: [2, 1, 2, 1]
0 2 0 3
After:  [2, 1, 2, 2]

Before: [0, 1, 2, 3]
13 3 3 1
After:  [0, 1, 2, 3]

Before: [1, 0, 2, 0]
9 0 2 3
After:  [1, 0, 2, 0]

Before: [3, 1, 2, 0]
11 0 0 0
After:  [1, 1, 2, 0]

Before: [0, 2, 1, 0]
14 0 0 1
After:  [0, 0, 1, 0]

Before: [2, 1, 3, 2]
4 0 3 3
After:  [2, 1, 3, 1]

Before: [0, 2, 2, 3]
2 1 3 0
After:  [0, 2, 2, 3]

Before: [2, 3, 3, 1]
11 2 2 1
After:  [2, 1, 3, 1]

Before: [0, 2, 2, 1]
12 2 1 2
After:  [0, 2, 1, 1]

Before: [2, 3, 2, 2]
3 2 3 2
After:  [2, 3, 2, 2]

Before: [2, 3, 3, 2]
4 0 3 0
After:  [1, 3, 3, 2]

Before: [3, 1, 3, 3]
0 3 0 0
After:  [3, 1, 3, 3]

Before: [0, 2, 1, 3]
8 0 3 2
After:  [0, 2, 0, 3]

Before: [2, 1, 2, 2]
3 2 3 3
After:  [2, 1, 2, 2]

Before: [2, 2, 2, 2]
12 2 1 1
After:  [2, 1, 2, 2]

Before: [2, 1, 2, 2]
3 2 3 1
After:  [2, 2, 2, 2]

Before: [3, 0, 3, 3]
0 3 0 2
After:  [3, 0, 3, 3]

Before: [1, 0, 3, 0]
11 2 2 3
After:  [1, 0, 3, 1]

Before: [0, 2, 2, 0]
12 2 1 1
After:  [0, 1, 2, 0]

Before: [1, 1, 0, 0]
15 1 0 2
After:  [1, 1, 1, 0]

Before: [2, 1, 0, 2]
4 0 3 1
After:  [2, 1, 0, 2]

Before: [1, 2, 2, 3]
2 2 3 2
After:  [1, 2, 0, 3]

Before: [3, 1, 2, 3]
2 1 3 1
After:  [3, 0, 2, 3]

Before: [1, 1, 1, 3]
15 1 0 2
After:  [1, 1, 1, 3]

Before: [1, 2, 3, 0]
11 2 2 3
After:  [1, 2, 3, 1]

Before: [1, 1, 0, 2]
15 1 0 2
After:  [1, 1, 1, 2]

Before: [3, 1, 3, 2]
10 1 3 3
After:  [3, 1, 3, 0]

Before: [1, 1, 2, 2]
3 2 3 0
After:  [2, 1, 2, 2]

Before: [2, 1, 2, 1]
1 1 2 1
After:  [2, 0, 2, 1]

Before: [3, 1, 3, 1]
0 1 0 2
After:  [3, 1, 1, 1]

Before: [3, 1, 1, 2]
0 1 0 2
After:  [3, 1, 1, 2]

Before: [1, 3, 3, 1]
12 2 3 2
After:  [1, 3, 0, 1]

Before: [3, 1, 1, 2]
10 1 3 3
After:  [3, 1, 1, 0]

Before: [1, 1, 1, 2]
10 1 3 0
After:  [0, 1, 1, 2]

Before: [0, 1, 0, 2]
8 0 3 3
After:  [0, 1, 0, 0]

Before: [3, 0, 0, 3]
5 3 3 1
After:  [3, 3, 0, 3]

Before: [1, 1, 2, 2]
1 1 2 1
After:  [1, 0, 2, 2]

Before: [0, 0, 1, 1]
6 3 3 3
After:  [0, 0, 1, 0]

Before: [1, 2, 2, 2]
6 3 3 3
After:  [1, 2, 2, 0]

Before: [2, 3, 2, 1]
7 3 2 3
After:  [2, 3, 2, 1]

Before: [3, 3, 1, 1]
11 0 0 0
After:  [1, 3, 1, 1]

Before: [3, 0, 2, 1]
7 3 2 2
After:  [3, 0, 1, 1]

Before: [2, 0, 3, 2]
4 0 3 1
After:  [2, 1, 3, 2]

Before: [2, 3, 2, 1]
5 2 2 1
After:  [2, 2, 2, 1]

Before: [1, 1, 0, 2]
10 1 3 3
After:  [1, 1, 0, 0]

Before: [0, 3, 1, 3]
8 0 2 1
After:  [0, 0, 1, 3]

Before: [2, 0, 1, 2]
4 0 3 1
After:  [2, 1, 1, 2]

Before: [1, 3, 3, 3]
5 3 3 0
After:  [3, 3, 3, 3]

Before: [2, 2, 2, 2]
4 0 3 3
After:  [2, 2, 2, 1]

Before: [3, 1, 2, 0]
1 1 2 1
After:  [3, 0, 2, 0]

Before: [1, 3, 3, 1]
6 3 3 3
After:  [1, 3, 3, 0]

Before: [1, 1, 3, 1]
15 1 0 2
After:  [1, 1, 1, 1]

Before: [1, 1, 1, 1]
15 1 0 1
After:  [1, 1, 1, 1]

Before: [1, 3, 2, 3]
5 3 3 0
After:  [3, 3, 2, 3]

Before: [2, 0, 2, 1]
7 3 2 2
After:  [2, 0, 1, 1]

Before: [0, 1, 1, 2]
10 1 3 2
After:  [0, 1, 0, 2]

Before: [0, 2, 1, 3]
2 2 3 2
After:  [0, 2, 0, 3]

Before: [1, 1, 2, 0]
1 1 2 2
After:  [1, 1, 0, 0]

Before: [1, 0, 1, 3]
2 2 3 2
After:  [1, 0, 0, 3]

Before: [3, 1, 0, 3]
0 3 0 3
After:  [3, 1, 0, 3]

Before: [0, 2, 0, 1]
8 0 3 0
After:  [0, 2, 0, 1]

Before: [3, 1, 1, 0]
11 0 0 1
After:  [3, 1, 1, 0]

Before: [1, 2, 2, 2]
6 3 3 1
After:  [1, 0, 2, 2]

Before: [1, 2, 1, 3]
2 2 3 3
After:  [1, 2, 1, 0]

Before: [0, 3, 3, 2]
14 0 0 1
After:  [0, 0, 3, 2]

Before: [2, 2, 2, 1]
7 3 2 2
After:  [2, 2, 1, 1]

Before: [2, 2, 0, 2]
4 0 3 2
After:  [2, 2, 1, 2]

Before: [0, 1, 1, 3]
8 0 2 1
After:  [0, 0, 1, 3]

Before: [2, 1, 1, 2]
10 1 3 3
After:  [2, 1, 1, 0]

Before: [3, 0, 2, 3]
13 3 2 1
After:  [3, 0, 2, 3]

Before: [0, 3, 2, 1]
14 0 0 3
After:  [0, 3, 2, 0]

Before: [2, 3, 2, 1]
5 2 2 0
After:  [2, 3, 2, 1]

Before: [2, 1, 2, 3]
2 2 3 0
After:  [0, 1, 2, 3]

Before: [0, 1, 3, 2]
10 1 3 1
After:  [0, 0, 3, 2]

Before: [1, 1, 2, 0]
9 0 2 2
After:  [1, 1, 0, 0]

Before: [0, 3, 0, 3]
14 0 0 0
After:  [0, 3, 0, 3]

Before: [0, 2, 0, 3]
2 1 3 0
After:  [0, 2, 0, 3]

Before: [0, 0, 2, 1]
13 2 2 3
After:  [0, 0, 2, 1]

Before: [0, 1, 2, 2]
1 1 2 2
After:  [0, 1, 0, 2]

Before: [3, 1, 3, 3]
2 1 3 3
After:  [3, 1, 3, 0]

Before: [0, 3, 2, 0]
5 2 2 0
After:  [2, 3, 2, 0]

Before: [1, 2, 2, 1]
9 0 2 1
After:  [1, 0, 2, 1]

Before: [1, 3, 2, 3]
2 2 3 3
After:  [1, 3, 2, 0]

Before: [2, 3, 0, 2]
4 0 3 3
After:  [2, 3, 0, 1]

Before: [2, 2, 3, 1]
12 2 3 0
After:  [0, 2, 3, 1]

Before: [0, 1, 2, 2]
13 0 0 1
After:  [0, 1, 2, 2]

Before: [1, 0, 2, 1]
7 3 2 2
After:  [1, 0, 1, 1]

Before: [0, 3, 3, 0]
14 0 0 2
After:  [0, 3, 0, 0]

Before: [3, 0, 3, 1]
11 0 2 0
After:  [1, 0, 3, 1]

Before: [1, 2, 0, 1]
6 3 3 0
After:  [0, 2, 0, 1]

Before: [2, 1, 2, 1]
1 1 2 0
After:  [0, 1, 2, 1]

Before: [3, 3, 2, 3]
0 3 0 0
After:  [3, 3, 2, 3]

Before: [0, 3, 2, 3]
5 3 3 0
After:  [3, 3, 2, 3]

Before: [0, 1, 3, 3]
14 0 0 3
After:  [0, 1, 3, 0]

Before: [0, 0, 3, 1]
13 0 0 1
After:  [0, 1, 3, 1]

Before: [0, 3, 2, 2]
3 2 3 2
After:  [0, 3, 2, 2]

Before: [2, 2, 2, 3]
2 1 3 0
After:  [0, 2, 2, 3]

Before: [2, 2, 2, 3]
12 2 1 0
After:  [1, 2, 2, 3]

Before: [0, 0, 1, 0]
14 0 0 3
After:  [0, 0, 1, 0]

Before: [1, 1, 1, 2]
15 1 0 0
After:  [1, 1, 1, 2]

Before: [2, 0, 2, 1]
7 3 2 0
After:  [1, 0, 2, 1]

Before: [3, 0, 2, 1]
11 0 0 3
After:  [3, 0, 2, 1]

Before: [3, 1, 2, 2]
10 1 3 3
After:  [3, 1, 2, 0]

Before: [0, 1, 2, 3]
13 3 1 0
After:  [0, 1, 2, 3]

Before: [0, 1, 0, 3]
14 0 0 3
After:  [0, 1, 0, 0]

Before: [0, 3, 2, 3]
8 0 2 3
After:  [0, 3, 2, 0]

Before: [1, 3, 2, 2]
9 0 2 0
After:  [0, 3, 2, 2]

Before: [1, 0, 2, 1]
9 0 2 1
After:  [1, 0, 2, 1]

Before: [0, 1, 0, 3]
2 1 3 1
After:  [0, 0, 0, 3]

Before: [0, 0, 2, 3]
14 0 0 0
After:  [0, 0, 2, 3]

Before: [2, 2, 2, 1]
12 2 1 0
After:  [1, 2, 2, 1]

Before: [3, 3, 3, 1]
0 3 0 3
After:  [3, 3, 3, 1]

Before: [3, 3, 0, 1]
0 3 0 1
After:  [3, 1, 0, 1]

Before: [0, 1, 2, 3]
1 1 2 0
After:  [0, 1, 2, 3]

Before: [3, 3, 3, 3]
0 3 0 3
After:  [3, 3, 3, 3]

Before: [1, 0, 2, 2]
3 2 3 1
After:  [1, 2, 2, 2]

Before: [1, 2, 2, 2]
12 2 1 3
After:  [1, 2, 2, 1]

Before: [0, 1, 1, 2]
10 1 3 1
After:  [0, 0, 1, 2]

Before: [1, 0, 2, 2]
9 0 2 2
After:  [1, 0, 0, 2]

Before: [1, 1, 2, 2]
10 1 3 1
After:  [1, 0, 2, 2]

Before: [3, 3, 1, 1]
0 3 0 1
After:  [3, 1, 1, 1]

Before: [2, 1, 2, 2]
12 2 0 0
After:  [1, 1, 2, 2]

Before: [2, 0, 3, 2]
4 0 3 0
After:  [1, 0, 3, 2]

Before: [2, 2, 3, 2]
4 0 3 3
After:  [2, 2, 3, 1]

Before: [2, 3, 3, 3]
13 3 3 2
After:  [2, 3, 1, 3]

Before: [3, 3, 2, 1]
7 3 2 1
After:  [3, 1, 2, 1]

Before: [0, 3, 2, 0]
8 0 2 2
After:  [0, 3, 0, 0]

Before: [0, 1, 3, 2]
13 2 1 1
After:  [0, 0, 3, 2]

Before: [0, 1, 2, 2]
13 0 0 0
After:  [1, 1, 2, 2]

Before: [2, 2, 1, 3]
2 1 3 0
After:  [0, 2, 1, 3]

Before: [1, 1, 1, 0]
15 1 0 1
After:  [1, 1, 1, 0]

Before: [2, 2, 2, 2]
3 2 3 2
After:  [2, 2, 2, 2]

Before: [1, 1, 2, 3]
15 1 0 3
After:  [1, 1, 2, 1]

Before: [2, 0, 3, 2]
4 0 3 3
After:  [2, 0, 3, 1]

Before: [3, 0, 3, 3]
0 3 0 3
After:  [3, 0, 3, 3]

Before: [0, 2, 1, 1]
8 0 2 1
After:  [0, 0, 1, 1]

Before: [1, 3, 2, 0]
5 2 2 3
After:  [1, 3, 2, 2]

Before: [0, 2, 2, 1]
6 3 3 1
After:  [0, 0, 2, 1]

Before: [1, 1, 3, 0]
15 1 0 1
After:  [1, 1, 3, 0]

Before: [2, 0, 1, 3]
5 3 3 0
After:  [3, 0, 1, 3]

Before: [1, 1, 2, 1]
15 1 0 1
After:  [1, 1, 2, 1]

Before: [2, 1, 2, 2]
3 2 3 0
After:  [2, 1, 2, 2]

Before: [1, 1, 3, 2]
15 1 0 3
After:  [1, 1, 3, 1]

Before: [0, 2, 1, 1]
14 0 0 0
After:  [0, 2, 1, 1]

Before: [0, 0, 2, 0]
5 2 2 1
After:  [0, 2, 2, 0]

Before: [0, 1, 2, 3]
2 1 3 2
After:  [0, 1, 0, 3]

Before: [3, 1, 2, 2]
3 2 3 0
After:  [2, 1, 2, 2]

Before: [1, 2, 2, 2]
9 0 2 2
After:  [1, 2, 0, 2]

Before: [2, 2, 2, 1]
5 2 2 1
After:  [2, 2, 2, 1]

Before: [1, 1, 2, 1]
7 3 2 1
After:  [1, 1, 2, 1]

Before: [3, 0, 0, 1]
0 3 0 3
After:  [3, 0, 0, 1]

Before: [3, 2, 3, 3]
12 3 0 3
After:  [3, 2, 3, 1]

Before: [3, 1, 2, 2]
10 1 3 1
After:  [3, 0, 2, 2]

Before: [1, 0, 1, 3]
13 3 2 1
After:  [1, 0, 1, 3]

Before: [0, 0, 0, 2]
14 0 0 1
After:  [0, 0, 0, 2]

Before: [3, 0, 3, 1]
0 3 0 1
After:  [3, 1, 3, 1]

Before: [1, 1, 2, 3]
1 1 2 3
After:  [1, 1, 2, 0]

Before: [3, 1, 2, 1]
1 1 2 1
After:  [3, 0, 2, 1]

Before: [3, 3, 0, 3]
13 3 3 2
After:  [3, 3, 1, 3]

Before: [3, 3, 2, 3]
2 2 3 2
After:  [3, 3, 0, 3]

Before: [1, 2, 2, 1]
9 0 2 2
After:  [1, 2, 0, 1]

Before: [3, 1, 0, 1]
0 3 0 1
After:  [3, 1, 0, 1]

Before: [2, 2, 3, 2]
4 0 3 0
After:  [1, 2, 3, 2]

Before: [2, 0, 2, 1]
7 3 2 1
After:  [2, 1, 2, 1]

Before: [1, 1, 2, 2]
9 0 2 2
After:  [1, 1, 0, 2]

Before: [0, 1, 3, 2]
6 3 3 2
After:  [0, 1, 0, 2]

Before: [3, 3, 0, 2]
6 3 3 3
After:  [3, 3, 0, 0]

Before: [3, 1, 3, 1]
11 0 2 2
After:  [3, 1, 1, 1]

Before: [0, 1, 2, 1]
7 3 2 3
After:  [0, 1, 2, 1]

Before: [1, 2, 2, 1]
7 3 2 1
After:  [1, 1, 2, 1]

Before: [3, 1, 0, 2]
10 1 3 2
After:  [3, 1, 0, 2]

Before: [0, 1, 3, 2]
14 0 0 2
After:  [0, 1, 0, 2]

Before: [0, 3, 0, 2]
14 0 0 1
After:  [0, 0, 0, 2]

Before: [0, 1, 2, 1]
1 1 2 3
After:  [0, 1, 2, 0]

Before: [1, 1, 2, 1]
9 0 2 1
After:  [1, 0, 2, 1]

Before: [0, 1, 2, 2]
10 1 3 2
After:  [0, 1, 0, 2]

Before: [1, 0, 2, 2]
3 2 3 2
After:  [1, 0, 2, 2]

Before: [2, 3, 3, 1]
12 2 3 3
After:  [2, 3, 3, 0]

Before: [2, 0, 3, 1]
12 2 3 0
After:  [0, 0, 3, 1]

Before: [2, 1, 2, 1]
7 3 2 2
After:  [2, 1, 1, 1]

Before: [3, 3, 2, 2]
3 2 3 0
After:  [2, 3, 2, 2]

Before: [0, 1, 0, 1]
8 0 1 1
After:  [0, 0, 0, 1]

Before: [1, 1, 2, 1]
6 3 3 2
After:  [1, 1, 0, 1]

Before: [0, 1, 2, 2]
1 1 2 0
After:  [0, 1, 2, 2]

Before: [3, 3, 1, 3]
2 2 3 2
After:  [3, 3, 0, 3]

Before: [3, 2, 1, 3]
5 3 3 1
After:  [3, 3, 1, 3]

Before: [2, 1, 2, 2]
4 0 3 0
After:  [1, 1, 2, 2]

Before: [3, 3, 2, 2]
13 2 2 2
After:  [3, 3, 1, 2]

Before: [2, 1, 3, 2]
4 0 3 2
After:  [2, 1, 1, 2]

Before: [3, 0, 2, 2]
3 2 3 1
After:  [3, 2, 2, 2]

Before: [2, 0, 1, 2]
4 0 3 3
After:  [2, 0, 1, 1]

Before: [3, 2, 2, 0]
5 2 2 3
After:  [3, 2, 2, 2]

Before: [0, 0, 3, 3]
5 3 3 3
After:  [0, 0, 3, 3]

Before: [0, 1, 0, 3]
13 3 1 0
After:  [0, 1, 0, 3]

Before: [2, 2, 3, 2]
4 0 3 2
After:  [2, 2, 1, 2]

Before: [0, 3, 0, 1]
14 0 0 2
After:  [0, 3, 0, 1]

Before: [3, 3, 3, 0]
11 0 0 2
After:  [3, 3, 1, 0]

Before: [0, 3, 3, 3]
14 0 0 1
After:  [0, 0, 3, 3]

Before: [2, 2, 1, 1]
6 3 3 2
After:  [2, 2, 0, 1]

Before: [3, 2, 0, 3]
5 3 3 0
After:  [3, 2, 0, 3]

Before: [2, 2, 2, 3]
2 1 3 1
After:  [2, 0, 2, 3]

Before: [2, 3, 2, 2]
3 2 3 1
After:  [2, 2, 2, 2]

Before: [0, 1, 2, 1]
7 3 2 1
After:  [0, 1, 2, 1]

Before: [0, 1, 2, 2]
3 2 3 1
After:  [0, 2, 2, 2]

Before: [3, 1, 2, 0]
0 1 0 2
After:  [3, 1, 1, 0]

Before: [2, 2, 2, 0]
0 2 0 1
After:  [2, 2, 2, 0]

Before: [1, 1, 3, 0]
15 1 0 0
After:  [1, 1, 3, 0]

Before: [0, 3, 0, 3]
5 3 3 0
After:  [3, 3, 0, 3]

Before: [3, 3, 3, 3]
0 3 0 0
After:  [3, 3, 3, 3]

Before: [3, 0, 2, 0]
5 2 2 2
After:  [3, 0, 2, 0]

Before: [2, 3, 2, 2]
6 3 3 0
After:  [0, 3, 2, 2]

Before: [1, 0, 2, 3]
9 0 2 0
After:  [0, 0, 2, 3]

Before: [2, 3, 2, 0]
5 2 2 1
After:  [2, 2, 2, 0]

Before: [3, 3, 3, 1]
12 2 3 3
After:  [3, 3, 3, 0]

Before: [1, 1, 1, 3]
2 2 3 2
After:  [1, 1, 0, 3]

Before: [3, 1, 1, 2]
11 0 0 2
After:  [3, 1, 1, 2]

Before: [1, 1, 0, 2]
15 1 0 3
After:  [1, 1, 0, 1]

Before: [1, 1, 1, 1]
15 1 0 2
After:  [1, 1, 1, 1]

Before: [0, 1, 0, 3]
2 1 3 2
After:  [0, 1, 0, 3]

Before: [2, 0, 2, 2]
3 2 3 2
After:  [2, 0, 2, 2]

Before: [0, 3, 3, 3]
11 2 2 3
After:  [0, 3, 3, 1]

Before: [0, 1, 2, 2]
3 2 3 3
After:  [0, 1, 2, 2]

Before: [0, 3, 3, 0]
8 0 1 1
After:  [0, 0, 3, 0]

Before: [3, 1, 3, 2]
10 1 3 1
After:  [3, 0, 3, 2]

Before: [3, 2, 2, 3]
12 2 1 2
After:  [3, 2, 1, 3]

Before: [3, 2, 2, 0]
5 2 2 0
After:  [2, 2, 2, 0]

Before: [3, 1, 1, 2]
10 1 3 1
After:  [3, 0, 1, 2]

Before: [3, 0, 3, 1]
11 0 2 2
After:  [3, 0, 1, 1]

Before: [3, 1, 0, 3]
0 1 0 1
After:  [3, 1, 0, 3]

Before: [0, 1, 2, 1]
7 3 2 2
After:  [0, 1, 1, 1]

Before: [2, 1, 2, 0]
12 2 0 1
After:  [2, 1, 2, 0]

Before: [0, 1, 0, 2]
14 0 0 2
After:  [0, 1, 0, 2]

Before: [2, 3, 2, 1]
0 2 0 3
After:  [2, 3, 2, 2]

Before: [1, 1, 0, 2]
10 1 3 1
After:  [1, 0, 0, 2]

Before: [3, 1, 2, 3]
13 3 3 2
After:  [3, 1, 1, 3]

Before: [2, 3, 2, 3]
0 2 0 1
After:  [2, 2, 2, 3]

Before: [3, 1, 2, 3]
1 1 2 3
After:  [3, 1, 2, 0]

Before: [2, 2, 1, 2]
4 0 3 0
After:  [1, 2, 1, 2]

Before: [0, 0, 3, 1]
14 0 0 0
After:  [0, 0, 3, 1]

Before: [3, 2, 3, 0]
11 0 2 3
After:  [3, 2, 3, 1]

Before: [2, 1, 1, 1]
11 0 0 1
After:  [2, 1, 1, 1]

Before: [3, 2, 2, 2]
12 2 1 2
After:  [3, 2, 1, 2]

Before: [0, 1, 3, 2]
10 1 3 2
After:  [0, 1, 0, 2]

Before: [1, 1, 2, 2]
15 1 0 1
After:  [1, 1, 2, 2]

Before: [0, 0, 3, 3]
8 0 2 3
After:  [0, 0, 3, 0]

Before: [2, 0, 0, 0]
11 0 0 1
After:  [2, 1, 0, 0]

Before: [3, 2, 3, 3]
0 3 0 2
After:  [3, 2, 3, 3]

Before: [2, 2, 2, 2]
4 0 3 2
After:  [2, 2, 1, 2]

Before: [1, 1, 1, 3]
15 1 0 0
After:  [1, 1, 1, 3]

Before: [0, 1, 2, 0]
8 0 1 0
After:  [0, 1, 2, 0]

Before: [3, 1, 3, 1]
12 2 3 0
After:  [0, 1, 3, 1]

Before: [1, 1, 2, 2]
3 2 3 2
After:  [1, 1, 2, 2]

Before: [3, 1, 2, 2]
3 2 3 1
After:  [3, 2, 2, 2]

Before: [1, 1, 0, 1]
15 1 0 0
After:  [1, 1, 0, 1]

Before: [2, 3, 1, 3]
2 2 3 3
After:  [2, 3, 1, 0]

Before: [2, 0, 3, 1]
12 2 3 2
After:  [2, 0, 0, 1]

Before: [2, 0, 0, 3]
8 1 0 0
After:  [0, 0, 0, 3]

Before: [1, 1, 2, 0]
15 1 0 0
After:  [1, 1, 2, 0]

Before: [3, 0, 0, 0]
8 2 0 3
After:  [3, 0, 0, 0]

Before: [2, 0, 2, 2]
0 2 0 3
After:  [2, 0, 2, 2]

Before: [2, 0, 2, 2]
4 0 3 3
After:  [2, 0, 2, 1]

Before: [0, 2, 2, 1]
7 3 2 2
After:  [0, 2, 1, 1]

Before: [2, 2, 0, 1]
6 3 3 1
After:  [2, 0, 0, 1]

Before: [2, 1, 1, 2]
10 1 3 2
After:  [2, 1, 0, 2]

Before: [2, 0, 1, 3]
2 2 3 0
After:  [0, 0, 1, 3]

Before: [2, 0, 0, 2]
4 0 3 3
After:  [2, 0, 0, 1]

Before: [1, 2, 2, 2]
3 2 3 0
After:  [2, 2, 2, 2]

Before: [0, 3, 2, 1]
8 0 1 0
After:  [0, 3, 2, 1]

Before: [0, 2, 2, 3]
8 0 3 2
After:  [0, 2, 0, 3]

Before: [0, 2, 2, 0]
5 2 2 3
After:  [0, 2, 2, 2]

Before: [3, 0, 3, 1]
12 2 3 0
After:  [0, 0, 3, 1]

Before: [0, 2, 1, 3]
2 1 3 0
After:  [0, 2, 1, 3]

Before: [1, 1, 2, 2]
1 1 2 0
After:  [0, 1, 2, 2]

Before: [2, 0, 2, 0]
0 2 0 2
After:  [2, 0, 2, 0]

Before: [0, 1, 3, 2]
10 1 3 3
After:  [0, 1, 3, 0]

Before: [1, 1, 2, 0]
15 1 0 3
After:  [1, 1, 2, 1]

Before: [2, 1, 2, 3]
1 1 2 0
After:  [0, 1, 2, 3]

Before: [1, 3, 1, 3]
2 2 3 3
After:  [1, 3, 1, 0]

Before: [2, 3, 2, 0]
12 2 0 1
After:  [2, 1, 2, 0]

Before: [3, 0, 3, 3]
12 3 0 2
After:  [3, 0, 1, 3]

Before: [3, 1, 1, 3]
2 2 3 0
After:  [0, 1, 1, 3]

Before: [3, 2, 2, 3]
2 1 3 3
After:  [3, 2, 2, 0]

Before: [2, 2, 2, 1]
7 3 2 3
After:  [2, 2, 2, 1]

Before: [1, 1, 1, 1]
6 2 3 3
After:  [1, 1, 1, 0]

Before: [2, 3, 2, 3]
5 2 2 2
After:  [2, 3, 2, 3]

Before: [2, 3, 2, 2]
4 0 3 0
After:  [1, 3, 2, 2]

Before: [0, 1, 2, 1]
13 2 2 2
After:  [0, 1, 1, 1]

Before: [1, 3, 2, 2]
9 0 2 3
After:  [1, 3, 2, 0]

Before: [0, 0, 0, 3]
14 0 0 1
After:  [0, 0, 0, 3]

Before: [0, 2, 0, 0]
14 0 0 2
After:  [0, 2, 0, 0]

Before: [1, 3, 2, 1]
9 0 2 3
After:  [1, 3, 2, 0]

Before: [3, 2, 2, 3]
13 3 2 1
After:  [3, 0, 2, 3]

Before: [1, 0, 2, 0]
9 0 2 0
After:  [0, 0, 2, 0]

Before: [0, 3, 2, 1]
5 2 2 1
After:  [0, 2, 2, 1]

Before: [3, 1, 2, 3]
1 1 2 1
After:  [3, 0, 2, 3]

Before: [0, 3, 1, 2]
14 0 0 2
After:  [0, 3, 0, 2]

Before: [2, 1, 1, 3]
13 3 2 1
After:  [2, 0, 1, 3]

Before: [0, 0, 2, 2]
6 3 3 3
After:  [0, 0, 2, 0]

Before: [0, 1, 3, 0]
8 0 2 0
After:  [0, 1, 3, 0]

Before: [1, 1, 1, 2]
15 1 0 2
After:  [1, 1, 1, 2]

Before: [0, 1, 3, 2]
8 0 2 3
After:  [0, 1, 3, 0]

Before: [1, 1, 3, 3]
15 1 0 0
After:  [1, 1, 3, 3]

Before: [2, 2, 1, 2]
11 0 1 0
After:  [1, 2, 1, 2]

Before: [1, 0, 2, 2]
3 2 3 0
After:  [2, 0, 2, 2]

Before: [0, 0, 2, 2]
3 2 3 0
After:  [2, 0, 2, 2]

Before: [2, 2, 2, 2]
3 2 3 0
After:  [2, 2, 2, 2]

Before: [2, 2, 2, 0]
12 2 0 0
After:  [1, 2, 2, 0]

Before: [0, 1, 1, 2]
10 1 3 0
After:  [0, 1, 1, 2]

Before: [0, 0, 0, 2]
14 0 0 3
After:  [0, 0, 0, 0]

Before: [1, 3, 3, 3]
13 3 3 2
After:  [1, 3, 1, 3]

Before: [3, 2, 2, 3]
5 3 3 0
After:  [3, 2, 2, 3]

Before: [1, 1, 3, 1]
15 1 0 1
After:  [1, 1, 3, 1]

Before: [2, 3, 2, 2]
4 0 3 2
After:  [2, 3, 1, 2]

Before: [3, 3, 2, 3]
0 3 0 1
After:  [3, 3, 2, 3]

Before: [1, 1, 2, 0]
9 0 2 3
After:  [1, 1, 2, 0]

Before: [1, 2, 2, 0]
9 0 2 2
After:  [1, 2, 0, 0]

Before: [0, 3, 2, 1]
7 3 2 1
After:  [0, 1, 2, 1]

Before: [2, 0, 2, 3]
5 2 2 0
After:  [2, 0, 2, 3]

Before: [2, 0, 0, 2]
4 0 3 2
After:  [2, 0, 1, 2]

Before: [3, 3, 1, 1]
0 3 0 2
After:  [3, 3, 1, 1]

Before: [0, 3, 3, 0]
14 0 0 1
After:  [0, 0, 3, 0]

Before: [3, 2, 1, 1]
0 3 0 1
After:  [3, 1, 1, 1]

Before: [1, 1, 2, 2]
15 1 0 0
After:  [1, 1, 2, 2]

Before: [2, 2, 1, 2]
6 3 3 0
After:  [0, 2, 1, 2]

Before: [2, 1, 2, 2]
4 0 3 2
After:  [2, 1, 1, 2]

Before: [1, 1, 1, 2]
10 1 3 1
After:  [1, 0, 1, 2]

Before: [1, 1, 0, 0]
15 1 0 0
After:  [1, 1, 0, 0]

Before: [1, 2, 2, 3]
9 0 2 1
After:  [1, 0, 2, 3]

Before: [2, 0, 1, 2]
4 0 3 0
After:  [1, 0, 1, 2]

Before: [1, 3, 3, 3]
12 3 2 3
After:  [1, 3, 3, 1]

Before: [3, 1, 1, 2]
0 1 0 0
After:  [1, 1, 1, 2]

Before: [3, 0, 2, 1]
0 3 0 3
After:  [3, 0, 2, 1]

Before: [3, 3, 0, 1]
0 3 0 0
After:  [1, 3, 0, 1]

Before: [1, 3, 3, 2]
6 3 3 2
After:  [1, 3, 0, 2]

Before: [0, 2, 1, 0]
8 0 2 2
After:  [0, 2, 0, 0]

Before: [2, 2, 2, 0]
12 2 0 2
After:  [2, 2, 1, 0]

Before: [2, 1, 2, 3]
5 2 2 0
After:  [2, 1, 2, 3]

Before: [0, 0, 1, 3]
5 3 3 3
After:  [0, 0, 1, 3]

Before: [1, 0, 2, 3]
13 2 2 2
After:  [1, 0, 1, 3]

Before: [1, 1, 2, 3]
15 1 0 2
After:  [1, 1, 1, 3]

Before: [2, 2, 2, 2]
3 2 3 3
After:  [2, 2, 2, 2]

Before: [1, 1, 0, 1]
15 1 0 2
After:  [1, 1, 1, 1]

Before: [1, 1, 2, 3]
15 1 0 0
After:  [1, 1, 2, 3]

Before: [1, 1, 0, 3]
2 1 3 1
After:  [1, 0, 0, 3]

Before: [2, 0, 2, 1]
12 2 0 1
After:  [2, 1, 2, 1]

Before: [0, 2, 1, 2]
8 0 1 1
After:  [0, 0, 1, 2]

Before: [1, 1, 2, 3]
1 1 2 1
After:  [1, 0, 2, 3]

Before: [0, 3, 2, 3]
2 2 3 0
After:  [0, 3, 2, 3]

Before: [0, 0, 2, 3]
13 3 3 2
After:  [0, 0, 1, 3]

Before: [2, 1, 3, 2]
10 1 3 1
After:  [2, 0, 3, 2]

Before: [1, 1, 2, 3]
2 1 3 3
After:  [1, 1, 2, 0]

Before: [0, 0, 3, 2]
14 0 0 2
After:  [0, 0, 0, 2]

Before: [0, 2, 2, 1]
7 3 2 3
After:  [0, 2, 2, 1]

Before: [1, 0, 3, 2]
11 2 2 3
After:  [1, 0, 3, 1]

Before: [3, 2, 3, 3]
11 0 0 1
After:  [3, 1, 3, 3]

Before: [0, 3, 2, 2]
14 0 0 2
After:  [0, 3, 0, 2]

Before: [3, 2, 1, 1]
6 3 3 2
After:  [3, 2, 0, 1]

Before: [0, 2, 2, 3]
2 2 3 0
After:  [0, 2, 2, 3]

Before: [1, 2, 1, 2]
6 3 3 3
After:  [1, 2, 1, 0]

Before: [2, 1, 2, 1]
7 3 2 1
After:  [2, 1, 2, 1]

Before: [1, 1, 1, 2]
10 1 3 2
After:  [1, 1, 0, 2]

Before: [0, 0, 1, 1]
14 0 0 1
After:  [0, 0, 1, 1]

Before: [3, 3, 3, 1]
11 0 2 1
After:  [3, 1, 3, 1]

Before: [2, 1, 2, 2]
12 2 0 2
After:  [2, 1, 1, 2]

Before: [1, 2, 2, 1]
7 3 2 0
After:  [1, 2, 2, 1]

Before: [1, 2, 2, 2]
9 0 2 1
After:  [1, 0, 2, 2]

Before: [3, 3, 2, 1]
7 3 2 3
After:  [3, 3, 2, 1]

Before: [2, 1, 1, 2]
6 3 3 3
After:  [2, 1, 1, 0]

Before: [2, 2, 1, 3]
2 2 3 2
After:  [2, 2, 0, 3]

Before: [3, 2, 2, 2]
3 2 3 1
After:  [3, 2, 2, 2]

Before: [2, 2, 2, 1]
0 2 0 0
After:  [2, 2, 2, 1]

Before: [0, 1, 3, 1]
14 0 0 1
After:  [0, 0, 3, 1]

Before: [2, 0, 3, 1]
8 1 0 0
After:  [0, 0, 3, 1]

Before: [2, 3, 0, 2]
4 0 3 2
After:  [2, 3, 1, 2]

Before: [2, 0, 2, 2]
3 2 3 1
After:  [2, 2, 2, 2]

Before: [0, 0, 3, 2]
8 0 2 2
After:  [0, 0, 0, 2]

Before: [3, 1, 1, 2]
10 1 3 2
After:  [3, 1, 0, 2]

Before: [3, 2, 2, 1]
7 3 2 2
After:  [3, 2, 1, 1]

Before: [2, 2, 2, 2]
4 0 3 1
After:  [2, 1, 2, 2]

Before: [1, 1, 2, 2]
9 0 2 1
After:  [1, 0, 2, 2]

Before: [3, 0, 2, 2]
5 2 2 1
After:  [3, 2, 2, 2]

Before: [0, 2, 0, 1]
14 0 0 0
After:  [0, 2, 0, 1]

Before: [2, 2, 2, 1]
5 2 2 0
After:  [2, 2, 2, 1]

Before: [2, 1, 2, 3]
1 1 2 1
After:  [2, 0, 2, 3]

Before: [2, 3, 0, 2]
4 0 3 1
After:  [2, 1, 0, 2]

Before: [2, 3, 2, 1]
7 3 2 0
After:  [1, 3, 2, 1]

Before: [2, 0, 2, 2]
12 2 0 0
After:  [1, 0, 2, 2]

Before: [1, 2, 2, 2]
3 2 3 2
After:  [1, 2, 2, 2]

Before: [0, 0, 2, 1]
7 3 2 0
After:  [1, 0, 2, 1]

Before: [2, 2, 3, 3]
11 2 2 3
After:  [2, 2, 3, 1]

Before: [3, 3, 2, 0]
5 2 2 2
After:  [3, 3, 2, 0]

Before: [3, 2, 2, 2]
3 2 3 2
After:  [3, 2, 2, 2]

Before: [2, 3, 2, 2]
4 0 3 3
After:  [2, 3, 2, 1]

Before: [2, 1, 1, 2]
11 0 0 1
After:  [2, 1, 1, 2]

Before: [0, 0, 2, 1]
7 3 2 2
After:  [0, 0, 1, 1]

Before: [0, 2, 1, 0]
14 0 0 3
After:  [0, 2, 1, 0]

Before: [1, 1, 2, 0]
15 1 0 1
After:  [1, 1, 2, 0]

Before: [0, 1, 2, 3]
1 1 2 1
After:  [0, 0, 2, 3]

Before: [0, 3, 1, 0]
14 0 0 3
After:  [0, 3, 1, 0]

Before: [0, 2, 3, 2]
8 0 3 0
After:  [0, 2, 3, 2]

Before: [0, 1, 3, 3]
13 0 0 0
After:  [1, 1, 3, 3]

Before: [2, 1, 2, 0]
1 1 2 0
After:  [0, 1, 2, 0]

Before: [3, 0, 1, 1]
11 0 0 0
After:  [1, 0, 1, 1]

Before: [0, 2, 1, 3]
14 0 0 3
After:  [0, 2, 1, 0]

Before: [0, 2, 2, 1]
14 0 0 0
After:  [0, 2, 2, 1]

Before: [0, 2, 3, 0]
14 0 0 1
After:  [0, 0, 3, 0]

Before: [2, 2, 2, 2]
3 2 3 1
After:  [2, 2, 2, 2]

Before: [3, 0, 2, 1]
7 3 2 3
After:  [3, 0, 2, 1]

Before: [2, 2, 2, 1]
6 3 3 0
After:  [0, 2, 2, 1]

Before: [2, 1, 3, 2]
10 1 3 2
After:  [2, 1, 0, 2]

Before: [2, 1, 2, 2]
5 2 2 3
After:  [2, 1, 2, 2]

Before: [3, 2, 1, 1]
0 3 0 3
After:  [3, 2, 1, 1]

Before: [2, 1, 2, 3]
1 1 2 3
After:  [2, 1, 2, 0]

Before: [2, 3, 2, 0]
0 2 0 1
After:  [2, 2, 2, 0]

Before: [3, 0, 3, 1]
11 0 0 3
After:  [3, 0, 3, 1]

Before: [2, 3, 1, 1]
6 2 3 2
After:  [2, 3, 0, 1]

Before: [2, 0, 3, 2]
11 2 2 0
After:  [1, 0, 3, 2]

Before: [0, 1, 1, 2]
10 1 3 3
After:  [0, 1, 1, 0]

Before: [0, 1, 3, 3]
12 3 2 2
After:  [0, 1, 1, 3]

Before: [0, 1, 1, 2]
14 0 0 1
After:  [0, 0, 1, 2]

Before: [0, 1, 2, 3]
1 1 2 2
After:  [0, 1, 0, 3]

Before: [1, 1, 2, 2]
1 1 2 3
After:  [1, 1, 2, 0]

Before: [0, 1, 0, 1]
14 0 0 3
After:  [0, 1, 0, 0]

Before: [2, 0, 0, 1]
6 3 3 1
After:  [2, 0, 0, 1]

Before: [1, 2, 1, 3]
13 3 2 3
After:  [1, 2, 1, 0]

Before: [2, 1, 2, 1]
6 3 3 3
After:  [2, 1, 2, 0]

Before: [0, 1, 0, 2]
6 3 3 3
After:  [0, 1, 0, 0]

Before: [3, 1, 0, 2]
8 2 0 0
After:  [0, 1, 0, 2]

Before: [1, 1, 3, 3]
12 3 2 0
After:  [1, 1, 3, 3]

Before: [0, 1, 2, 1]
5 2 2 3
After:  [0, 1, 2, 2]

Before: [1, 0, 3, 0]
11 2 2 0
After:  [1, 0, 3, 0]

Before: [3, 3, 2, 1]
5 2 2 0
After:  [2, 3, 2, 1]

Before: [0, 2, 2, 3]
14 0 0 3
After:  [0, 2, 2, 0]

Before: [3, 0, 1, 3]
2 2 3 3
After:  [3, 0, 1, 0]

Before: [2, 3, 3, 2]
4 0 3 3
After:  [2, 3, 3, 1]

Before: [1, 1, 3, 2]
15 1 0 2
After:  [1, 1, 1, 2]

Before: [1, 1, 2, 2]
9 0 2 0
After:  [0, 1, 2, 2]

Before: [2, 1, 2, 2]
10 1 3 0
After:  [0, 1, 2, 2]

Before: [3, 1, 2, 0]
1 1 2 3
After:  [3, 1, 2, 0]

Before: [0, 1, 1, 3]
14 0 0 1
After:  [0, 0, 1, 3]

Before: [1, 1, 2, 3]
13 3 1 0
After:  [0, 1, 2, 3]

Before: [1, 1, 1, 2]
6 3 3 1
After:  [1, 0, 1, 2]

Before: [2, 1, 2, 2]
5 2 2 1
After:  [2, 2, 2, 2]

Before: [0, 2, 2, 0]
14 0 0 0
After:  [0, 2, 2, 0]

Before: [0, 0, 2, 2]
8 0 2 2
After:  [0, 0, 0, 2]

Before: [0, 1, 2, 0]
14 0 0 3
After:  [0, 1, 2, 0]

Before: [1, 3, 2, 2]
9 0 2 1
After:  [1, 0, 2, 2]

Before: [1, 2, 2, 0]
12 2 1 0
After:  [1, 2, 2, 0]

Before: [2, 1, 3, 2]
4 0 3 0
After:  [1, 1, 3, 2]

Before: [0, 1, 2, 1]
1 1 2 1
After:  [0, 0, 2, 1]

Before: [3, 0, 3, 3]
11 0 0 0
After:  [1, 0, 3, 3]

Before: [0, 3, 2, 1]
7 3 2 0
After:  [1, 3, 2, 1]

Before: [3, 1, 1, 3]
12 3 0 0
After:  [1, 1, 1, 3]

Before: [0, 2, 2, 1]
7 3 2 0
After:  [1, 2, 2, 1]

Before: [1, 1, 3, 2]
10 1 3 3
After:  [1, 1, 3, 0]

Before: [1, 1, 2, 1]
1 1 2 1
After:  [1, 0, 2, 1]

Before: [2, 0, 1, 2]
6 3 3 0
After:  [0, 0, 1, 2]

Before: [2, 0, 2, 0]
0 2 0 3
After:  [2, 0, 2, 2]

Before: [0, 2, 3, 3]
13 3 3 0
After:  [1, 2, 3, 3]

Before: [1, 1, 0, 3]
15 1 0 3
After:  [1, 1, 0, 1]

Before: [2, 0, 1, 1]
11 0 0 2
After:  [2, 0, 1, 1]

Before: [2, 3, 0, 2]
6 3 3 2
After:  [2, 3, 0, 2]

Before: [3, 1, 1, 2]
10 1 3 0
After:  [0, 1, 1, 2]

Before: [2, 3, 0, 1]
6 3 3 1
After:  [2, 0, 0, 1]

Before: [3, 1, 2, 1]
1 1 2 0
After:  [0, 1, 2, 1]

Before: [1, 1, 0, 2]
10 1 3 0
After:  [0, 1, 0, 2]

Before: [2, 1, 2, 1]
1 1 2 2
After:  [2, 1, 0, 1]

Before: [2, 1, 0, 2]
10 1 3 2
After:  [2, 1, 0, 2]

Before: [1, 1, 2, 2]
15 1 0 2
After:  [1, 1, 1, 2]

Before: [2, 3, 0, 2]
4 0 3 0
After:  [1, 3, 0, 2]

Before: [1, 1, 2, 1]
1 1 2 0
After:  [0, 1, 2, 1]

Before: [3, 1, 2, 3]
13 3 3 0
After:  [1, 1, 2, 3]

Before: [3, 0, 2, 3]
0 3 0 1
After:  [3, 3, 2, 3]

Before: [0, 1, 2, 1]
1 1 2 0
After:  [0, 1, 2, 1]

Before: [2, 2, 1, 2]
4 0 3 3
After:  [2, 2, 1, 1]

Before: [3, 3, 0, 3]
11 0 0 0
After:  [1, 3, 0, 3]

Before: [3, 3, 2, 2]
3 2 3 1
After:  [3, 2, 2, 2]

Before: [1, 3, 2, 3]
2 2 3 0
After:  [0, 3, 2, 3]

Before: [1, 2, 2, 3]
9 0 2 0
After:  [0, 2, 2, 3]

Before: [2, 1, 2, 0]
1 1 2 2
After:  [2, 1, 0, 0]

Before: [3, 1, 2, 1]
1 1 2 2
After:  [3, 1, 0, 1]

Before: [3, 1, 0, 2]
10 1 3 1
After:  [3, 0, 0, 2]

Before: [3, 0, 3, 1]
12 2 3 2
After:  [3, 0, 0, 1]

Before: [1, 0, 2, 2]
9 0 2 3
After:  [1, 0, 2, 0]

Before: [0, 2, 2, 3]
5 3 3 1
After:  [0, 3, 2, 3]

Before: [2, 0, 2, 1]
12 2 0 2
After:  [2, 0, 1, 1]

Before: [2, 3, 1, 2]
11 0 0 3
After:  [2, 3, 1, 1]

Before: [0, 2, 2, 2]
14 0 0 0
After:  [0, 2, 2, 2]

Before: [1, 0, 3, 0]
11 2 2 2
After:  [1, 0, 1, 0]

Before: [0, 1, 2, 3]
14 0 0 0
After:  [0, 1, 2, 3]

Before: [2, 2, 3, 1]
6 3 3 3
After:  [2, 2, 3, 0]

Before: [1, 1, 2, 2]
10 1 3 0
After:  [0, 1, 2, 2]

Before: [3, 1, 2, 2]
6 3 3 1
After:  [3, 0, 2, 2]

Before: [1, 2, 3, 3]
13 3 1 2
After:  [1, 2, 0, 3]

Before: [1, 2, 1, 3]
2 2 3 2
After:  [1, 2, 0, 3]

Before: [3, 1, 0, 2]
10 1 3 3
After:  [3, 1, 0, 0]

Before: [3, 1, 3, 3]
11 2 2 3
After:  [3, 1, 3, 1]

Before: [2, 2, 1, 2]
11 0 0 2
After:  [2, 2, 1, 2]

Before: [3, 1, 3, 2]
10 1 3 0
After:  [0, 1, 3, 2]

Before: [3, 0, 2, 2]
3 2 3 2
After:  [3, 0, 2, 2]

Before: [1, 1, 0, 3]
2 1 3 0
After:  [0, 1, 0, 3]

Before: [2, 1, 2, 2]
1 1 2 3
After:  [2, 1, 2, 0]

Before: [2, 2, 2, 3]
2 2 3 2
After:  [2, 2, 0, 3]

Before: [3, 0, 2, 1]
7 3 2 1
After:  [3, 1, 2, 1]

Before: [1, 1, 2, 3]
9 0 2 0
After:  [0, 1, 2, 3]

Before: [3, 2, 2, 3]
2 1 3 2
After:  [3, 2, 0, 3]

Before: [2, 1, 2, 2]
4 0 3 1
After:  [2, 1, 2, 2]

Before: [2, 0, 2, 2]
4 0 3 0
After:  [1, 0, 2, 2]

Before: [2, 3, 1, 2]
4 0 3 2
After:  [2, 3, 1, 2]

Before: [0, 2, 1, 0]
8 0 2 3
After:  [0, 2, 1, 0]

Before: [3, 0, 1, 1]
6 2 3 3
After:  [3, 0, 1, 0]

Before: [1, 2, 2, 0]
12 2 1 2
After:  [1, 2, 1, 0]

Before: [1, 3, 2, 1]
9 0 2 2
After:  [1, 3, 0, 1]

Before: [1, 1, 1, 3]
15 1 0 1
After:  [1, 1, 1, 3]

Before: [0, 0, 0, 3]
8 0 3 2
After:  [0, 0, 0, 3]

Before: [3, 1, 2, 0]
1 1 2 2
After:  [3, 1, 0, 0]

Before: [2, 1, 2, 2]
10 1 3 2
After:  [2, 1, 0, 2]

Before: [1, 1, 0, 1]
15 1 0 1
After:  [1, 1, 0, 1]

Before: [1, 1, 3, 0]
13 2 1 0
After:  [0, 1, 3, 0]

Before: [0, 0, 2, 1]
7 3 2 1
After:  [0, 1, 2, 1]

Before: [2, 1, 3, 0]
11 0 0 3
After:  [2, 1, 3, 1]

Before: [3, 1, 3, 0]
0 1 0 3
After:  [3, 1, 3, 1]

Before: [1, 1, 3, 3]
13 2 1 1
After:  [1, 0, 3, 3]

Before: [1, 3, 2, 3]
9 0 2 3
After:  [1, 3, 2, 0]

Before: [0, 3, 1, 3]
8 0 3 1
After:  [0, 0, 1, 3]

Before: [2, 1, 0, 2]
4 0 3 3
After:  [2, 1, 0, 1]

Before: [2, 0, 2, 2]
3 2 3 3
After:  [2, 0, 2, 2]

Before: [2, 3, 1, 0]
11 0 0 0
After:  [1, 3, 1, 0]

Before: [3, 2, 3, 2]
11 0 0 2
After:  [3, 2, 1, 2]

Before: [2, 1, 2, 2]
4 0 3 3
After:  [2, 1, 2, 1]

Before: [3, 0, 3, 3]
5 3 3 1
After:  [3, 3, 3, 3]

Before: [2, 2, 2, 1]
7 3 2 1
After:  [2, 1, 2, 1]

Before: [2, 1, 2, 2]
3 2 3 2
After:  [2, 1, 2, 2]

Before: [1, 1, 2, 1]
7 3 2 2
After:  [1, 1, 1, 1]

Before: [2, 0, 2, 2]
5 2 2 0
After:  [2, 0, 2, 2]

Before: [2, 1, 3, 2]
4 0 3 1
After:  [2, 1, 3, 2]

Before: [0, 2, 2, 2]
3 2 3 3
After:  [0, 2, 2, 2]

Before: [0, 3, 2, 2]
14 0 0 0
After:  [0, 3, 2, 2]

Before: [2, 1, 3, 2]
10 1 3 0
After:  [0, 1, 3, 2]

Before: [3, 1, 2, 1]
7 3 2 0
After:  [1, 1, 2, 1]

Before: [2, 2, 1, 2]
4 0 3 2
After:  [2, 2, 1, 2]

Before: [3, 2, 1, 1]
11 0 0 2
After:  [3, 2, 1, 1]

Before: [0, 3, 3, 1]
13 0 0 1
After:  [0, 1, 3, 1]

Before: [3, 0, 2, 3]
13 3 2 2
After:  [3, 0, 0, 3]

Before: [0, 0, 0, 1]
6 3 3 2
After:  [0, 0, 0, 1]

Before: [2, 3, 1, 2]
4 0 3 1
After:  [2, 1, 1, 2]

Before: [2, 3, 2, 3]
0 2 0 3
After:  [2, 3, 2, 2]

Before: [1, 3, 2, 0]
9 0 2 0
After:  [0, 3, 2, 0]

Before: [0, 1, 0, 2]
6 3 3 0
After:  [0, 1, 0, 2]

Before: [0, 1, 2, 1]
1 1 2 2
After:  [0, 1, 0, 1]

Before: [1, 3, 2, 1]
7 3 2 0
After:  [1, 3, 2, 1]

Before: [0, 3, 2, 1]
8 0 2 1
After:  [0, 0, 2, 1]

Before: [2, 2, 0, 3]
5 3 3 1
After:  [2, 3, 0, 3]

Before: [1, 1, 2, 2]
3 2 3 3
After:  [1, 1, 2, 2]

Before: [0, 0, 3, 2]
11 2 2 1
After:  [0, 1, 3, 2]

Before: [0, 3, 1, 3]
2 2 3 3
After:  [0, 3, 1, 0]

Before: [3, 3, 3, 3]
11 2 0 0
After:  [1, 3, 3, 3]

Before: [2, 0, 0, 2]
4 0 3 0
After:  [1, 0, 0, 2]

Before: [0, 1, 2, 3]
2 2 3 1
After:  [0, 0, 2, 3]

Before: [2, 3, 2, 1]
7 3 2 2
After:  [2, 3, 1, 1]

Before: [3, 1, 2, 2]
10 1 3 0
After:  [0, 1, 2, 2]

Before: [0, 2, 3, 3]
14 0 0 3
After:  [0, 2, 3, 0]

Before: [3, 2, 2, 3]
13 3 1 1
After:  [3, 0, 2, 3]

Before: [1, 1, 2, 2]
9 0 2 3
After:  [1, 1, 2, 0]

Before: [0, 2, 1, 3]
14 0 0 2
After:  [0, 2, 0, 3]

Before: [1, 0, 2, 1]
7 3 2 3
After:  [1, 0, 2, 1]

Before: [0, 3, 2, 1]
7 3 2 3
After:  [0, 3, 2, 1]

Before: [0, 1, 3, 2]
11 2 2 0
After:  [1, 1, 3, 2]

Before: [0, 0, 2, 0]
13 0 0 2
After:  [0, 0, 1, 0]

Before: [3, 1, 1, 3]
11 0 0 2
After:  [3, 1, 1, 3]

Before: [3, 2, 1, 3]
0 3 0 3
After:  [3, 2, 1, 3]

Before: [1, 2, 2, 0]
9 0 2 0
After:  [0, 2, 2, 0]

Before: [3, 0, 0, 3]
0 3 0 0
After:  [3, 0, 0, 3]

Before: [1, 0, 1, 3]
2 2 3 0
After:  [0, 0, 1, 3]

Before: [0, 0, 2, 1]
7 3 2 3
After:  [0, 0, 2, 1]

Before: [1, 1, 2, 2]
15 1 0 3
After:  [1, 1, 2, 1]

Before: [2, 1, 1, 3]
2 1 3 0
After:  [0, 1, 1, 3]

Before: [0, 2, 0, 2]
8 0 3 0
After:  [0, 2, 0, 2]

Before: [3, 1, 0, 3]
0 3 0 0
After:  [3, 1, 0, 3]

Before: [2, 3, 2, 3]
2 2 3 1
After:  [2, 0, 2, 3]

Before: [2, 1, 2, 3]
0 2 0 0
After:  [2, 1, 2, 3]

Before: [2, 0, 2, 3]
8 1 0 3
After:  [2, 0, 2, 0]

Before: [1, 1, 2, 3]
2 2 3 1
After:  [1, 0, 2, 3]

Before: [0, 0, 2, 2]
8 0 3 1
After:  [0, 0, 2, 2]

Before: [1, 0, 2, 1]
7 3 2 0
After:  [1, 0, 2, 1]

Before: [1, 3, 2, 3]
9 0 2 2
After:  [1, 3, 0, 3]

Before: [1, 1, 3, 3]
11 2 2 1
After:  [1, 1, 3, 3]

Before: [1, 1, 0, 3]
15 1 0 1
After:  [1, 1, 0, 3]

Before: [2, 3, 3, 2]
4 0 3 1
After:  [2, 1, 3, 2]

Before: [2, 1, 0, 1]
6 3 3 0
After:  [0, 1, 0, 1]

Before: [1, 1, 2, 2]
10 1 3 2
After:  [1, 1, 0, 2]

Before: [2, 0, 2, 1]
7 3 2 3
After:  [2, 0, 2, 1]

Before: [2, 3, 2, 2]
13 2 2 3
After:  [2, 3, 2, 1]

Before: [0, 1, 1, 0]
14 0 0 0
After:  [0, 1, 1, 0]

Before: [0, 1, 3, 2]
14 0 0 1
After:  [0, 0, 3, 2]

Before: [0, 3, 2, 3]
8 0 1 2
After:  [0, 3, 0, 3]

Before: [2, 3, 1, 3]
2 2 3 0
After:  [0, 3, 1, 3]

Before: [0, 0, 1, 1]
8 0 2 0
After:  [0, 0, 1, 1]

Before: [0, 1, 0, 2]
10 1 3 0
After:  [0, 1, 0, 2]

Before: [2, 3, 3, 3]
5 3 3 3
After:  [2, 3, 3, 3]

Before: [0, 3, 2, 1]
7 3 2 2
After:  [0, 3, 1, 1]

Before: [1, 0, 2, 3]
2 2 3 1
After:  [1, 0, 2, 3]

Before: [2, 1, 2, 1]
7 3 2 3
After:  [2, 1, 2, 1]

Before: [3, 1, 1, 1]
0 1 0 0
After:  [1, 1, 1, 1]

Before: [2, 3, 0, 3]
5 3 3 3
After:  [2, 3, 0, 3]

Before: [2, 0, 2, 0]
13 2 2 0
After:  [1, 0, 2, 0]

Before: [3, 2, 2, 3]
13 3 2 2
After:  [3, 2, 0, 3]

Before: [2, 0, 2, 1]
0 2 0 2
After:  [2, 0, 2, 1]

Before: [3, 1, 2, 0]
1 1 2 0
After:  [0, 1, 2, 0]

Before: [1, 2, 2, 1]
9 0 2 3
After:  [1, 2, 2, 0]

Before: [3, 0, 1, 1]
0 3 0 0
After:  [1, 0, 1, 1]

Before: [3, 1, 3, 3]
0 1 0 2
After:  [3, 1, 1, 3]

Before: [0, 1, 1, 3]
2 1 3 1
After:  [0, 0, 1, 3]

Before: [0, 3, 3, 3]
5 3 3 1
After:  [0, 3, 3, 3]

Before: [3, 3, 2, 2]
13 2 2 3
After:  [3, 3, 2, 1]

Before: [1, 1, 2, 1]
1 1 2 3
After:  [1, 1, 2, 0]

Before: [1, 1, 3, 2]
15 1 0 0
After:  [1, 1, 3, 2]

Before: [1, 0, 2, 2]
5 2 2 1
After:  [1, 2, 2, 2]

Before: [2, 2, 1, 1]
11 0 1 1
After:  [2, 1, 1, 1]

Before: [0, 0, 3, 1]
14 0 0 1
After:  [0, 0, 3, 1]

Before: [2, 1, 2, 2]
10 1 3 1
After:  [2, 0, 2, 2]

Before: [0, 1, 0, 2]
10 1 3 3
After:  [0, 1, 0, 0]

Before: [3, 1, 2, 2]
1 1 2 3
After:  [3, 1, 2, 0]

Before: [1, 0, 2, 1]
9 0 2 3
After:  [1, 0, 2, 0]

Before: [2, 1, 2, 2]
1 1 2 1
After:  [2, 0, 2, 2]

Before: [2, 3, 1, 2]
4 0 3 0
After:  [1, 3, 1, 2]

Before: [2, 1, 3, 3]
5 3 3 3
After:  [2, 1, 3, 3]

Before: [2, 2, 3, 3]
2 1 3 0
After:  [0, 2, 3, 3]

Before: [1, 1, 3, 2]
15 1 0 1
After:  [1, 1, 3, 2]

Before: [2, 3, 2, 1]
7 3 2 1
After:  [2, 1, 2, 1]

Before: [1, 0, 2, 0]
9 0 2 2
After:  [1, 0, 0, 0]

Before: [3, 3, 2, 3]
5 2 2 1
After:  [3, 2, 2, 3]

Before: [3, 1, 2, 2]
1 1 2 1
After:  [3, 0, 2, 2]

Before: [0, 0, 2, 3]
2 2 3 3
After:  [0, 0, 2, 0]

Before: [3, 3, 1, 3]
2 2 3 0
After:  [0, 3, 1, 3]

Before: [2, 2, 2, 3]
0 2 0 1
After:  [2, 2, 2, 3]

Before: [3, 1, 2, 1]
0 1 0 2
After:  [3, 1, 1, 1]

Before: [3, 3, 2, 1]
7 3 2 0
After:  [1, 3, 2, 1]

Before: [0, 1, 2, 0]
1 1 2 2
After:  [0, 1, 0, 0]

Before: [0, 0, 1, 0]
14 0 0 0
After:  [0, 0, 1, 0]

Before: [0, 2, 2, 1]
12 2 1 3
After:  [0, 2, 2, 1]

Before: [3, 2, 3, 1]
6 3 3 3
After:  [3, 2, 3, 0]

Before: [1, 1, 2, 1]
1 1 2 2
After:  [1, 1, 0, 1]

Before: [2, 3, 1, 2]
4 0 3 3
After:  [2, 3, 1, 1]

Before: [2, 2, 1, 2]
4 0 3 1
After:  [2, 1, 1, 2]

Before: [2, 1, 1, 2]
4 0 3 0
After:  [1, 1, 1, 2]



9 2 0 1
9 0 1 0
9 3 0 3
10 3 1 1
8 1 1 1
14 1 2 2
7 2 2 1
9 1 3 3
9 1 2 0
9 3 0 2
8 3 2 3
8 3 1 3
14 3 1 1
7 1 3 2
9 1 2 3
8 0 0 0
0 0 2 0
8 1 0 1
0 1 3 1
15 3 0 0
8 0 3 0
8 0 2 0
14 2 0 2
7 2 1 1
9 1 2 2
8 0 0 0
0 0 3 0
9 0 3 3
1 0 2 2
8 2 1 2
14 2 1 1
7 1 0 2
8 2 0 3
0 3 2 3
9 2 1 0
9 3 3 1
4 0 3 0
8 0 3 0
14 0 2 2
9 1 1 3
9 1 2 1
9 1 0 0
14 1 3 0
8 0 1 0
14 0 2 2
9 2 1 1
9 2 2 0
6 0 3 1
8 1 2 1
8 1 2 1
14 1 2 2
7 2 2 1
9 1 0 0
8 1 0 3
0 3 0 3
9 3 0 2
12 3 2 0
8 0 3 0
8 0 1 0
14 0 1 1
9 1 2 0
8 3 0 3
0 3 1 3
9 0 0 2
8 0 2 2
8 2 2 2
14 1 2 1
9 2 0 0
8 0 0 2
0 2 2 2
6 0 3 0
8 0 1 0
8 0 3 0
14 0 1 1
7 1 0 3
9 2 3 0
9 3 3 2
9 3 0 1
1 1 2 2
8 2 2 2
14 3 2 3
7 3 3 0
9 0 1 2
9 0 1 1
9 3 1 3
1 3 2 2
8 2 3 2
14 0 2 0
7 0 0 3
9 2 2 0
9 1 1 1
9 3 2 2
13 0 2 1
8 1 2 1
8 1 2 1
14 3 1 3
7 3 0 1
9 2 2 3
9 0 1 2
12 2 3 2
8 2 1 2
14 1 2 1
8 1 0 2
0 2 2 2
9 1 2 3
8 2 0 0
0 0 1 0
7 0 2 0
8 0 3 0
8 0 2 0
14 1 0 1
7 1 0 0
8 3 0 2
0 2 1 2
9 1 3 1
14 1 3 3
8 3 1 3
8 3 3 3
14 0 3 0
9 2 1 1
9 0 1 3
9 2 3 3
8 3 2 3
8 3 3 3
14 0 3 0
7 0 2 1
9 1 2 3
9 2 1 0
6 0 3 2
8 2 3 2
14 1 2 1
7 1 2 3
9 1 1 0
9 2 1 2
9 3 1 1
0 0 1 2
8 2 2 2
14 2 3 3
7 3 1 0
9 2 1 3
8 0 0 2
0 2 3 2
9 0 0 1
9 2 1 2
8 2 3 2
8 2 3 2
14 0 2 0
7 0 1 2
9 1 2 3
9 2 3 1
9 3 2 0
10 0 1 0
8 0 2 0
14 2 0 2
7 2 0 3
8 2 0 2
0 2 3 2
9 2 1 0
8 1 0 1
0 1 3 1
10 1 0 1
8 1 2 1
8 1 3 1
14 1 3 3
7 3 2 0
9 1 0 1
9 1 3 3
9 2 3 1
8 1 2 1
14 1 0 0
7 0 3 2
9 2 3 0
9 3 0 3
9 2 1 1
10 3 0 1
8 1 3 1
14 2 1 2
7 2 0 0
9 3 0 2
9 3 0 1
9 2 1 3
10 1 3 3
8 3 2 3
14 3 0 0
7 0 0 2
9 1 3 3
9 2 0 0
9 1 1 1
6 0 3 0
8 0 1 0
14 0 2 2
7 2 0 3
8 2 0 0
0 0 1 0
9 2 0 2
9 2 3 1
7 0 2 0
8 0 2 0
14 0 3 3
9 3 2 1
9 1 0 2
9 1 0 0
0 0 1 0
8 0 2 0
14 3 0 3
7 3 3 1
9 2 2 3
9 2 0 2
9 1 3 0
7 0 2 3
8 3 3 3
8 3 2 3
14 1 3 1
9 0 3 2
9 3 3 3
8 0 2 3
8 3 2 3
8 3 2 3
14 3 1 1
8 1 0 0
0 0 0 0
9 1 3 3
9 3 0 2
8 3 2 2
8 2 2 2
14 1 2 1
7 1 0 2
9 2 0 0
9 0 2 1
9 2 1 3
5 0 3 3
8 3 1 3
8 3 3 3
14 2 3 2
9 1 2 3
9 1 0 1
15 3 0 0
8 0 2 0
14 0 2 2
7 2 0 0
9 1 2 2
9 2 0 3
15 1 3 2
8 2 1 2
14 2 0 0
9 0 0 3
8 3 0 2
0 2 2 2
9 0 1 1
5 2 3 1
8 1 1 1
8 1 3 1
14 0 1 0
9 3 2 2
9 3 0 1
9 2 2 3
1 1 2 2
8 2 3 2
14 2 0 0
7 0 1 3
9 2 3 2
9 2 2 0
11 0 1 2
8 2 1 2
14 3 2 3
7 3 0 1
9 2 3 2
9 1 1 0
9 3 3 3
7 0 2 3
8 3 1 3
14 1 3 1
9 3 3 2
8 1 0 3
0 3 3 3
8 3 0 0
0 0 2 0
13 0 2 2
8 2 2 2
8 2 2 2
14 1 2 1
9 2 2 2
9 1 3 3
6 0 3 2
8 2 3 2
14 1 2 1
7 1 0 2
9 3 3 1
9 1 0 0
0 3 1 1
8 1 3 1
14 2 1 2
7 2 1 1
9 2 1 0
8 3 0 3
0 3 3 3
9 3 3 2
3 0 2 2
8 2 1 2
8 2 1 2
14 2 1 1
7 1 2 2
8 2 0 3
0 3 1 3
9 0 1 1
6 0 3 1
8 1 1 1
14 2 1 2
9 0 3 1
9 3 2 0
9 2 3 3
10 0 3 1
8 1 2 1
8 1 2 1
14 2 1 2
7 2 3 3
9 0 1 2
9 1 0 0
9 3 3 1
8 0 2 1
8 1 1 1
14 3 1 3
7 3 1 2
9 2 0 1
9 0 2 3
9 2 3 0
5 1 3 1
8 1 3 1
8 1 1 1
14 1 2 2
7 2 0 1
9 3 2 0
8 0 0 2
0 2 0 2
9 3 2 3
13 2 0 0
8 0 3 0
14 1 0 1
8 3 0 2
0 2 2 2
8 1 0 0
0 0 1 0
7 0 2 2
8 2 3 2
8 2 1 2
14 1 2 1
7 1 2 2
9 0 0 3
8 2 0 1
0 1 1 1
14 0 0 0
8 0 2 0
14 2 0 2
7 2 3 3
8 2 0 0
0 0 3 0
8 0 0 1
0 1 3 1
9 0 0 2
1 0 2 0
8 0 1 0
14 0 3 3
7 3 2 1
9 1 2 3
9 2 1 0
6 0 3 0
8 0 2 0
8 0 3 0
14 0 1 1
7 1 0 3
9 2 0 2
9 1 1 0
8 2 0 1
0 1 2 1
7 0 2 1
8 1 2 1
8 1 3 1
14 3 1 3
9 1 1 1
7 0 2 1
8 1 1 1
14 1 3 3
7 3 3 2
9 2 0 3
9 3 1 1
0 0 1 0
8 0 1 0
14 2 0 2
7 2 0 3
8 0 0 2
0 2 1 2
9 2 0 0
1 1 2 1
8 1 1 1
14 1 3 3
7 3 1 2
9 1 2 1
9 2 0 3
15 1 3 0
8 0 2 0
14 0 2 2
9 3 2 3
9 2 0 0
9 3 2 1
11 0 1 0
8 0 3 0
14 0 2 2
7 2 3 3
9 3 1 0
9 3 3 2
9 1 2 1
8 1 2 1
8 1 1 1
8 1 3 1
14 3 1 3
7 3 0 0
9 2 2 2
8 1 0 3
0 3 0 3
9 0 2 1
2 3 2 1
8 1 1 1
14 1 0 0
7 0 0 1
9 2 1 0
9 3 2 2
12 3 2 2
8 2 3 2
14 2 1 1
7 1 0 2
8 0 0 1
0 1 3 1
9 2 3 3
10 1 3 1
8 1 2 1
14 1 2 2
7 2 2 1
9 1 0 2
5 0 3 0
8 0 1 0
14 0 1 1
7 1 3 3
9 3 3 2
9 2 0 0
9 3 1 1
13 0 2 2
8 2 3 2
8 2 1 2
14 3 2 3
9 3 3 2
8 2 0 1
0 1 0 1
3 0 2 1
8 1 3 1
8 1 3 1
14 1 3 3
7 3 2 1
9 1 3 3
13 0 2 2
8 2 2 2
14 2 1 1
7 1 2 0
9 2 1 3
9 1 0 1
9 2 0 2
5 2 3 3
8 3 1 3
14 0 3 0
8 1 0 3
0 3 2 3
9 3 1 1
10 1 3 1
8 1 3 1
8 1 1 1
14 0 1 0
9 3 3 1
9 3 2 3
11 2 1 1
8 1 2 1
8 1 1 1
14 1 0 0
7 0 0 1
9 0 2 2
8 2 0 0
0 0 3 0
8 1 0 3
0 3 2 3
13 2 0 3
8 3 3 3
14 3 1 1
9 1 1 2
8 1 0 3
0 3 1 3
14 3 3 3
8 3 3 3
14 3 1 1
7 1 3 3
9 3 0 2
9 1 0 1
9 2 1 0
8 0 1 0
8 0 2 0
14 0 3 3
7 3 3 2
8 3 0 0
0 0 2 0
8 3 0 1
0 1 3 1
9 1 1 3
6 0 3 0
8 0 2 0
14 2 0 2
9 1 0 1
9 2 1 3
9 0 2 0
15 1 3 1
8 1 3 1
14 2 1 2
7 2 3 1
9 1 3 0
9 3 1 2
9 0 0 3
12 3 2 3
8 3 1 3
14 3 1 1
7 1 1 2
9 1 1 3
9 2 3 0
9 0 1 1
15 3 0 0
8 0 2 0
14 0 2 2
7 2 3 0
8 1 0 1
0 1 2 1
9 0 2 3
9 2 2 2
2 3 2 3
8 3 3 3
14 0 3 0
7 0 0 2
9 3 3 0
9 2 2 3
3 1 0 1
8 1 1 1
14 1 2 2
9 0 1 1
10 0 3 0
8 0 1 0
8 0 2 0
14 0 2 2
8 3 0 0
0 0 2 0
4 0 3 3
8 3 3 3
14 3 2 2
7 2 3 0
8 0 0 3
0 3 1 3
9 3 2 1
9 2 0 2
14 3 3 1
8 1 3 1
14 1 0 0
7 0 1 2
9 1 0 0
9 2 0 3
9 3 0 1
10 1 3 3
8 3 2 3
14 2 3 2
7 2 2 1
8 3 0 3
0 3 0 3
9 2 1 2
8 3 0 0
0 0 3 0
11 2 0 3
8 3 1 3
8 3 1 3
14 1 3 1
9 1 0 3
9 3 2 2
9 2 0 0
13 0 2 3
8 3 2 3
14 3 1 1
8 3 0 3
0 3 3 3
8 0 0 0
0 0 1 0
8 0 2 0
8 0 3 0
14 1 0 1
7 1 1 3
9 1 3 1
9 2 1 0
13 0 2 0
8 0 2 0
8 0 2 0
14 3 0 3
7 3 3 0
8 0 0 3
0 3 3 3
9 0 2 1
1 3 2 2
8 2 2 2
14 2 0 0
9 3 2 2
9 3 1 1
1 3 2 1
8 1 3 1
8 1 1 1
14 1 0 0
7 0 2 2
9 3 3 1
9 1 2 0
9 1 0 3
0 0 1 1
8 1 3 1
14 2 1 2
7 2 3 1
8 3 0 2
0 2 3 2
8 3 0 0
0 0 2 0
9 2 1 3
4 0 3 0
8 0 1 0
14 0 1 1
9 3 1 3
9 2 3 2
9 2 0 0
10 3 0 0
8 0 3 0
14 1 0 1
8 0 0 3
0 3 0 3
9 1 0 0
7 0 2 2
8 2 1 2
14 1 2 1
9 3 0 0
8 2 0 2
0 2 0 2
13 2 0 2
8 2 3 2
14 1 2 1
9 3 0 2
9 2 2 3
9 2 2 0
3 0 2 3
8 3 2 3
14 3 1 1
7 1 2 2
9 2 0 3
8 1 0 1
0 1 1 1
4 0 3 3
8 3 3 3
8 3 1 3
14 3 2 2
7 2 2 1
9 3 0 0
8 0 0 2
0 2 0 2
9 2 1 3
13 2 0 2
8 2 3 2
14 1 2 1
7 1 1 2
9 0 1 1
9 1 0 0
8 3 0 3
0 3 3 3
0 0 1 1
8 1 1 1
14 1 2 2
7 2 3 1
9 2 3 0
9 2 1 3
9 2 0 2
4 0 3 3
8 3 3 3
14 1 3 1
9 1 1 3
8 1 0 2
0 2 0 2
6 0 3 3
8 3 3 3
14 3 1 1
7 1 1 3
9 1 2 0
9 3 0 1
9 3 1 2
0 0 1 0
8 0 1 0
14 0 3 3
7 3 3 1
8 1 0 0
0 0 1 0
9 2 2 3
9 2 0 2
7 0 2 0
8 0 2 0
14 0 1 1
7 1 0 2
9 1 0 3
9 2 1 1
9 1 1 0
14 0 0 1
8 1 1 1
8 1 2 1
14 1 2 2
7 2 1 3
9 2 3 0
9 3 1 2
9 2 3 1
13 0 2 0
8 0 3 0
14 3 0 3
7 3 0 2
9 3 1 1
9 1 0 3
9 2 2 0
11 0 1 3
8 3 1 3
14 2 3 2
7 2 2 1
8 2 0 0
0 0 1 0
9 2 1 2
9 1 3 3
7 0 2 3
8 3 3 3
14 3 1 1
7 1 2 0
9 0 1 3
9 1 1 1
2 3 2 2
8 2 1 2
14 2 0 0
7 0 3 3
9 3 0 1
9 1 3 0
8 3 0 2
0 2 2 2
0 0 1 1
8 1 2 1
14 1 3 3
7 3 1 2
9 2 1 1
9 1 2 3
9 2 1 0
6 0 3 0
8 0 1 0
8 0 3 0
14 0 2 2
9 2 1 3
9 1 3 1
9 2 1 0
4 0 3 1
8 1 3 1
8 1 1 1
14 1 2 2
7 2 3 1
9 1 3 2
9 3 3 0
9 0 2 3
9 2 0 2
8 2 1 2
14 2 1 1
9 3 2 3
8 1 0 2
0 2 0 2
9 2 2 0
10 3 0 3
8 3 2 3
14 1 3 1
9 0 1 3
9 2 1 2
2 3 2 0
8 0 2 0
14 1 0 1
7 1 0 3
9 3 0 0
9 0 3 1
11 2 0 0
8 0 2 0
14 3 0 3
9 3 3 2
9 3 2 0
9 2 1 1
1 0 2 0
8 0 3 0
14 3 0 3
7 3 0 2
8 1 0 0
0 0 2 0
9 1 0 3
8 0 0 1
0 1 0 1
6 0 3 3
8 3 2 3
8 3 1 3
14 3 2 2
7 2 0 3
9 3 2 2
13 0 2 2
8 2 1 2
14 3 2 3
7 3 3 1
8 0 0 3
0 3 1 3
9 3 1 0
9 2 0 2
11 2 0 3
8 3 1 3
14 3 1 1
9 0 1 3
9 0 1 0
2 3 2 2
8 2 2 2
8 2 2 2
14 2 1 1
7 1 3 3
9 0 2 2
9 3 1 1
1 1 2 2
8 2 3 2
14 2 3 3
7 3 3 0
"""
let parts = input.components(separatedBy: "\n\n")


class Opcode {
    let mnemonic: String
    var numeric = -1
    let action: ( Int, Int, Int ) -> Void
    
    init( mnemonic: String, action: @escaping ( Int, Int, Int ) -> Void ) {
        self.mnemonic = mnemonic
        self.numeric = -1
        self.action = action
    }
}

class Instruction {
    let opcode: Int
    let a: Int
    let b: Int
    let c: Int
    
    init( input: Substring ) {
        let instruction = input.split(separator: " ")
        
        opcode = Int( instruction[0] )!
        a = Int( instruction[1] )!
        b = Int( instruction[2] )!
        c = Int( instruction[3] )!
    }
}

class Sample {
    let before: [Int]
    let instruction: Instruction
    let after: [Int]
    
    init( input: String ) {
        let lines = input.split(separator: "\n")
        let before = lines[0].split(whereSeparator: { " [],".contains($0) } )
        let after = lines[2].split(whereSeparator: { " [],".contains($0) } )
        
        self.before = before[1...4].map { Int($0)! }
        self.after = after[1...4].map { Int($0)! }
        
        instruction = Instruction(input: lines[1])
    }
}

var registers = Array(repeating: 0, count: 4)
let opcodes = [
    Opcode( mnemonic: "addr", action: { registers[$2] = registers[$0] + registers[$1] } ),
    Opcode( mnemonic: "addi", action: { registers[$2] = registers[$0] + $1 } ),
    Opcode( mnemonic: "mulr", action: { registers[$2] = registers[$0] * registers[$1] } ),
    Opcode( mnemonic: "muli", action: { registers[$2] = registers[$0] * $1 } ),
    Opcode( mnemonic: "banr", action: { registers[$2] = registers[$0] & registers[$1] } ),
    Opcode( mnemonic: "bani", action: { registers[$2] = registers[$0] & $1 } ),
    Opcode( mnemonic: "borr", action: { registers[$2] = registers[$0] | registers[$1] } ),
    Opcode( mnemonic: "bori", action: { registers[$2] = registers[$0] | $1 } ),
    Opcode( mnemonic: "setr", action: { registers[$2] = registers[$0] } ),
    Opcode( mnemonic: "seti", action: { registers[$2] = $0 } ),
    Opcode( mnemonic: "gtir", action: { registers[$2] = $0 > registers[$1] ? 1 : 0 } ),
    Opcode( mnemonic: "gtri", action: { registers[$2] = registers[$0] > $1 ? 1 : 0 } ),
    Opcode( mnemonic: "gtrr", action: { registers[$2] = registers[$0] > registers[$1] ? 1 : 0 } ),
    Opcode( mnemonic: "eqir", action: { registers[$2] = $0 == registers[$1] ? 1 : 0 } ),
    Opcode( mnemonic: "eqri", action: { registers[$2] = registers[$0] == $1 ? 1 : 0 } ),
    Opcode( mnemonic: "eqrr", action: { registers[$2] = registers[$0] == registers[$1] ? 1 : 0 } ),
]
let pairs = opcodes.map { ( $0.mnemonic, $0 ) }
let opcodeDictionary: [String:Opcode] = Dictionary(pairs, uniquingKeysWith: { first, _ in first } )

let samples = parts[...(parts.count-3)].map { Sample(input: $0) }
var part1 = 0
var working = Array(repeating: Set<String>( [] ), count: 16)

for sample in samples {
    var matching = Set<String>()
    var count = 0

    for opcode in opcodes {
        registers = sample.before
        opcode.action( sample.instruction.a, sample.instruction.b, sample.instruction.c )
        if registers == sample.after {
            count += 1
            matching.insert( opcode.mnemonic )
        }
    }
    
    if matching.count >= 3 {
        part1 += 1
    }
    
    if working[ sample.instruction.opcode ].count == 0 {
        working[ sample.instruction.opcode ] = matching
    } else {
        working[ sample.instruction.opcode ] = working[ sample.instruction.opcode ].intersection(matching)
    }
}

print( "Part1:", part1 )

while working.reduce( 0, { $0 + $1.count } ) > 0 {
    let singles = working.filter { $0.count == 1 }
    
    for single in singles {
        let mnemonic = single.first!
        
        opcodeDictionary[mnemonic]?.numeric = working.firstIndex(of: single)!
        working.enumerated().forEach { working[$0] = $1.subtracting(single) }
    }
}

let program = parts.last!.split(separator: "\n").map { Instruction(input: $0) }

registers = [ 0, 0, 0, 0 ]
for instruction in program {
    let opcode = opcodes.first( where: { $0.numeric == instruction.opcode } )!
    
    opcode.action( instruction.a, instruction.b, instruction.c )
}

print( "Part2:", registers[0] )
