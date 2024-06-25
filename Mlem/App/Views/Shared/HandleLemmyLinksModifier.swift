//
//  HandleLemmyLinksModifier.swift
//  Mlem
//
//  Created by Sjmarf on 25/06/2024.
//

import MlemMiddleware
import SafariServices
import SwiftUI

struct HandleLemmyLinksModifier: ViewModifier {
    @Environment(NavigationLayer.self) var navigation
    @Environment(AppState.self) var appState
    
    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction(handler: didReceiveURL))
    }
    
    @MainActor
    func didReceiveURL(_ url: URL) -> OpenURLAction.Result {
        guard let host = url.host() else {
            openSafariView(url: url)
            return .handled
        }
        if MlemStats.main.hosts?.contains(host) ?? false {
            let components = url.pathComponents.dropFirst()
            if components.isEmpty {
                // TODO: instance
            }
            switch components.first {
            case "u":
                navigation.push(.person(PersonStub(api: appState.firstApi, actorId: url)))
                return .handled
            case "c":
                // TODO: community
                break
            case "post":
                if components.count == 2 {
                    navigation.push(.expandedPost(PostStub(api: appState.firstApi, actorId: url)))
                    return .handled
                } else if components.count == 3 {
                    // TODO: comment
                }
            case "comment":
                // TODO: comment (again)
                break
            default:
                break
            }
        }
        openSafariView(url: url)
        return .handled
    }
    
    func openSafariView(url: URL) {
        @AppStorage("links.openInBrowser") var openLinksInBrowser = false
        
        if let scheme = url.scheme, scheme.hasPrefix("http"), !openLinksInBrowser {
            Task { @MainActor in
                let viewController = SFSafariViewController(url: url, configuration: .default)
                UIApplication.shared.firstKeyWindow?.rootViewController?.topMostViewController().present(viewController, animated: true)
            }
        } else {
            UIApplication.shared.open(url)
        }
    }
}

extension SFSafariViewController.Configuration {
    /// The default settings used in this application
    static var `default`: Self {
        let configuration = Self()
        @AppStorage("links.readerMode") var openLinksInReaderMode = false
        configuration.entersReaderIfAvailable = openLinksInReaderMode
        return configuration
    }
}
