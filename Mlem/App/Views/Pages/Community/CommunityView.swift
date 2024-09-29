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
        
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    
    @Setting(\.postSize) var postSize
    @Setting(\.showNsfwCommunityWarning) var showNsfwCommunityWarning
    
    @State var community: AnyCommunity
    @State private var selectedTab: Tab = .posts
    @State var postFeedLoader: CommunityPostFeedLoader?
    @State var warningPresented: Bool
    
    @State var isAtTop: Bool = true
    
    init(community: AnyCommunity) {
        @Setting(\.showNsfwCommunityWarning) var showNsfwCommunityWarning
        self.community = community
        self._warningPresented = .init(wrappedValue: showNsfwCommunityWarning && (community.wrappedValue.nsfw_ ?? false))
    }
    
    var body: some View {
        ContentLoader(model: community) { proxy in
            if let community = proxy.entity {
                content(community: community)
                    .externalApiWarning(entity: community, isLoading: proxy.isLoading)
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
    func content(community: any Community) -> some View {
        FancyScrollView {
            HStack {
                FeedHeaderView(
                    title: Text(community.displayName),
                    subtitle: Text(community.fullNameWithPrefix ?? ""),
                    dropdownStyle: .disabled,
                    image: { CircleCroppedImageView(community, frame: 44) } // TODO: NOW 44 as constant
                )
                subscribeButton(community: community)
                    .padding(.top, Constants.main.halfSpacing)
            }
            BubblePicker(
                tabs(community: community),
                selected: $selectedTab,
                label: \.label
            )
            VStack {
                switch selectedTab {
                case .posts:
                    if let postFeedLoader {
                        postsTab(community: community, postFeedLoader: postFeedLoader)
                            .padding(.bottom, -4)
                    }
                case .about:
                    aboutTab(community: community)
                case .moderation:
                    FormSection { moderationTab(community: community) }
                        .padding([.horizontal, .bottom], Constants.main.standardSpacing)
                case .details:
                    CommunityDetailsView(community: community)
                default:
                    EmptyView()
                }
            }
            .environment(\.communityContext, community)
        }
        .background(palette.groupedBackground)
        .outdatedFeedPopup(feedLoader: postFeedLoader, showPopup: selectedTab == .posts)
        .navigationTitle(isAtTop ? "" : community.name)
        .isAtTopSubscriber(isAtTop: $isAtTop)
        .toolbar {
            ToolbarItemGroup(placement: .secondaryAction) {
                MenuButtons { community.menuActions(navigation: navigation) }
            }
        }
        .popupAnchor()
        .fullScreenCover(isPresented: $warningPresented) {
            nsfwWarningOverlay
                .presentationBackground(.ultraThinMaterial)
        }
    }
    
    @ViewBuilder
    func postsTab(community: any Community, postFeedLoader: CommunityPostFeedLoader) -> some View {
        PostGridView(postFeedLoader: postFeedLoader)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    FeedSortPicker(feedLoader: postFeedLoader)
                }
            }
    }

    @ViewBuilder
    func aboutTab(community: any Community) -> some View {
        VStack(spacing: Constants.main.standardSpacing) {
            if let banner = community.banner {
                LargeImageView(url: banner, shouldBlur: false)
            }
            if let description = community.description {
                Markdown(description, configuration: .default)
                    .padding(Constants.main.standardSpacing)
                    .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
            }
        }
        .padding([.horizontal, .bottom], Constants.main.standardSpacing)
    }
    
    @ViewBuilder
    func moderationTab(community: any Community) -> some View {
        VStack(spacing: 0) {
            ForEach(community.moderators_ ?? []) { person in
                PersonListRow(person)
                Divider()
                    .padding(.leading, 71)
            }
        }
        .background(palette.secondaryGroupedBackground)
        .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
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
                Image(systemName: subscribed ? Icons.successCircleFill : Icons.personCircle)
                    .symbolRenderingMode(.hierarchical)
            }
            .fontWeight(.semibold)
            .padding(.vertical, 3)
            .padding(.trailing, 6)
            .padding(.leading, 8)
            .background(subscribed ? palette.accent : palette.secondary.opacity(0.2), in: .capsule)
            .foregroundStyle(subscribed ? palette.selectedInteractionBarItem : palette.secondary)
        }
        .padding(.trailing, Constants.main.standardSpacing)
        .padding(.bottom, Constants.main.halfSpacing)
    }
    
    func tabs(community: any Community) -> [Tab] {
        var output: [Tab] = [.posts, .moderation, .details]
        if community.description != nil || community.banner != nil {
            output.insert(.about, at: 1)
        }
        return output
    }
    
    @ViewBuilder
    var nsfwWarningOverlay: some View {
        VStack(spacing: Constants.main.doubleSpacing) {
            WarningView(
                iconName: Icons.warning,
                text: "This community likely contains graphic or explicit content.",
                inList: false
            )
            
            Group {
                HStack(spacing: Constants.main.doubleSpacing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Go back").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button {
                        warningPresented = false
                    } label: {
                        Text("Continue").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Toggle(isOn: Binding(
                    get: { !showNsfwCommunityWarning },
                    set: { showNsfwCommunityWarning = !$0 }
                ), label: {
                    Text("Don't show this again")
                })
            }
            .padding(.horizontal, 30)
        }
        .padding(Constants.main.doubleSpacing)
        .background {
            RoundedRectangle(cornerRadius: Constants.main.largeItemCornerRadius)
                .fill(palette.background.opacity(0.8))
        }
        .padding(Constants.main.doubleSpacing)
    }
    
    func setupFeedLoader(community: any Community) {
        Task { @MainActor in
            @Setting(\.internetSpeed) var internetSpeed
            @Setting(\.showReadInFeed) var showReadInFeed
            
            postFeedLoader = try await .init(
                pageSize: internetSpeed.pageSize,
                sortType: appState.initialFeedSortType,
                showReadPosts: showReadInFeed,
                filteredKeywords: [],
                prefetchingConfiguration: .forPostSize(postSize),
                urlCache: Constants.main.urlCache,
                community: community
            )
        }
    }
}
