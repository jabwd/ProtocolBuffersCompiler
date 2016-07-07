//
//  ProtobufSwiftTests.swift
//  ProtobufSwiftTests
//
//  Created by Antwan van Houdt on 07/07/16.
//  Copyright © 2016 Antwan van Houdt. All rights reserved.
//

import XCTest
@testable import ProtobufSwift

class ProtobufSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDecoder() {
        let decoder = Decoder()
        
        let testBuffer = NSData(base64EncodedString: "AAAAAAAAAAAKEWFkbWluQGV4dXJpb24uY29tEgYyMTIxMjEqIFzDetAVTk8kmJamRkdOGPpwCbFCjJDbZVa8DMdTMock", options: [])!
        
        let result = decoder.decode(testBuffer.subdataWithRange(NSMakeRange(8, testBuffer.length-8)))
        print("\(result)")
    }
    
    /*func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }*/
    
}
