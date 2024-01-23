//         FILE: Heap.swift
//  DESCRIPTION:  - Implements a generic Binary Heap (to be used as a priority queue).
//        NOTES: Thanks to Caleb Stultz for his excellent description of heaps at
//               https://medium.com/devslopes-blog/swift-data-structures-heap-e3fbbdaa3129
//               I took his code and modified it to make it generic. Then I discovered Tyler Stromberg's
//               post on the Swift forums (https://forums.swift.org/t/priority-queue/47172). I implemented
//               his code but it was 20% slower. So I created the following hybred version.
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 1/12/24 12:03 PM

import Foundation

public struct BinaryHeap<Element: Comparable> {
    public typealias Index = Int

    var items: [Element] = []
    let comparator: ( Element, Element ) -> Bool

    public var isEmpty: Bool { items.isEmpty }
    public var count: Int { items.count }

    public init( comparator: @escaping ( Element, Element ) -> Bool ) {
        self.items = []
        self.comparator = comparator
    }
    
    //Get Index
    private func getLeftChildIndex( _ parentIndex: Index ) -> Index { return 2 * parentIndex + 1 }
    private func getRightChildIndex( _ parentIndex: Index ) -> Index { return 2 * parentIndex + 2 }
    private func getParentIndex( _ childIndex: Index ) -> Index { return ( childIndex - 1 ) / 2 }
    
    // Boolean Check
    private func hasLeftChild( _ index: Index ) -> Bool { return getLeftChildIndex( index ) < items.count }
    private func hasRightChild( _ index: Index ) -> Bool { return getRightChildIndex( index ) < items.count }
    private func hasParent( _ index: Index ) -> Bool { return getParentIndex( index ) >= 0 }
    
    // Return Item From Heap
    private func leftChild( _ index: Index ) -> Element { return items[ getLeftChildIndex( index ) ] }
    private func rightChild( _ index: Index ) -> Element { return items[ getRightChildIndex( index ) ] }
    private func parent( _ index: Index ) -> Element { return items[ getParentIndex( index ) ] }
    
    // Heap Operations
    mutating private func swap( indexOne: Index, indexTwo: Index ) {
        ( items[indexOne], items[indexTwo] ) = ( items[indexTwo], items[indexOne] )
    }
    
    public func peek() -> Element? { items.first }
    
    mutating public func pop() -> Element? {
        guard let item = items.first else { return nil }
        var index = 0

        items[0] = items[ items.count - 1 ]
        // heapifyDown
        while hasLeftChild( index ) {
            let childIndex
                = hasRightChild( index ) && comparator( rightChild( index ), leftChild( index ) )
                ? getRightChildIndex( index ) : getLeftChildIndex( index )
            
            if comparator( items[index], items[childIndex] ) {
                break
            } else {
                swap( indexOne: index, indexTwo: childIndex )
            }
            index = childIndex
        }
        items.removeLast()
        return item
    }
    
    mutating public func insert( _ item: Element ) {
        var index = items.count
        
        items.append( item )
        // heapifyUp
        while hasParent( index ) && comparator( items[index], parent( index ) ) {
            swap( indexOne: getParentIndex( index ), indexTwo: index )
            index = getParentIndex( index )
        }
    }

    public mutating func insert( contentsOf items: any Sequence<Element> ) {
        items.forEach { insert( $0 ) }
    }
}


extension BinaryHeap {
    public init<Value>( keyPath: KeyPath<Element, Value>, comparator: @escaping ( Value, Value ) -> Bool ) {
        self.init { lhs, rhs in
            comparator( lhs[ keyPath: keyPath ], rhs[ keyPath: keyPath ] )
        }
    }
}


extension BinaryHeap where Element: Comparable {
    public static func minHeap() -> Self {
        self.init( comparator: < )
    }

    public static func maxHeap() -> Self {
        self.init( comparator: > )
    }
}


public struct DictionaryHeap<Key: Hashable, Element: Equatable> {
    public typealias Index = Int
    private typealias HeapNode = ( key: Key, value: Element )

    private var items: [ Key : Index ]
    private var heap: [HeapNode]
    private let comparator: ( Element, Element ) -> Bool

    public var isEmpty: Bool { items.isEmpty }
    public var count: Int { items.count }
    public var first: Element? { heap.first?.value }     // Replaces Heap peek operator

    public subscript( key: Key, default defaultValue: Element? = nil ) -> Element? {
        get {
            guard let index = items[key] else { return defaultValue }
            return heap[index].value
        }
        set {
            guard let index = items[key] else {
                if let newValue = newValue { insert( key: key, value: newValue ) }
                return
            }
            guard let newValue = newValue else {
                delete( index: index )
                return
            }
            
            // update
            if comparator( newValue, heap[index].value ) {
                heap[index] = ( key: key, value: newValue )
                heapifyUp( index: index )
            } else {
                heap[index] = ( key: key, value: newValue )
                heapifyDown( index: index )
            }
        }
    }
    
