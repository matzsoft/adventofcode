//         FILE: HeapTests.swift
//  DESCRIPTION:  - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2024 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 1/23/24 1:06 PM

import XCTest
import Library

final class HeapTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    fileprivate func fourLetters( encoded: Int ) -> String {
        var encoded = encoded
        var letters = [Character]()
        
        while encoded > 0 {
            let next = Character( UnicodeScalar( Character( "a" ).asciiValue! +  UInt8( encoded % 26 ) ) )
            letters.append( next )
            encoded /= 26
        }
        
        return String( letters.reversed() )
    }
    
    fileprivate struct Sample: Equatable {
        let name: String
        let number: Int
    }
    
    func testSorting() {
        let sampleSize = 100
        let nameStart = 26 * 26 * 26
        var namesSeen = Set<Int>()
        var names = [String]()
        
        while names.count < sampleSize {
            let name = Int.random( in: nameStart ..< 26 * nameStart )
            if namesSeen.insert( name ).inserted {
                names.append( fourLetters( encoded: name ) )
            }
        }
        
        var numbersSeen = Set<Int>()
        var numbers = [Int]()
        
        while numbers.count < sampleSize {
            let number = Int.random( in: 1000 ..< 10000 )
            if numbersSeen.insert( number ).inserted {
                numbers.append( number )
            }
        }
        
        let samples = zip( names, numbers ).map { Sample( name: $0.0, number: $0.1 ) }
        var heap = DictionaryHeap<String, Sample>() { $0.number < $1.number }
        
        samples.forEach { heap[$0.name] = $0 }
        
        var extracted = [Sample]()
        while let next = heap.removeFirst() {
            extracted.append( next )
        }
        XCTAssertEqual( extracted, samples.sorted { $0.number < $1.number }, "Sorts not equal" )
    }
    
    func testSubscripts() {
        var heap = DictionaryHeap<String, Sample>() { $0.number < $1.number }
        
        heap["cat"] = Sample( name: "cat", number: 1 )
        heap["dog"] = Sample( name: "dog", number: 2 )
        heap["horse"] = Sample( name: "horse", number: 3 )
        heap["lamb"] = Sample( name: "lamb", number: 4 )
        
        heap["horse"] = Sample( name: "horse", number: 7 )
        heap["dog"] = nil
        
        let expected = [
            Sample( name: "cat", number: 1 ),
            Sample( name: "lamb", number: 4 ),
            Sample( name: "horse", number: 7 ),
        ]
        
        var extracted = [Sample]()
        while let next = heap.removeFirst() {
            extracted.append( next )
        }
        XCTAssertEqual( extracted, expected, "Extracted results not expected" )
        
        let expected2 = [
            Sample( name: "cat", number: 1 ),
            Sample( name: "horse", number: 3 ),
            Sample( name: "lamb", number: 4 ),
        ]
        
        heap["cat"] = Sample( name: "cat", number: 1 )
        heap["horse"] = Sample( name: "horse", number: 7 )
        heap["lamb"] = Sample( name: "lamb", number: 4 )

        heap["horse"] = Sample( name: "horse", number: 3 )
        extracted = []
        while let next = heap.removeFirst() {
            extracted.append( next )
        }
        XCTAssertEqual( extracted, expected2, "Second extracted results not expected" )

        let kermit = Sample( name: "frog", number: 12 )
        XCTAssertEqual( kermit, heap[ "frog", default: kermit ]!, "Subscript default failure." )
        XCTAssertNil( heap["frog"], "Non-existant entry does not return nil" )
    }
    
//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        // Any test you write for XCTest can be annotated as throws and async.
//        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
//        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
//    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
