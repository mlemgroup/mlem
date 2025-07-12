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
    
    @State private var showingEmailAlert = false
    @State private var pendingMailtoURL: URL?
    
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
    
    private static let instanceMultiplexerDomains: Set<String> = [
        "lemmyverse.link",
        "threadiverse.link"
    ]
    
    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction(handler: didReceiveURL))
            .alert("Open Mail App", isPresented: $showingEmailAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Open") {
                    if let url = pendingMailtoURL {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("Would you like to open this email address in your mail app?")
            }
    }
    
    @MainActor
    func didReceiveURL(_ url: URL) -> OpenURLAction.Result {
        // TODO: Consider handling links to alternative frontends such as `old.lemmy.world` or `oldsh.itjust.works`.
        
        guard let scheme = url.scheme else {
            // LemmyMarkdownUI parses the `/c/comm@example.com` and `!comm@example.com` link formats into regular links,
            // so those don't need to be handled in this method. However, it doesn't parse links written in the format
            // [Some text](/c/comm@example.com), which is a format that lemmy-ui supports. Those links are handled here.
            // Later, it might  be better to move that into LemmyMarkdownUI, but I think we'd need to modify the core
            // cmark code rather than just the extensions, which isn't ideal.
            
            if let newUrl = createLemmyUrlFromShortcut(parts: url.pathComponents), interpretLemmyUrlPath(url: newUrl) {
                return .handled
            }
            
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
        
        if Self.instanceMultiplexerDomains.contains(host), url.pathComponents.count > 3 {
            var components = URLComponents()
            components.scheme = "https"
            components.host = url.pathComponents[1]
            components.path = "/" + url.pathComponents.dropFirst(2).joined(separator: "/")
            if let newUrl = components.url, interpretLemmyUrlPath(url: newUrl) { return .handled }
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
                    await showToastAndResolve(url: url) { url in
                        openRegularLink(url: url)
                    }
                }
                return .handled
            }
        }
        
        // If all else fails, fallback to opening in browser
        openRegularLink(url: url)
        return .handled
    }
    
    // Creates https://example.com/c/comm from /c/comm@example.com
    func createLemmyUrlFromShortcut(parts: [String]) -> URL? {
        var parts = parts
        parts.removeFirst()
        guard parts.count == 2 else { return nil }
        guard parts[0] == "c" || parts[0] == "u" else { return nil }
        var components = URLComponents()
        components.scheme = "https"
        let fullNameParts = parts[1].split(separator: "@")
        components.host = String(fullNameParts[1])
        components.path = "/\(parts[0])/\(fullNameParts[0])"
        return components.url
    }
    
    func interpretLemmyUrlPath(url: URL) -> Bool {
        let components = url.pathComponents.dropFirst()
        if components.isEmpty, let host = url.host() {
            navigation.push(.instance(InstanceStub(api: appState.firstApi, actorId: .instance(host: host))))
            return true
        }
        switch components.first {
        case "u":
            navigation.push(.person(PersonStub(api: appState.firstApi, url: url)))
            return true
        case "c":
            navigation.push(.community(CommunityStub(api: appState.firstApi, url: url)))
            return true
        case "post":
            if components.count == 2 {
                navigation.push(.post(PostStub(api: appState.firstApi, url: url)))
                return true
            } else if components.count == 3 {
                let newUrl = url.removingPathComponents().appendingPathComponent("comment/\(url.lastPathComponent)")
                navigation.push(.comment(CommentStub(api: appState.firstApi, url: newUrl)))
                return true
            }
        case "comment":
            navigation.push(.comment(CommentStub(api: appState.firstApi, url: url)))
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
        
        // For common email domains, show an alert asking if user wants to open mail app
        if Self.emailDomains.contains(host) {
            pendingMailtoURL = url
            showingEmailAlert = true
        } else if isLemmyHost(host) {
            // If it's a Lemmy host, try to resolve as a Lemmy user
            Task {
                await showToastAndResolve(url: URL(string: "https://\(host)/u/\(user)")!) { _ in
                    // If resolution fails, show email alert as fallback
                    pendingMailtoURL = url
                    showingEmailAlert = true
                }
            }
        } else {
            // If it's neither a common email domain nor a Lemmy host, show email alert
            pendingMailtoURL = url
            showingEmailAlert = true
        }
        
        return true
    }
    
    func showToastAndResolve(url: URL, fallback: @escaping (URL) -> Void) async {
        let toastId = ToastModel.main.add(.loading())
        var output = try? await appState.firstApi.resolve(url: url)
        if output == nil {
            // Retry on local instance, which is needed if there is a federation boundary
            output = try? await ApiClient.getApiClient(
                url: url.removingPathComponents(),
                username: nil
            ).resolve(url: url)
        }

        if let person = output as? any Person {
            navigation.push(.person(person))
        } else if let community = output as? any Community {
            navigation.push(.community(community))
        } else {
            fallback(url)
        }
        ToastModel.main.removeToast(id: toastId)
    }
    
    func isLemmyHost(_ host: String) -> Bool {
        MlemStats.main.hosts.contains(host)
    }
}

func openRegularLink(url: URL) {
    @Setting(\.links_openInBrowser) var openLinksInBrowser
    
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
        @Setting(\.links_readerMode) var openLinksInReaderMode
        configuration.entersReaderIfAvailable = openLinksInReaderMode
        return configuration
    }
}
