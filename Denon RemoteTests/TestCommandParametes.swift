//
//  TestCommandParametes.swift
//  Denon Remote
//
//  Created by Thomas Nordquist on 19.08.16.
//  Copyright © 2016 Thomas Nordquist. All rights reserved.
//

import XCTest
@testable import Denon_Remote

class TestCommandParametes: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSleepCommandParameters() {
        func minuteStr(minutes: Int) -> String {
            return DenonCommand.SLEEP.PARAMETER(minutes).parameter
        }

        XCTAssertEqual(minuteStr(-1), "000") // lower bound
        XCTAssertEqual(minuteStr(130), "120") // upper bound
        XCTAssertEqual(minuteStr(5), "005")
        XCTAssertEqual(minuteStr(12), "012")
        XCTAssertEqual(minuteStr(112), "112")

    }

}
