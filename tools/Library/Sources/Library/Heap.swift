//         FILE: Heap.swift
//  DESCRIPTION:  - Implements a generic Min Heap (to be used as a priority queue).
//        NOTES: Thanks to Caleb Stultz for his excellent description of heaps at
//               https://medium.com/devslopes-blog/swift-data-structures-heap-e3fbbdaa3129
//               I have taken his code and modified it slightly, mostly to make it generic.
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 1/12/24 12:03 PM

import Foundation

public struct MinHeap<Element: Comparable> {
    var items: [Element] = []
    
    var isEmpty: Bool { items.isEmpty }
    
    public init( items: [Element] = [] ) {
        self.items = items
    }
    
    //Get Index
    private func getLeftChildIndex( _ parentIndex: Int ) -> Int { return 2 * parentIndex + 1 }
    private func getRightChildIndex( _ parentIndex: Int ) -> Int { return 2 * parentIndex + 2 }
    private func getParentIndex( _ childIndex: Int ) -> Int { return ( childIndex - 1 ) / 2 }
    
    // Boolean Check
    private func hasLeftChild( _ index: Int ) -> Bool { return getLeftChildIndex( index ) < items.count }
    private func hasRightChild( _ index: Int ) -> Bool { return getRightChildIndex( index ) < items.count }
    private func hasParent( _ index: Int ) -> Bool { return getParentIndex( index ) >= 0 }
    
    // Return Item From Heap
    private func leftChild( _ index: Int ) -> Element { return items[ getLeftChildIndex( index ) ] }
    private func rightChild( _ index: Int ) -> Element { return items[ getRightChildIndex( index ) ] }
    private func parent( _ index: Int ) -> Element { return items[ getParentIndex( index ) ] }
    
    // Heap Operations
    mutating private func swap( indexOne: Int, indexTwo: Int ) {
        ( items[indexOne], items[indexTwo] ) = ( items[indexTwo], items[indexOne] )
    }
    
    public func peek() -> Element? { items.first }
    
    mutating public func poll() -> Element? {
        guard let item = items.first else { return nil }
        var index = 0

        items[0] = items[ items.count - 1 ]
        // heapifyDown
        while hasLeftChild( index ) {
            let childIndex = hasRightChild( index ) && rightChild( index ) < leftChild( index )
                ? getRightChildIndex( index ) : getLeftChildIndex( index )
            
            if items[index] < items[childIndex] {
                break
            } else {
                swap( indexOne: index, indexTwo: childIndex )
            }
            index = childIndex
        }
        items.removeLast()
        return item
    }
    
    mutating public func add( _ item: Element ) {
        var index = items.count
        
        items.append( item )
        // heapifyUp
        while hasParent( index ) && items[index] < parent( index ) {
            swap( indexOne: getParentIndex( index ), indexTwo: index )
            index = getParentIndex( index )
        }
    }
}
