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
    
    /// The type of action to perform in response to the URL
    enum Action {
        case error(String)
    }
    
    struct Result {
        let result: OpenURLAction.Result
        let action: Action?
    }
    
    @available(*, unavailable, message: "This handler should not be instantiated, please use static methods.")
    init() { /* class should not be instantiated */ }
    
    /// A method to perform handling on URLs within the application
    /// - Parameter url: The `URL` you require to be handled
    /// - Returns: A `Result` containing to the system level `OpenURLAction.Result` and any application level actions to perform
    static func handle(_ url: URL) -> Result {
        guard let scheme = url.scheme, scheme.hasPrefix("http") else {
            // TODO: handle additional link types appropriately
            // as the current handling only supports http(s) via Safari bail early if the scheme is unsupported...
            // a future piece of work will add deep linking where possible with help of the `ResolveObject` API call
            return .init(result: .discarded, action: .error("This type of link is not currently supported 😞"))
        }
        
        // TODO: as part of the deep linking work we'd ideally move this to remain in a `SwiftUI` context...
        let viewController = SFSafariViewController(url: url, configuration: .default)
        UIApplication.shared.firstKeyWindow?.rootViewController?.present(viewController, animated: true)
        return .init(result: .handled, action: nil)
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
