//
//  CommunityView.swift
//  Mlem
//
//  Created by Sjmarf on 30/07/2024.
//

import Actions
import Dependencies
import Haptics
import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI
import Theming

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
    @Environment(FiltersTracker.self) var filtersTracker
    @Environment(HapticManager.self) var hapticManager
    @Environment(\.palette) var palette
    @Environment(\.dismiss) var dismiss
    
    @Setting(\.post_size) var postSize
    @Setting(\.feed_showRead) var showRead
    @Setting(\.safety_enableNsfwCommunityWarning) var showNsfwCommunityWarning
    @Setting(\.safety_blurNsfw) var blurNsfw
    
    @ObservationIgnored @Dependency(\.persistenceRepository) private var persistenceRepository
    
    let visitContext: VisitHistory.VisitContext

    @State var community: AnyCommunity
    @State private var selectedTab: Tab = .posts
    @State var postFeedLoader: CommunityPostFeedLoader?
    @State var warningPresented: Bool
    
    @State var showingConfirmation: Bool = false
    @State var newMod: Person?
    @State var showHiddenReadBanner: Bool = false
    @State var lastRefreshDate: Date?
    
    init(
        community: AnyCommunity,
        visitContext: VisitHistory.VisitContext
    ) {
        @Setting(\.safety_enableNsfwCommunityWarning) var showNsfwCommunityWarning
        self.community = community
        self.visitContext = visitContext
        self._warningPresented = .init(wrappedValue: showNsfwCommunityWarning && (community.wrappedValue.nsfw_ ?? false))
    }
    
    var body: some View {
        ContentLoader(model: community) { proxy in
            if let community = proxy.entity {
                content(community: community, contentLoaderError: proxy.error)
                    .externalApiWarning(entity: community, isLoading: proxy.isLoading)
                    .onChange(of: (community as? any Community2Providing)?.community2 == nil, initial: true) {
                        if let community2 = (community as? any Community2Providing)?.community2 {
                            logVisit(community2)
                        }
                    }
            } else if let error = proxy.error {
                ErrorView(.init(error: error))
            } else {
                ProgressView()
                    .tint(.themedSecondary)
            }
        } upgradeOperation: { model, api in
            try await model.upgrade(api: api, upgradeOperation: nil)
            if let community = model.wrappedValue as? any Community {
                setupFeedLoader(community: community)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .themedGroupedBackground()
    }
        
    @ViewBuilder
    // swiftlint:disable:next function_body_length
    func content(community: any Community, contentLoaderError: (any Error)?) -> some View {
        FancyScrollView {
            HStack {
                FeedHeaderView(
                    title: Text(community.displayName),
                    subtitle: Text(community.fullNameWithPrefix),
                    dropdownStyle: .disabled,
                    image: {
                        CircleCroppedImageView(
                            community,
                            frame: Constants.main.feedHeaderSize,
                            blurred: community.nsfw && (blurNsfw == .always)
                        )
                    }
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
                    VStack {
                        if let postFeedLoader {
                            postsTab(community: community, postFeedLoader: postFeedLoader)
                                .padding(.bottom, -4)
                        } else if let error = contentLoaderError {
                            ErrorView(.init(error: error))
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            FeedSortPicker(feedLoader: postFeedLoader, showTopTimescaleInIcon: true)
                        }
                    }
                case .about:
                    CommunityAboutView(community: community)
                case .moderation:
                    moderationTab(community: community)
                case .details:
                    CommunityDetailsView(community: community)
                default:
                    EmptyView()
                }
            }
            .environment(\.communityContext, community)
        }
        .animation(.snappy, value: showHiddenReadBanner && !showRead)
        .conditionalNavigationTitle(community.name)
        .toolbar {
            ToolbarItemGroup(placement: .secondaryAction) {
                ActionButtons(community: community)
                    .environment(postFeedLoader)
            }
        }
        // don't show the refresh popup if community api isn't the active api, since that indicates an unresolvable community
        .popupAnchor()
        .outdatedFeedPopup(
            feedLoader: postFeedLoader,
            showPopup: selectedTab == .posts && community.api === appState.firstApi,
            onManualRefresh: {
                guard !showRead else { return }
                let now = Date()
                if let lastRefresh = lastRefreshDate,
                   now.timeIntervalSince(lastRefresh) < 5 {
                    showHiddenReadBanner = true
                }
                lastRefreshDate = now
            }
        )
        .onChange(of: showRead) {
            if showRead {
                showHiddenReadBanner = false
            }
            lastRefreshDate = nil
        }
        .fullScreenCover(isPresented: $warningPresented) {
            WarningOverlayView(
                text: "This community likely contains graphic or explicit content.",
                isPresented: $warningPresented,
                showWarningAgain: $showNsfwCommunityWarning
            )
        }
        .environment(\.feedContext, .community)
    }
    
    @ViewBuilder
    func postsTab(community: any Community, postFeedLoader: CommunityPostFeedLoader) -> some View {
        if community.removed {
            VStack(spacing: Constants.main.standardSpacing) {
                Image(icon: .lemmy.remove)
                    .font(.title)
                Text("This community has been removed.")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.themedWarning)
            .padding(.top, Constants.main.doubleSpacing)
        } else {
            if showHiddenReadBanner, !showRead {
                HiddenReadBannerView {
                    showHiddenReadBanner = false
                }
                .padding([.horizontal, .bottom], Constants.main.standardSpacing)
            }
            PostGridView(postFeedLoader: postFeedLoader)
        }
    }

    @ViewBuilder
    func moderationTab(community: any Community) -> some View {
        VStack(spacing: Constants.main.standardSpacing) {
            if community.api.supports(.modlog, defaultValue: true) {
                ModlogButtonView(community: community)
            }

            VStack(spacing: Constants.main.halfSpacing) {
                ForEach(community.moderators_ ?? []) { person in
                    PersonListRow(person)
                        .quickSwipes(moderatorQuickSwipes(community: community, person: person))
                }
            }
            
            if canEditModeratorList(community) {
                Button("Add Moderator", icon: .general.add, action: openAddModSheet)
                    .buttonStyle(.capsule)
                    .confirmationDialog("Add Moderator", isPresented: $showingConfirmation) {
                        Button("Yes", action: addNewMod)
                    } message: {
                        if let displayName = newMod?.displayName {
                            Text("Really appoint \(displayName) as a moderator of \(community.displayName)?")
                        } else {
                            Text("Really appoint this user as a moderator of \(community.displayName)?")
                        }
                    }
            }
        }
        .padding([.horizontal, .bottom], Constants.main.standardSpacing)
    }
    
    @ViewBuilder
    func subscribeButton(community: any Community) -> some View {
        let subscribed = community.subscribed_ ?? false
        Button {
            if let community = community as? any Community2Providing, community.api.willSendToken {
                hapticManager.play(haptic: .gentleInfo, tier: .low)
                community.toggleSubscribe()
            }
        } label: {
            HStack {
                Text((community.subscriberCount_ ?? 0).abbreviated)
                Image(icon: subscribed ? .general.success : .lemmy.personAvatar)
                    .symbolVariant(.circle)
                    .symbolVariant(subscribed ? .fill : .none)
                    .symbolRenderingMode(.hierarchical)
            }
            .fontWeight(.semibold)
            .padding(.vertical, 3)
            .padding(.trailing, 6)
            .padding(.leading, 8)
            .background(subscribed ? .themedAccent : .themedSecondary.opacity(0.2), in: .capsule)
            .foregroundStyle(subscribed ? .themedContrastingLabel : .themedSecondary)
        }
        .padding(.trailing, Constants.main.standardSpacing)
        .padding(.bottom, Constants.main.halfSpacing)
    }
    
    func tabs(community: any Community) -> [Tab] {
        var output: [Tab] = [.posts, .moderation, .details]
        let canModerate: Bool
        if !appState.firstApi.supports(.editCommunityDescription, defaultValue: false) {
            canModerate = false
        } else if let firstPerson = appState.firstPerson {
            canModerate = (firstPerson.moderates?(.community(community)) ?? false) || (firstPerson.isAdmin.value ?? false)
        } else {
            canModerate = false
        }
        if community.description != nil || community.banner != nil || canModerate {
            output.insert(.about, at: 1)
        }
        return output
    }
}

// TODO: updated mocks
// #if DEBUG
//    #Preview(traits: .sampleEnvironment(api: .realistic)) {
//        CommunityView(
//            community: .init(Community2.mock(.realistic(.pics), api: .realistic)),
//            visitContext: .other
//        )
//        .previewNavigationStack()
//        .previewTabBar(selected: .feeds)
//    }
// #endif
