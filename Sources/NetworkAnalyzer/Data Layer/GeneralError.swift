//
//  GeneralError.swift
//  
//
//  Created by Lior Tal on 03/07/2021.
//

import Foundation

/// The error that our framework can throw
public enum GeneralError: Error {
    case invalidUrl
    case multipleRedirects
    case circularRedirect
}

extension GeneralError: LocalizedError {
    /// Error description that our framework can throw
    public var errorDescription: String? {
        switch self {
        case .invalidUrl:
            return NSLocalizedString("The url that provid is invalid.",
                                     comment: "GeneralError the user enter invalid URL")
        case .multipleRedirects:
            return NSLocalizedString("The number of redirections that we detect are more that what you provided.",
                                     comment: "My error")
        case .circularRedirect:
            return NSLocalizedString("The server return a circular redirect.",
                                     comment: "GeneralError server return a circular redirect")
        }
    }
}
