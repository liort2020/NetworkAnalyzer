//
//  NetworkRepositoryTests.swift
//
//
//  Created by Lior Tal on 02/07/2021.
//

import XCTest
import Combine
@testable import NetworkAnalyzer

final class NetworkRepositoryTests: XCTestCase {
    private var networkWebRepository: NetworkWebRepository?
    private let baseURL = "http://www.mocky.io/v2"
    private let startRedirectId = "5e0af46b3300007e1120a7ef"
    private var maxNumberOfRedirects = UInt8.max
    private var subscriptions = Set<AnyCancellable>()
    
    private static let expectationsTimeOut: TimeInterval = 5.0
    
    override func setUp() {
        super.setUp()
        networkWebRepository = NetworkRepository(baseURL: baseURL, maxNumberOfRedirects: maxNumberOfRedirects)
    }
    
    func test_maxNumberOfRedirects_limitedToZero() throws {
        // Given
        let expectedRedirections: UInt8 = 0
        var actualRedirections: UInt8 = 0
        
        var networkWebRepository = try XCTUnwrap(networkWebRepository)
        networkWebRepository.maxNumberOfRedirects = expectedRedirections
        
        let expectation = expectation(description: "zeroRedirects")
        
        let networkPublishers = networkWebRepository.get(by: startRedirectId)
        
        // When
        networkPublishers
            .redirectSubject
            .eraseToAnyPublisher()
            .sink { _ in
            } receiveValue: { redirectURLRequest in
                if redirectURLRequest.url != nil {
                    actualRedirections += 1
                }
            }
            .store(in: &subscriptions)
        
        networkPublishers
            .responseSubject
            .eraseToAnyPublisher()
            .sink { completion in
                // Then
                XCTAssertEqual(actualRedirections, expectedRedirections, "We expected to get: \(expectedRedirections) redirects, and we actually got: \(actualRedirections) redirects")
                expectation.fulfill()
            } receiveValue: { _ in }
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: Self.expectationsTimeOut)
    }
    
    func test_maxNumberOfRedirects_unlimited() throws {
        // Given
        let expectedRedirections: UInt8 = 4
        var actualRedirections: UInt8 = 0
        
        let networkWebRepository = try XCTUnwrap(networkWebRepository)
        
        let expectation = expectation(description: "unlimitedRedirections")
        
        let networkPublishers = networkWebRepository.get(by: startRedirectId)
        
        // When
        networkPublishers
            .redirectSubject
            .eraseToAnyPublisher()
            .sink { _ in
            } receiveValue: { redirectURLRequest in
                if redirectURLRequest.url != nil {
                    actualRedirections += 1
                }
            }
            .store(in: &subscriptions)
        
        networkPublishers
            .responseSubject
            .eraseToAnyPublisher()
            .sink { completion in
                // Then
                XCTAssertEqual(actualRedirections, expectedRedirections, "We expected to get: \(expectedRedirections) redirects, and we actually got: \(actualRedirections) redirects")
                expectation.fulfill()
            } receiveValue: { _ in }
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: Self.expectationsTimeOut)
    }
    
    func test_maxNumberOfRedirects_limited() throws {
        // Given
        let expectedRedirections: UInt8 = 2
        var actualRedirections: UInt8 = 0
        
        var networkWebRepository = try XCTUnwrap(networkWebRepository)
        networkWebRepository.maxNumberOfRedirects = expectedRedirections
        
        let expectation = expectation(description: "limitedRedirections")
        
        let networkPublishers = networkWebRepository.get(by: startRedirectId)
        
        // When
        networkPublishers
            .redirectSubject
            .eraseToAnyPublisher()
            .sink { _ in
            } receiveValue: { redirectURLRequest in
                if redirectURLRequest.url != nil {
                    actualRedirections += 1
                }
            }
            .store(in: &subscriptions)
        
        networkPublishers
            .responseSubject
            .eraseToAnyPublisher()
            .sink { completion in
                // Then
                XCTAssertEqual(actualRedirections, expectedRedirections, "We expected to get: \(expectedRedirections) redirects, and we actually got: \(actualRedirections) redirects")
                expectation.fulfill()
            } receiveValue: { _ in }
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: Self.expectationsTimeOut)
    }
    
    func test_getDataFromUrl() throws {
        // Given
        let networkWebRepository = try XCTUnwrap(networkWebRepository)
        let expectation = expectation(description: "getDataFromUrl")
        
        let networkPublishers = networkWebRepository.get(by: startRedirectId)
        
        // When
        networkPublishers
            .responseSubject
            .eraseToAnyPublisher()
            .sink { completion in
                expectation.fulfill()
            } receiveValue: { data in
                // Then
                XCTAssertNotNil(data?.description)
                XCTAssertEqual(data?.description, "[\"hello\": world]")
            }
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: Self.expectationsTimeOut)
    }
    
    func test_invalidBaseUrl() throws {
        // Given
        var networkWebRepository = try XCTUnwrap(networkWebRepository)
        networkWebRepository.baseURL = "empty"
        
        let expectation = expectation(description: "invalidUrl")
        let expectedResult = WebError.invalidURL.localizedDescription
        
        let networkPublishers = networkWebRepository.get(by: startRedirectId)
        
        // When
        networkPublishers
            .responseSubject
            .eraseToAnyPublisher()
            .sink { completion in
                // Then
                switch completion {
                case .finished:
                    XCTFail("We try to get data from invalid base url: \(networkWebRepository.baseURL)")
                case let .failure(error):
                    XCTAssertEqual(error.localizedDescription, expectedResult, "When loading an invalid URL, we expect to receive WebError.invalidURL")
                }
                expectation.fulfill()
            } receiveValue: { _ in }
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: Self.expectationsTimeOut)
    }
    
    func test_generalError_multipleRedirects() throws {
        // Given
        let expectedRedirections: UInt8 = 1
        
        var networkWebRepository = try XCTUnwrap(networkWebRepository)
        networkWebRepository.maxNumberOfRedirects = expectedRedirections
        
        let expectation = expectation(description: "multipleRedirectsError")
        
        let networkPublishers = networkWebRepository.get(by: startRedirectId)
        
        // When
        networkPublishers
            .errorSubject
            .eraseToAnyPublisher()
            .sink { completion in
                // Then
                XCTAssertEqual(completion, .failure(.multipleRedirects), "We expect to get multiple redirects error")
                expectation.fulfill()
            } receiveValue: { _ in }
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: Self.expectationsTimeOut)
    }
    
    func test_generalError_invalidUrl() throws {
        // Given
        var networkWebRepository = try XCTUnwrap(networkWebRepository)
        networkWebRepository.baseURL = "empty"
        
        let expectation = expectation(description: "invalidUrlError")
        
        let networkPublishers = networkWebRepository.get(by: startRedirectId)
        
        // When
        networkPublishers
            .errorSubject
            .eraseToAnyPublisher()
            .sink { completion in
                // Then
                XCTAssertEqual(completion, .failure(.invalidUrl), "We expect to get invalid URL error")
                expectation.fulfill()
            } receiveValue: { _ in }
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: Self.expectationsTimeOut)
    }
    
    func test_generalError_invalidData() throws {
        // Given
        let networkWebRepository = try XCTUnwrap(networkWebRepository)
        if let testUrl = URL(string: "http://www.mocky.io/v2/5e0af421330000250020a7eb") {
            networkWebRepository.insertRedirect(url: testUrl)
            networkWebRepository.insertRedirect(url: testUrl)
        }
        
        let expectation = expectation(description: "invalidUrlError")
        
        let networkPublishers = networkWebRepository.get(by: startRedirectId)
        
        // When
        networkPublishers
            .errorSubject
            .eraseToAnyPublisher()
            .sink { completion in
                // Then
                XCTAssertEqual(completion, .failure(.circularRedirect), "We expect to get circular redirect error")
                expectation.fulfill()
            } receiveValue: { _ in }
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: Self.expectationsTimeOut)
    }
    
    override func tearDown() {
        subscriptions.removeAll()
        networkWebRepository = nil
        super.tearDown()
    }
}
