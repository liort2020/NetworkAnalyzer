//
//  WebError.swift
//  
//
//  Created by Lior Tal on 03/07/2021.
//

import Foundation

enum WebError: Error {
    case invalidURL
    case noResponse
    case httpCode(HTTPError)
}

enum HTTPError: Error {
    case movedPermanently
    case unknown
    
    /// Initial HTTPError with status code
    /// - Parameter code: HTTP status code that retrieved from the server
    init(code: Int) {
        switch code {
        case 301: self = .movedPermanently
        default: self = .unknown
        }
    }
}
