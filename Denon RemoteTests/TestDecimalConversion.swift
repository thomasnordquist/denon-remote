//
//  TestDecimalConversion.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 15.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import XCTest
import Alamofire
import AlamofireImage
import PromiseKit
@testable import Denon_Remote

class TestDecimalConversion: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testVolumeParamter() {

        XCTAssertEqual(ParameterValidator.volumeParameter(0, max: 70, step: 0.5, value: 20), "20")
        XCTAssertEqual(ParameterValidator.volumeParameter(0, max: 70, step: 0.5, value: 20.5), "205")
        XCTAssertEqual(ParameterValidator.volumeParameter(0, max: 70, step: 0.5, value: -1), "00")
        XCTAssertEqual(ParameterValidator.volumeParameter(0, max: 70, step: 0.5, value: 70.5), "70")
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testFixedDecimal() {
        XCTAssertEqual(ParameterValidator.valueToFixedDecimal(20), "20")
        XCTAssertEqual(ParameterValidator.valueToFixedDecimal(20.5), "205")
        XCTAssertEqual(ParameterValidator.valueToFixedDecimal(99.5), "995")
        XCTAssertEqual(ParameterValidator.valueToFixedDecimal(7), "07")
        XCTAssertEqual(ParameterValidator.valueToFixedDecimal(0), "00")

        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

}
