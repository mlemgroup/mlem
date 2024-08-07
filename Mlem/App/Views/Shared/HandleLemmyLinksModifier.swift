//
//  HandleLemmyLinksModifier.swift
//  Mlem
//
//  Created by Sjmarf on 25/06/2024.
//

import MlemMiddleware
import SafariServices
import SwiftUI

/// Modifier that overrides the `openURL` environment variable and attempts to open Lemmy links in-app.
struct HandleLemmyLinksModifier: ViewModifier {
    @Environment(NavigationLayer.self) var navigation
    @Environment(AppState.self) var appState
    
    // If a link in the `user@example.com` format is clicked, it opens in the Mail app
    // immediately for these domains. For all other domains, Mlem will attempt to
    // resolve it as a Lemmy link first.
    private static let emailDomains: Set<String> = [
        "hotmail.com",
        "gmail.com",
        "yahoo.com",
        "icloud.com",
        "outlook.com",
        "zoho.com",
        "aol.com",
        "yandex.com",
        "sky.com",
        "bt.com",
        "btinternet.com"
    ]
    
    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction(handler: didReceiveURL))
    }
    
    @MainActor
    func didReceiveURL(_ url: URL) -> OpenURLAction.Result {
        // We don't need to decode `/c/comm@example.com` or `!comm@example.com` formats in this method
        // - LemmyMarkdownUI converts those links into `https://example.com/c/comm` format during parsing.
        
        // TODO: Consider handling links to alternative frontends such as `old.lemmy.world` or `oldsh.itjust.works`.
        
        guard let scheme = url.scheme else {
            openRegularLink(url: url)
            return .handled
        }
        
        // `user@example.com` isn't recognised by Lemmy, and doesn't appear as a clickable link in lemmy-ui.
        // The *correct* syntax is `@user@example.com`, but occasionally someone doesn't know this and
        // types `user@example.com` instead. We handle this case by attempting to parse as a Lemmy link, and
        // falling back to opening the Mail app if that fails.
        if scheme == "mailto" {
            if parseEmail(url: url) { return .handled }
        }
        
        guard let host = url.host(), scheme.starts(with: "http") else {
            openRegularLink(url: url)
            return .handled
        }
        
        // If the link is in our Lemmy domain list, push a page to the NavigationStack straight away
        if isLemmyHost(host), interpretLemmyUrlPath(url: url) {
            return .handled
        }
        
        let components = url.pathComponents.dropFirst()
        
        // Super-small instances may not appear in the Lemmy domain list, in which case we show a
        // "Loading..." toast whilst we attempt to work out if it's actually a Lemmy link
        if ["u", "c", "post", "comment"].contains(components.first) {
            // The "@" check ensures that KBin links are excluded
            if !host.contains("reddit.com"), components.count == 2, components[1].first != "@" {
                Task {
                    await showToastAndLoad(url: url)
                }
                return .handled
            }
        }
        
        // If all else fails, fallback to opening in browser
        openRegularLink(url: url)
        return .handled
    }
    
    func interpretLemmyUrlPath(url: URL) -> Bool {
        let components = url.pathComponents.dropFirst()
        if components.isEmpty {
            navigation.push(.instance(InstanceStub(api: appState.firstApi, actorId: url)))
            return true
        }
        switch components.first {
        case "u":
            navigation.push(.person(PersonStub(api: appState.firstApi, actorId: url)))
            return true
        case "c":
            navigation.push(.community(CommunityStub(api: appState.firstApi, actorId: url)))
            return true
        case "post":
            if components.count == 2 {
                navigation.push(.expandedPost(PostStub(api: appState.firstApi, actorId: url)))
                return true
            } else if components.count == 3 {
                // TODO: comment in format `lemmy.world/post/21312/34534`
                return true
            }
        case "comment":
            // TODO: comment
            return true
        default:
            break
        }
        return false
    }
    
    func parseEmail(url: URL) -> Bool {
        let parts = url.absoluteString.trimmingPrefix("mailto:").split(separator: "@")
        guard parts.count == 2 else { return false }
        let user = String(parts[0])
        let host = String(parts[1])
        if !Self.emailDomains.contains(host) {
            Task {
                await showToastAndLoad(url: URL(string: "https://\(host)/u/\(user)")!)
            }
        }
        return true
    }
    
    func showToastAndLoad(url: URL) async {
        let toastId = ToastModel.main.add(.loading())
        var output = try? await appState.firstApi.resolve(actorId: url)
        if output == nil {
            // Retry on local instance, which is needed if there is a federation boundary
            output = try? await ApiClient.getApiClient(
                for: url.removingPathComponents(),
                with: nil
            ).resolve(actorId: url)
        }

        if let person = output as? any Person {
            navigation.push(.person(person))
        } else if let community = output as? any Community {
            navigation.push(.community(community))
        } else {
            openRegularLink(url: url)
        }
        ToastModel.main.removeToast(id: toastId)
    }
    
    func isLemmyHost(_ host: String) -> Bool {
        MlemStats.main.hosts.contains(host)
    }
}

func openRegularLink(url: URL) {
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

private extension SFSafariViewController.Configuration {
    /// The default settings used in this application
    static var `default`: Self {
        let configuration = Self()
        @AppStorage("links.readerMode") var openLinksInReaderMode = false
        configuration.entersReaderIfAvailable = openLinksInReaderMode
        return configuration
    }
}
