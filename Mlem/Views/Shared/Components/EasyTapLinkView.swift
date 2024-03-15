//
//  TappableLinkView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-12-08.
//

import Foundation
import SwiftUI

enum LinkDestinationType {
    case appRoute(AppRoute)
    case url(URL)
}

/// Enumerates the types of links
/// Equatable so that things like PostModel can be equatable
/// All cases have a 'position' int for sorting the list
enum LinkType {
    // TODO: capture internal Lemmy links:
    // - users
    // - communities
    // - posts
    // - comments
    
    case website(Int, String, URL) // position, link title, url
    case user(Int, String, String, URL) // position, username, instance, url
    case community(Int, String, String, URL) // position, community name, instance, url
    
    var title: String {
        switch self {
        case let .website(_, title, _):
            return title
        case let .user(_, username, _, _):
            return "/u/\(username)"
        case let .community(_, community, _, _):
            return "/c/\(community)"
        }
    }
    
    var position: Int {
        switch self {
        case
            let .website(position, _, _),
            let .user(position, _, _, _),
            let .community(position, _, _, _):
            return position
        }
    }
    
    var destinationType: LinkDestinationType {
        switch self {
        case
            let .website(_, _, url),
            let .user(_, _, _, url),
            let .community(_, _, _, url):
            return .url(url)
        }
    }
    
    var isWebsite: Bool {
        if case .website = self {
            return true
        }
        return false
    }
}

extension LinkType: Hashable, Identifiable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(position)
        switch self {
        case let .website(_, title, url):
            hasher.combine("website")
            hasher.combine(title)
            hasher.combine(url)
        case let .user(_, _, _, url):
            hasher.combine("user")
            hasher.combine(url)
        case let .community(_, _, _, url):
            hasher.combine("community")
            hasher.combine(url)
        }
    }
    
    var id: Int { hashValue }
}

enum EasyTapLinkDisplayMode: String, SettingsOptions {
    case disabled, compact, large, contextual
    
    var label: String { rawValue.capitalized }
    
    var id: Self { self }
}

struct EasyTapLinkView: View {
    @Environment(\.openURL) private var openURL
    
    let linkType: LinkType
    let showCaption: Bool
    
    var body: some View {
        switch linkType.destinationType {
        case let .appRoute(appRoute):
            NavigationLink(appRoute) {
                content
            }
        case let .url(url):
            content
                .onTapGesture {
                    openURL(url)
                }
                .contextMenu {
                    if linkType.isWebsite {
                        Button("Open", systemImage: Icons.browser) {
                            openURL(url)
                        }
                        Button("Copy", systemImage: Icons.copy) {
                            let pasteboard = UIPasteboard.general
                            pasteboard.url = url
                        }
                        ShareLink(item: url)
                    }
                } preview: { WebView(url: url) }
        }
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(linkType.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.secondary)
                .font(.subheadline)
                .bold()

            if showCaption {
                caption
                    .lineLimit(1)
            }
        }
        .padding(AppConstants.standardSpacing)
        .background(RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius)
            .foregroundColor(Color(UIColor.secondarySystemBackground)))
    }
    
    @ViewBuilder
    var caption: some View {
        switch linkType {
        case let .website(_, _, url):
            websiteCaption(url: url)
        case let .user(_, name, instance, _), let .community(_, name, instance, _):
            userOrCommunityCaption(name: name, instance: instance)
        }
    }
    
    private func websiteCaption(url: URL) -> some View {
        Text(url.description)
            .foregroundColor(.secondary)
            .font(.footnote)
    }
    
    private func userOrCommunityCaption(name: String, instance: String) -> some View {
        HStack(alignment: .center, spacing: 0) {
            Text(name)
                .foregroundColor(.secondary)
                .font(.footnote)
            
            Text("@\(instance)")
                .foregroundColor(.secondary)
                .font(.footnote)
                .opacity(0.5)
        }
    }
}
