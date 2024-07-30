//
//  CommunityView.swift
//  Mlem
//
//  Created by Sjmarf on 30/07/2024.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct CommunityView: View {
    enum Tab: String, CaseIterable, Identifiable {
        case posts, comments, about, moderation, details

        var id: Self { self }
        var label: LocalizedStringResource {
            switch self {
            case .posts: "Posts"
            case .comments: "Comments"
            case .about: "About"
            case .moderation: "Moderation"
            case .details: "Details"
            }
        }
    }
    
    @AppStorage("test") var test: Bool = false
    
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    
    @State var community: AnyCommunity
    @State private var selectedTab: Tab = .posts
    @State private var isAtTop: Bool = true
    
    var body: some View {
        ContentLoader(model: community) { proxy in
            if let community = proxy.entity {
                content(community: community)
                    .externalApiWarning(entity: community, isLoading: proxy.isLoading)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            if community is any Community3Providing, proxy.isLoading {
                                ProgressView()
                            } else {
                                ToolbarEllipsisMenu(community.menuActions(navigation: navigation))
                            }
                        }
                    }
            } else {
                ProgressView()
                    .tint(palette.secondary)
            }
        }
        .onPreferenceChange(IsAtTopPreferenceKey.self, perform: { value in
            isAtTop = value
        })
        .navigationTitle(isAtTop ? "" : (community.wrappedValue.displayName_ ?? community.wrappedValue.name))
        .navigationBarTitleDisplayMode(.inline)
    }
        
    @ViewBuilder
    func content(community: any Community) -> some View {
        FancyScrollView {
            FeedHeaderView(
                title: Text(community.displayName),
                subtitle: Text(community.fullNameWithPrefix ?? ""),
                dropdownStyle: .disabled,
                image: { AvatarView(community) }
            )
            BubblePicker(
                tabs(community: community),
                selected: $selectedTab,
                withDividers: [.top, .bottom],
                label: \.label
            )
            switch selectedTab {
            case .about:
                aboutTab(community: community)
            default:
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    func aboutTab(community: any Community) -> some View {
        VStack(spacing: AppConstants.standardSpacing) {
            if let banner = community.banner {
                TappableImageView(url: banner)
            }
            if let description = community.description {
                Markdown(description, configuration: .default)
            }
        }
        .padding(AppConstants.standardSpacing)
    }
    
    func tabs(community: any Community) -> [Tab] {
        var output: [Tab] = [.posts, .about, .details]
        if community.description != nil || community.banner != nil {
            output.insert(.moderation, at: 2)
        }
        return output
    }
}
