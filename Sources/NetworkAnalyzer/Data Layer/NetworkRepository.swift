//
//  NetworkRepository.swift
//
//
//  Created by Lior Tal on 02/07/2021.
//

import Foundation
import Combine

public protocol NetworkWebRepository: WebRepository {
    var baseURL: String { get set }
    var maxNumberOfRedirects: UInt8 { get set }
    
    func get(by id: String) -> NetworkRepositoryPublishers
    
    #if DEBUG
    func insertRedirect(url: URL)
    #endif
}

public class NetworkRepository: NSObject, NetworkWebRepository {
    public var baseURL: String
    public var maxNumberOfRedirects: UInt8
    public private(set) var bgQueue = DispatchQueue(label: "network_web_repository_queue")
    
    /// Set a queue for URLSession
    private lazy var delegateOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "session_delegate_queue"
        queue.qualityOfService = .default
        return queue
    }()
    
    /// Configure URLSession with a delegate to get the URL redirects
    public private(set) lazy var session = URLSession(configuration: .default,
                                                      delegate: self,
                                                      delegateQueue: delegateOperationQueue)
    
    /// Publishers Wrapper that contains: response, error, and redirect subjects
    private let publishers = NetworkRepositoryPublishers()
    private var subscriptions = Set<AnyCancellable>()
    
    /// Redirected URLs viewed
    private var redirectURLs = Set<URL>()
    
    /// Initialize NetworkRepository
    /// - Parameters:
    ///   - baseURL: Base URL for retrieving data from the server
    ///   - maxNumberOfRedirects: The maximum number of redirects allowed
    public init(baseURL: String, maxNumberOfRedirects: UInt8) {
        self.baseURL = baseURL
        self.maxNumberOfRedirects = maxNumberOfRedirects
    }
    
    /// Retrieve data from the server for a given id
    /// - Parameter id: An id to be added to the URL path
    /// - Returns: NetworkRepositoryPublishers Wrapper that contains: response, error, and redirect subjects
    public func get(by id: String) -> NetworkRepositoryPublishers {
        call(endpoint: NetworkEndpoint.get(id))
            .eraseToAnyPublisher()
            .sink { completion in
                switch completion {
                case .failure(WebError.invalidURL):
                    self.publishers.errorSubject.send(completion: .failure(.invalidUrl))
                default:
                    break
                }
                self.publishers.responseSubject.send(completion: completion)
            } receiveValue: { data in
                self.publishers.responseSubject.send(data)
            }
            .store(in: &subscriptions)
        
        return publishers
    }
    
    deinit {
        subscriptions.removeAll()
        redirectURLs.removeAll()
    }
}

// MARK: - URLSessionTaskDelegate
extension NetworkRepository: URLSessionTaskDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        guard let url = request.url,
              HTTPError(code: response.statusCode) == .movedPermanently
        else {
            completionHandler(nil)
            return
        }
        
        // Check circular redirect
        guard !redirectURLs.contains(url) else {
            publishers.errorSubject.send(completion: .failure(.circularRedirect))
            completionHandler(nil)
            return
        }
        
        redirectURLs.insert(url)
        
        // Check multiple redirects
        guard maxNumberOfRedirects > 0 else {
            publishers.errorSubject.send(completion: .failure(.multipleRedirects))
            completionHandler(nil)
            return
        }
        
        maxNumberOfRedirects -= 1
        publishers.redirectSubject.send(request)
        completionHandler(request)
    }
}

// MARK: - For tests
#if DEBUG
extension NetworkRepository {
    /// Add a URL redirect to redirectURLs Set
    /// - Parameter url: URL that will be inserted to the set
    public func insertRedirect(url: URL) {
        redirectURLs.insert(url)
    }
}
#endif