    public init( comparator: @escaping ( Element, Element ) -> Bool ) {
        self.items = [:]
        self.heap = []
        self.comparator = comparator
    }
    
    //Get Index
    private func getLeftChildIndex( _ parentIndex: Index ) -> Index { 2 * parentIndex + 1 }
    private func getRightChildIndex( _ parentIndex: Index ) -> Index { 2 * parentIndex + 2 }
    private func getParentIndex( _ childIndex: Index ) -> Index { ( childIndex - 1 ) / 2 }
    
    // Boolean Check
    private func hasLeftChild( _ index: Index ) -> Bool { getLeftChildIndex( index ) < items.count }
    private func hasRightChild( _ index: Index ) -> Bool { getRightChildIndex( index ) < items.count }
    private func hasParent( _ index: Index ) -> Bool { getParentIndex( index ) >= 0 }
    
    // Return Item From Heap
    private func leftChild( _ index: Index ) -> Element { heap[ getLeftChildIndex( index ) ].value }
    private func rightChild( _ index: Index ) -> Element { heap[ getRightChildIndex( index ) ].value }
    private func parent( _ index: Index ) -> Element { heap[ getParentIndex( index ) ].value }
    
    // Heap Operations
    mutating private func swap( indexOne: Index, indexTwo: Index ) {
        ( heap[indexOne], heap[indexTwo] ) = ( heap[indexTwo], heap[indexOne] )
        items[ heap[indexOne].key ] = indexOne
        items[ heap[indexTwo].key ] = indexTwo
    }
    
    // Perfomrs the Heap pop operation
    public mutating func removeFirst() -> Element? { delete( index: 0 ) }
    
//    mutating public func pop() -> Element? {
//        guard let item = first else { return nil }
//        var index = 0
//
//        heap[0] = heap[ items.count - 1 ]
//        // heapifyDown
//        while hasLeftChild( index ) {
//            let childIndex
//                = hasRightChild( index ) && comparator( rightChild( index ), leftChild( index ) )
//                ? getRightChildIndex( index ) : getLeftChildIndex( index )
//            
//            if comparator( items[index], items[childIndex] ) {
//                break
//            } else {
//                swap( indexOne: index, indexTwo: childIndex )
//            }
//            index = childIndex
//        }
//        heap.removeLast()
//        return item
//    }
    
    mutating private func insert( key: Key, value: Element ) {
        let index = heap.count
        
        heap.append( ( key: key, value: value ) )
        items[key] = index
        heapifyUp( index: index )
    }

    @discardableResult private mutating func delete( index: Index ) -> Element? {
        guard index < heap.count else { return nil }
        guard heap.count > 1 else {
            let item = heap[0].value
            items = [:]
            heap = []
            return item
            
        }
        
        let item = heap[index].value
        
        items[ heap[index].key ] = nil
        heap[index] = heap[ heap.count - 1 ]
        items[ heap[index].key ] = index
        heap.removeLast()
        heapifyDown( index: index )
        return item
    }
    
    mutating private func heapifyUp( index: Index ) -> Void {
        var index = index
        
        while hasParent( index ) && comparator( heap[index].value, parent( index ) ) {
            swap( indexOne: getParentIndex( index ), indexTwo: index )
            index = getParentIndex( index )
        }
    }
    
    private mutating func heapifyDown( index: Index ) -> Void {
        var index = index

        while hasLeftChild( index ) {
            let childIndex
                = hasRightChild( index ) && comparator( rightChild( index ), leftChild( index ) )
                ? getRightChildIndex( index ) : getLeftChildIndex( index )
            
            if comparator( heap[index].value, heap[childIndex].value ) {
                break
            } else {
                swap( indexOne: index, indexTwo: childIndex )
            }
            index = childIndex
        }
    }
    
//    public mutating func insert( contentsOf items: any Sequence<Element> ) {
//        items.forEach { insert( $0 ) }
//    }
}


extension DictionaryHeap {
    public init<Value>( keyPath: KeyPath<Element, Value>, comparator: @escaping ( Value, Value ) -> Bool ) {
        self.init { lhs, rhs in
            comparator( lhs[ keyPath: keyPath ], rhs[ keyPath: keyPath ] )
        }
    }
}


extension DictionaryHeap where Element: Comparable {
    public static func minHeap() -> Self {
        self.init( comparator: < )
    }

    public static func maxHeap() -> Self {
        self.init( comparator: > )
    }
}
