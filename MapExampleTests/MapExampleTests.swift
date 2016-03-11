//
//  MapExampleTests.swift
//  MapExampleTests
//
//  Created by long nguyen on 10/03/2016.
//  Copyright © 2016 long nguyen. All rights reserved.
//

import XCTest
@testable import MapExample

class MapExampleTests: XCTestCase {
    
    var vcToTest:ViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let storyborad = UIStoryboard(name: "Main", bundle: nil)
        
        self.vcToTest = storyborad.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
        
        self.vcToTest.self.tfStart = TextFieldGrayCustom()
        self.vcToTest.self.tfEnd  = TextFieldGrayCustom()
        
        self.vcToTest.self.tfStart.text = "start"
        self.vcToTest.self.tfEnd.text = "end"
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSwapBtnTouch(){
        let tempStart = self.vcToTest.self.tfStart.text
        let tempEnd = self.vcToTest.self.tfEnd.text
        self.vcToTest.btnSwapTouch(UIButton())
        
        XCTAssertEqual(tempStart, self.vcToTest.self.tfEnd.text)
        XCTAssertEqual(tempEnd, self.vcToTest.self.tfStart.text)
    }
    
    //testupdateRouter
    func testupdateRouter() {
        let from = CLLocationCoordinate2D(latitude: 10.8033223, longitude: 106.615868)
        let to = CLLocationCoordinate2D(latitude: 10.7751571, longitude: 106.6330904)
        
        self.vcToTest.mapManager.directionsUsingGoogle(from: from, to:to) { (points ,route,directionInformation, boundingRegion, error) -> () in
            
            XCTAssertEqual(points,  "cb}`A}kviS_@aISqFBCFCDGHQ|CQhHo@BBDBFBD?NAJI@Ct@k@bMo@zIi@zBMbBKl@}@BOA[EkAIiBOyBKkCK}ELuJD_HDoCHc@L]bAmBrA_CjByDReALyA~@uL|@}JH{A`@{DNwAX}CxANxIt@jHp@tQbBnY~BtDZ`CPj@JjDp@`AVtEpA`A\\~@b@lEjCrDvBxA|@")
        }
    }
    
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
