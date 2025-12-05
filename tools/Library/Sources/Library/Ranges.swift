//         FILE: Ranges.swift
//  DESCRIPTION: Library - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2025 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 12/5/25 1:52 PM

import Foundation

extension ClosedRange where Bound: Strideable {
    public func union( other: ClosedRange<Bound> ) -> ClosedRange<Bound>? {
        let lower = Swift.min( self.lowerBound, other.lowerBound )
        let upper = Swift.max( self.upperBound, other.upperBound )
        
        if self.overlaps( other ) { return lower ... upper }
        if self.upperBound.advanced( by: 1 ) == other.lowerBound {
            return lower ... upper
        }
        if other.upperBound.advanced( by: 1 ) == self.lowerBound {
            return lower ... upper
        }
        return nil
    }
}


extension [ClosedRange<Int>] {
    public var condensed: [Element] {
        let sorted = self.sorted { $0.lowerBound < $1.lowerBound }
        var condensed = [ sorted[0] ]
        
        for range in sorted.dropFirst() {
            if let union = condensed.last!.union( other: range ) {
                condensed[ condensed.count - 1 ] = union
            } else {
                condensed.append( range )
            }
        }
        return condensed
    }
}
