//
//  GeneralErrorTests.swift
//  
//
//  Created by Lior Tal on 03/07/2021.
//

import XCTest
@testable import NetworkAnalyzer

final class GeneralErrorTests: XCTestCase {
    func test_generalError_localizedDescription() {
        XCTAssertEqual(GeneralError.invalidUrl.localizedDescription, "The url that provid is invalid.")
    }
}
