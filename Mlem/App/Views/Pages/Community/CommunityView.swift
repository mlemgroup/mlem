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
    
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    
    @State var community: AnyCommunity
    @State private var selectedTab: Tab = .posts
    @State var showRefreshPopup: Bool = false
    @State var postFeedLoader: CommunityPostFeedLoader?
    
    init(community: AnyCommunity) {
        self.community = community
    }
    
    var body: some View {
        ContentLoader(model: community) { proxy in
            if let community = proxy.entity, let postFeedLoader {
                content(community: community, postFeedLoader: postFeedLoader)
                    .refreshable {
                        showRefreshPopup = false
                        do {
                            try await postFeedLoader.refresh(clearBeforeRefresh: false)
                        } catch {
                            handleError(error)
                        }
                    }
                    .onChange(of: appState.firstApi, initial: false) {
                        showRefreshPopup = true
                    }
                    .overlay(alignment: .bottom) {
                        if selectedTab == .posts {
                            RefreshPopupView("Feed is outdated", isPresented: $showRefreshPopup) {
                                Task {
                                    do {
                                        showRefreshPopup = false
                                        try await postFeedLoader.refresh(clearBeforeRefresh: true)
                                    } catch {
                                        handleError(error)
                                    }
                                }
                            }
                        }
                    }
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
        } upgradeOperation: { model, api in
            try await model.upgrade(api: api, upgradeOperation: nil)
            if let community = model.wrappedValue as? any Community {
                if postFeedLoader == nil {
                    setupFeedLoader(community: community)
                } else if postFeedLoader?.community.api != community.api {
                    postFeedLoader?.community = community
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
        
    @ViewBuilder
    func content(community: any Community, postFeedLoader: CommunityPostFeedLoader) -> some View {
        FancyScrollView {
            HStack {
                FeedHeaderView(
                    title: Text(community.displayName),
                    subtitle: Text(community.fullNameWithPrefix ?? ""),
                    dropdownStyle: .disabled,
                    image: { AvatarView(community) }
                )
                subscribeButton(community: community)
            }
            BubblePicker(
                tabs(community: community),
                selected: $selectedTab,
                withDividers: [.top, .bottom],
                label: \.label
            )
            VStack {
                switch selectedTab {
                case .posts:
                    postsTab(community: community, postFeedLoader: postFeedLoader)
                case .about:
                    aboutTab(community: community)
                default:
                    EmptyView()
                }
            }
            .environment(\.communityContext, community)
        }
        .loadFeed(postFeedLoader)
    }
    
    @ViewBuilder
    func postsTab(community: any Community, postFeedLoader: CommunityPostFeedLoader) -> some View {
        PostGridView(postFeedLoader: postFeedLoader)
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
    
    @ViewBuilder
    func subscribeButton(community: any Community) -> some View {
        let subscribed = community.subscribed_ ?? false
        Button {
            if community.api.willSendToken {
                community.toggleSubscribe(feedback: [.haptic])
            }
        } label: {
            HStack {
                Text((community.subscriberCount_ ?? 0).abbreviated)
                Image(systemName: subscribed ? Icons.successCircleFill : Icons.user)
                    .symbolRenderingMode(.hierarchical)
            }
            .fontWeight(.semibold)
            .padding(.vertical, 3)
            .padding(.trailing, 6)
            .padding(.leading, 8)
            .background(subscribed ? palette.accent : palette.secondary.opacity(0.2), in: .capsule)
            .foregroundStyle(subscribed ? palette.selectedInteractionBarItem : palette.secondary)
        }
        .padding(.trailing, AppConstants.standardSpacing)
        .padding(.bottom, AppConstants.halfSpacing)
    }
    
    func tabs(community: any Community) -> [Tab] {
        var output: [Tab] = [.posts, .moderation, .details]
        if community.description != nil || community.banner != nil {
            output.insert(.about, at: 1)
        }
        return output
    }
    
    func setupFeedLoader(community: any Community) {
        @AppStorage("behavior.internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("behavior.upvoteOnSave") var upvoteOnSave = false
        @AppStorage("feed.showRead") var showReadPosts = true
        @AppStorage("post.defaultSort") var defaultSort: ApiSortType = .hot
        
        postFeedLoader = .init(
            pageSize: internetSpeed.pageSize,
            sortType: .new,
            showReadPosts: showReadPosts,
            filteredKeywords: [],
            smallAvatarSize: AppConstants.smallAvatarSize,
            largeAvatarSize: AppConstants.largeAvatarSize,
            urlCache: AppConstants.urlCache,
            community: community
        )
    }
}
