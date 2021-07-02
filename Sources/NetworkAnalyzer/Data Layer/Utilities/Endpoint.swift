//
//  Endpoint.swift
//  
//
//  Created by Lior Tal on 03/07/2021.
//

import Foundation

public protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    
    func body() throws -> Data?
}

extension Endpoint {
    /// Configure request URL to fetch data from the server
    /// - Parameter url: URL path
    /// - Throws: Throw invalid URL error
    /// - Returns: Optional URLRequest that we will use to fetch data from the server
    public func request(url: String) throws -> URLRequest? {
        let urlPath = url + path
        guard urlPath.isValidURL(), let url = URL(string: urlPath) else {
            throw WebError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = try body()
        return urlRequest
    }
}

fileprivate extension String {
    /// Check if the specified URL is valid
    /// - Returns: valid or not
    func isValidURL() -> Bool {
        // Detect URLs inside a string
        guard let dataDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue),
              let match = dataDetector.firstMatch(in: self,
                                               options: [],
                                               range: NSRange(location: 0, length: self.utf16.count))
        else { return false }
        
        return match.range.length == utf16.count
    }
}
