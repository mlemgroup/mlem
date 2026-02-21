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
    @Setting(\.safety_enableNsfwCommunityWarning) var showNsfwCommunityWarning
    @Setting(\.safety_blurNsfw) var blurNsfw
    
    @ObservationIgnored @Dependency(\.persistenceRepository) private var persistenceRepository
    
    let visitContext: VisitHistory.VisitContext

    @State var community: Community
    @State private var selectedTab: Tab = .posts
    @State var postFeedLoader: CommunityPostFeedLoader?
    @State var warningPresented: Bool
    // @State var isLoading: Bool = false
    
    @State var showingConfirmation: Bool = false
    @State var newMod: Person?
    
    init(
        community: Community,
        visitContext: VisitHistory.VisitContext
    ) {
        @Setting(\.safety_enableNsfwCommunityWarning) var showNsfwCommunityWarning
        self.community = community
        self.visitContext = visitContext
        self._warningPresented = .init(wrappedValue: showNsfwCommunityWarning && community.nsfw)
    }
    
    var body: some View {
        content(community: community)
            .externalApiWarning(entity: community, isLoading: false)
            .task {
                setupFeedLoader(community: community)
            }
            .onAppear {
                logVisit(community)
            }
            .navigationBarTitleDisplayMode(.inline)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .themedGroupedBackground()
    }
        
    @ViewBuilder
    // swiftlint:disable:next function_body_length
    func content(community: Community) -> some View {
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
            showPopup: selectedTab == .posts && community.api === appState.firstApi
        )
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
    func postsTab(community: Community, postFeedLoader: CommunityPostFeedLoader) -> some View {
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
            PostGridView(postFeedLoader: postFeedLoader)
        }
    }

    @ViewBuilder
    func moderationTab(community: Community) -> some View {
        VStack(spacing: Constants.main.standardSpacing) {
            if community.api.supports(.modlog, defaultValue: true) {
                ModlogButtonView(community: community)
            }

            ExpectedView(community.moderators) { moderators in
                ForEach(moderators) { person in
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
    func subscribeButton(community: Community) -> some View {
        if let subscription = community.subscription.value,
           let updateSubscribed = community.updateSubscribed {
            Button {
                if community.api.willSendToken {
                    hapticManager.play(haptic: .gentleInfo, tier: .low)
                    updateSubscribed(!subscription.subscribed)
                }
            } label: {
                HStack {
                    Text(subscription.total.abbreviated)
                    Image(icon: subscription.subscribed ? .general.success : .lemmy.personAvatar)
                        .symbolVariant(.circle)
                        .symbolVariant(subscription.subscribed ? .fill : .none)
                        .symbolRenderingMode(.hierarchical)
                }
                .fontWeight(.semibold)
                .padding(.vertical, 3)
                .padding(.trailing, 6)
                .padding(.leading, 8)
                .background(subscription.subscribed ? .themedAccent : .themedSecondary.opacity(0.2), in: .capsule)
                .foregroundStyle(subscription.subscribed ? .themedContrastingLabel : .themedSecondary)
            }
            .padding(.trailing, Constants.main.standardSpacing)
            .padding(.bottom, Constants.main.halfSpacing)
        }
    }
    
    func tabs(community: Community) -> [Tab] {
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
