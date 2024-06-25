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
    
    @State var emailPromptUrl: URL?
    
    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction(handler: didReceiveURL))
            .popover(item: $emailPromptUrl) { _ in
            }
    }
    
    @MainActor
    func didReceiveURL(_ url: URL) -> OpenURLAction.Result {
        guard let scheme = url.scheme else {
            openSafariView(url: url)
            return .handled
        }
        if scheme == "mailto" {
            if parseEmail(url: url) { return .handled }
        }
        
        guard let host = url.host(), scheme.starts(with: "https://") else {
            openSafariView(url: url)
            return .handled
        }
        if isLemmyHost(host) {
            if interpretLemmyUrlPath(url: url) {
                return .handled
            }
        }
        openSafariView(url: url)
        return .handled
    }
    
    func interpretLemmyUrlPath(url: URL) -> Bool {
        let components = url.pathComponents.dropFirst()
        if components.isEmpty {
            // TODO: instance
        }
        switch components.first {
        case "u":
            navigation.push(.person(PersonStub(api: appState.firstApi, actorId: url)))
            return true
        case "c":
            // TODO: community
            break
        case "post":
            if components.count == 2 {
                navigation.push(.expandedPost(PostStub(api: appState.firstApi, actorId: url)))
                return true
            } else if components.count == 3 {
                // TODO: comment
            }
        case "comment":
            // TODO: comment (again)
            break
        default:
            break
        }
        return false
    }
    
    func parseEmail(url: URL) -> Bool {
        let parts = url.absoluteString.split(separator: "@")
        guard parts.count == 2 else { return false }
        let user = String(parts[0])
        let host = String(parts[1])
        if isLemmyHost(host) {
            let toastId = ToastModel.main.add(.loading)
            Task {
                let personStub = PersonStub(api: appState.firstApi, actorId: URL(string: "https://\(host)/u/\(user)")!)
                let communityStub = CommunityStub(api: appState.firstApi, actorId: URL(string: "https://\(host)/c/\(user)")!)
            }
        }
        return true
    }
    
    func isLemmyHost(_ host: String) -> Bool {
        MlemStats.main.hosts?.contains(host) ?? false
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

private extension SFSafariViewController.Configuration {
    /// The default settings used in this application
    static var `default`: Self {
        let configuration = Self()
        @AppStorage("links.readerMode") var openLinksInReaderMode = false
        configuration.entersReaderIfAvailable = openLinksInReaderMode
        return configuration
    }
}
