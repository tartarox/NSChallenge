//
//  SwiftProjectTests.swift
//  SwiftProjectTests
//
//  Created by MacBook on 25/05/16.
//  Copyright © 2016 Fabio Takahara. All rights reserved.
//

import XCTest
@testable import SwiftProject

class SwiftProjectTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    //Test for Requests - Online only
    func testGistRequest() {
        
        RequestManager.getDataFromGist(0, completion: { (result) in
            let resultArray:[RequestManager.GistObject] = result!
            XCTAssert(resultArray.count == 30)
            
            }) { (error) in
                XCTAssert(false)
        }
    }
    
    //Test for return of objects from Coredata - need to have a one object registered
    func testCoreData() {
        
        CoreDataManager.getJsonFromCore({ (result) in
            
            XCTAssert(result.count != 0)
            
            }) { (error) in
                XCTAssert(false)
        }
    }
    
}
