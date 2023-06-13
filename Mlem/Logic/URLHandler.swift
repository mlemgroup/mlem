//
//  URLHandler.swift
//  Mlem
//
//  Created by Nicholas Lawson on 10/06/2023.
//

import SwiftUI
import SafariServices

/// A class that provides handling behaviour for `URL` actions
class URLHandler {
    
    @available(*, unavailable, message: "This handler should not be instantiated, please use static methods.")
    init() { /* class should not be instantiated */ }
    
    static func handle(_ url: URL) -> OpenURLAction.Result {
        guard let scheme = url.scheme, scheme.hasPrefix("http") else {
            // as the current handling only supports http(s) via Safari bail early if the scheme is unsupported...
            // a future piece of work will add deep linking where posssible with help of the ResolveObject API call
            return .discarded
        }
        
        let viewController = SFSafariViewController(url: url, configuration: .default)
        UIApplication.shared.firstKeyWindow?.rootViewController?.present(viewController, animated: true)
        return .handled
    }
}

extension SFSafariViewController.Configuration {
    /// The default settings used in this application
    static var `default`: Self {
        let configuration = Self.init()
        configuration.entersReaderIfAvailable = false
        return configuration
    }
}
