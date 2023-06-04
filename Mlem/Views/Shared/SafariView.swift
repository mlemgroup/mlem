//
//  SafariView.swift
//  Mlem
//
//  Created by Nicholas Lawson on 04/06/2023.
//

import SafariServices
import SwiftUI

extension SFSafariViewController.Configuration {
    /// The default settings used in this application
    static var `default`: Self {
        let configuration = Self.init()
        configuration.entersReaderIfAvailable = false
        return configuration
    }
}

/// A wrapper to allow use of `SFSafariViewController` in `SwiftUI` contexts
struct SafariView: UIViewControllerRepresentable {
    
    let url: URL
    let configuration: SFSafariViewController.Configuration
    
    init(url: URL, configuration: SFSafariViewController.Configuration = .default) {
        self.url = url
        self.configuration = configuration
    }

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<SafariView>
    ) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: UIViewControllerRepresentableContext<SafariView>
    ) {
        // no updates necessary
    }
}
