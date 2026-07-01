//
//  HandleLemmyLinksModifier.swift
//  Mlem
//
//  Created by Sjmarf on 25/06/2024.
//

import MlemMiddleware
import SafariServices
import SwiftUI

/// Modifier that overrides the `openURL` environment variable and attempts to open threadiverse links in-app.
struct HandleThreadiverseLinksModifier: ViewModifier {
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
        "threadiverse.link",
        "vger.to"
    ]
    
    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction(handler: didReceiveURL))
            .onChange(of: navigation.model?.pendingOpenURL) { _, url in
                if let url {
                    navigation.model?.pendingOpenURL = nil
                    _ = didReceiveURL(url)
                }
            }
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
    
    // swiftlint:disable:next cyclomatic_complexity
    @MainActor func didReceiveURL(_ url: URL) -> OpenURLAction.Result {
        // TODO: Consider handling links to alternative frontends such as `old.lemmy.world` or `oldsh.itjust.works`.
        
        guard let scheme = url.scheme else {
            // LemmyMarkdownUI parses the `/c/comm@example.com` and `!comm@example.com` link formats into regular links,
            // so those don't need to be handled in this method. However, it doesn't parse links written in the format
            // [Some text](/c/comm@example.com), which is a format that lemmy-ui supports. Those links are handled here.
            // Later, it might be better to move that into LemmyMarkdownUI, but I think we'd need to modify the core
            // cmark code rather than just the extensions, which isn't ideal.
            
            if let newUrl = createLemmyUrlFromShortcut(parts: url.pathComponents), let page = createNavigationPage(url: newUrl) {
                navigation.push(page)
                return .handled
            }
            
            openLinkAsWebsite(url: url)
            return .handled
        }

        if url.host() == "canvas.fediverse.events" {
            handleCanvasLink(url: url)
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
            openLinkAsWebsite(url: url)
            return .handled
        }
        
        if Self.instanceMultiplexerDomains.contains(host), url.pathComponents.count > 3 {
            var components = URLComponents()
            components.scheme = "https"
            components.host = url.pathComponents[1]
            components.path = "/" + url.pathComponents.dropFirst(2).joined(separator: "/")
            if let newUrl = components.url, let page = createNavigationPage(url: newUrl) {
                navigation.push(page)
                return .handled
            }
        }
        
        // If the link is in our threadiverse domain list, push a page to the NavigationStack straight away
        if isThreadiverseHost(host), let page = createNavigationPage(url: url) {
            navigation.push(page)
            return .handled
        }
        
        let components = url.pathComponents.dropFirst()
        
        // Super-small instances may not appear in the threadiverse domain list, in which case we show a
        // "Loading..." toast whilst we attempt to work out if it's actually a threadiverse link
        if ["u", "c", "post", "comment"].contains(components.first) {
            // The "@" check ensures that KBin links are excluded
            if !host.contains("reddit.com"), components.count == 2, components[1].first != "@" {
                Task {
                    await showToastAndResolve(url: url) { url in
                        openLinkAsWebsite(url: url)
                    }
                }
                return .handled
            }
        }
        
        // If all else fails, fallback to opening in browser
        openLinkAsWebsite(url: url)
        return .handled
    }
    
    // Creates https://example.com/c/comm from /c/comm@example.com or example.com/c/comm
    func createLemmyUrlFromShortcut(parts: [String]) -> URL? {
        var parts = parts
        
        var components = URLComponents()
        components.scheme = "https"
        
        if parts[0] != "/" {
            guard parts.count == 3 else { return nil }
            guard parts[1] == "c" || parts[1] == "u" else { return nil }
            components.host = parts[0]
            components.path = "/\(parts[1])/\(parts[2])"
        } else {
            parts.removeFirst()
            guard parts.count == 2 else { return nil }
            guard parts[0] == "c" || parts[0] == "u" else { return nil }
            let fullNameParts = parts[1].split(separator: "@")
            components.host = String(fullNameParts[1])
            components.path = "/\(parts[0])/\(fullNameParts[0])"
        }
        return components.url
    }
    
    func createNavigationPage(url: URL) -> NavigationPage? {
        let components = Array(url.pathComponents.dropFirst())
        if components.isEmpty, let host = url.host() {
            return .instanceStub(InstanceStub(api: appState.firstApi, actorId: .instance(host: host)))
        }
        switch components.first {
        case "u":
            return .personStub(PersonStub(api: appState.firstApi, url: url))
        case "c":
            // Handle links that look like this:
            // https://piefed.social/c/politics/p/1385905/will-the-supreme-court-hand-government-contractors-blanket-immunity
            if components.count > 4, components[2] == "p" {
                let newUrl = url.removingPathComponents().appendingPathComponent("post/\(components[3])")
                return .postStub(PostStub(api: appState.firstApi, url: newUrl))
            } else {
                return .communityStub(CommunityStub(api: appState.firstApi, url: url))
            }
        case "post":
            if let fragment = url.fragment()?.trimmingPrefix("comment_") {
                let newUrl = url.removingPathComponents().appendingPathComponent("comment/\(fragment)")
                return .commentStub(CommentStub(api: appState.firstApi, url: newUrl))
            } else if components.count == 2 {
                return .postStub(PostStub(api: appState.firstApi, url: url))
            } else if components.count == 3 {
                let newUrl = url.removingPathComponents().appendingPathComponent("comment/\(url.lastPathComponent)")
                return .commentStub(CommentStub(api: appState.firstApi, url: newUrl))
            } else {
                return nil
            }
        case "comment":
            return .commentStub(CommentStub(api: appState.firstApi, url: url))
        default:
            return nil
        }
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
        } else if isThreadiverseHost(host) {
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

    func handleCanvasLink(url: URL) {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var queryItems = components?.queryItems ?? []
        queryItems.append(.init(name: "fediverse-auth[exchanger]", value: "mlem://fediverse-auth/login"))
        components?.queryItems = queryItems
        guard let newUrl = components?.url else {
            assertionFailure()
            openLinkAsWebsite(url: url)
            return
        }
        openLinkAsWebsite(url: newUrl)
    }
    
    func showToastAndResolve(url: URL, fallback: @escaping (URL) -> Void) async {
        let toastId = ToastModel.main.add(.loading())
        var output: (any Sharable)?
        do {
            output = try await appState.firstApi.resolve(url: url)
        } catch {
            output = nil
            handleError(error, silent: true)
        }
        if output == nil {
            // Retry on local instance, which is needed if there is a federation boundary
            output = try? await ApiClient.getApiClient(
                url: url.removingPathComponents(),
                username: nil
            ).resolve(url: url)
        }

        if let person = output as? Person {
            navigation.push(.person(person))
        } else if let community = output as? Community {
            navigation.push(.community(community))
        } else if let post = output as? Post {
            navigation.push(.post(post))
        } else if let comment = output as? Comment {
            navigation.push(.comment(comment))
        } else {
            fallback(url)
        }
        ToastModel.main.removeToast(id: toastId)
    }
    
    func isThreadiverseHost(_ host: String) -> Bool {
        MlemStats.main.hosts.contains(host)
    }
}

func openLinkAsWebsite(url: URL) {
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
