//
//  WebErrorTests.swift
//  
//
//  Created by Lior Tal on 03/07/2021.
//

import XCTest
@testable import NetworkAnalyzer

final class WebErrorTests: XCTestCase {
    func test_movedPermanently() {
        XCTAssertEqual(HTTPError(code: 301), .movedPermanently)
    }
    
    func test_badRequestCode() {
        XCTAssertEqual(HTTPError(code: 402), .unknown)
    }
}
