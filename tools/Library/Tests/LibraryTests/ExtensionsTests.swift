//
//  ExtensionsTests.swift
//  
//
//  Created by Mark Johnson on 4/8/23.
//

import XCTest
import Library

final class ExtensionsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTokenize() {
        let t1 = "abc,def,hij".tokenize( delimiters: "," )
        let t2 = "abc,def;hij".tokenize( delimiters: ",;" )
        let t3 = ".abc,def;hij".tokenize( delimiters: ".,;" )
        let t4 = "abc,def;hij!".tokenize( delimiters: ",;!" )
        let t5 = "abc,,def,hij".tokenize( delimiters: "," )
        
        XCTAssertEqual( t1.count, 5, "t1 count should be 5" )
        XCTAssertEqual( t2.count, 5, "t2 count should be 5" )
        XCTAssertEqual( t3.count, 6, "t3 count should be 6" )
        XCTAssertEqual( t4.count, 6, "t4 count should be 6" )
        XCTAssertEqual( t5.count, 6, "t5 count should be 6" )
    }
    
    func testGCD() {
        XCTAssertEqual( gcd( 24, 60 ), 12, "gcd of 24 and 60 should be 12" )
    }
    
    func testLCM() {
        XCTAssertEqual( lcm( 24, 60 ), 120, "lcm of 24 and 60 should be 120" )
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
