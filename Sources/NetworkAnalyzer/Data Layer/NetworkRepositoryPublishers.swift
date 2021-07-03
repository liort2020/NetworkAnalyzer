//
//  NetworkRepositoryPublishers.swift
//  
//
//  Created by Lior Tal on 03/07/2021.
//

import Foundation
import Combine

/// Wrapper that contains: response, error, and redirect publishers
public class NetworkRepositoryPublishers {
    public typealias ResponseSubject = PassthroughSubject<[String: AnyObject]?, Error>
    public typealias ErrorSubject = PassthroughSubject<Never, GeneralError>
    public typealias RedirectSubject = PassthroughSubject<URLRequest, Never>
    
    public var responseSubject = ResponseSubject()
    public var errorSubject = ErrorSubject()
    public var redirectSubject = RedirectSubject()
}
