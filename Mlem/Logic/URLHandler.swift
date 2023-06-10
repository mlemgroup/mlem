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
        #warning("TODO: consider how we might deep link within the application for urls such as '/c/<community_name>' and '/post/<post_id>'")
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
