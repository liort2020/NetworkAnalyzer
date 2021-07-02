//
//  WebRepository.swift
//  
//
//  Created by Lior Tal on 03/07/2021.
//

import Foundation
import Combine

public protocol WebRepository {
    var bgQueue: DispatchQueue { get }
    var session: URLSession { get }
    var baseURL: String { get }
}

extension WebRepository {
    /// Retrieve data from the server for a given URL request
    /// - Parameter endpoint: An endpoint that will provide the URL request to create a data task
    /// - Returns: A publisher that returns data from the server or throws WebError
    public func call(endpoint: Endpoint) -> AnyPublisher<[String: AnyObject]?, Error> {
        guard let urlRequest = try? endpoint.request(url: baseURL) else {
            return Fail(error: WebError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session
            .dataTaskPublisher(for: urlRequest)
            .tryMap { (data, response) in
                guard let response = response as? HTTPURLResponse else { throw WebError.noResponse }
                
                switch response.statusCode {
                case 301:
                    throw WebError.httpCode(.movedPermanently)
                case 200:
                    return try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                default:
                    return nil
                }
            }
            .subscribe(on: bgQueue)
            .eraseToAnyPublisher()
    }
}
