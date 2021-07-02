//
//  NetworkEndpoint.swift
//  
//
//  Created by Lior Tal on 03/07/2021.
//

import Foundation

extension NetworkRepository {
    enum NetworkEndpoint: Endpoint {
        case get(String)
        
        var path: String {
            switch self {
            case .get(let id):
                return "/\(id)"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .get:
                return .get
            }
        }
        
        var headers: [String : String]? {
            ["Content-Type": "application/json"]
        }
        
        func body() throws -> Data? {
            return nil
        }
    }
}
