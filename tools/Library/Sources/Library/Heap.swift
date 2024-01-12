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
        let placeholder = items[indexOne]
        items[indexOne] = items[indexTwo]
        items[indexTwo] = placeholder
    }
    
    public func peek() -> Element? {
        if items.isEmpty { return nil }
        return items[0]
    }
    
    mutating public func poll() -> Element? {
        if items.isEmpty { return nil }
        
        let item = items[0]
        items[0] = items[ items.count - 1 ]
        heapifyDown()
        items.removeLast()
        return item
    }
    
    mutating public func add( _ item: Element ) {
        items.append( item )
        heapifyUp()
    }
    
    mutating private func heapifyUp() {
        var index = items.count - 1
        while hasParent( index ) && parent( index ) > items[index] {
            swap( indexOne: getParentIndex( index ), indexTwo: index )
            index = getParentIndex( index )
        }
    }
    
    mutating private func heapifyDown() {
        var index = 0
        while hasLeftChild( index ) {
            var smallerChildIndex = getLeftChildIndex( index )
            if hasRightChild( index ) && rightChild( index ) < leftChild( index ) {
                smallerChildIndex = getRightChildIndex( index )
            }
            
            if items[index] < items[smallerChildIndex] {
                break
            } else {
                swap(indexOne: index, indexTwo: smallerChildIndex)
            }
            index = smallerChildIndex
        }
    }
}
