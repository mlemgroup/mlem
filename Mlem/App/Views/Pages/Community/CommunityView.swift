//
//  CommunityView.swift
//  Mlem
//
//  Created by Sjmarf on 30/07/2024.
//

import Dependencies
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
    @Environment(FiltersTracker.self) var filtersTracker
    @Environment(\.palette) var palette
    @Environment(\.dismiss) var dismiss
    
    @Setting(\.postSize) var postSize
    @Setting(\.showNsfwCommunityWarning) var showNsfwCommunityWarning
    @Setting(\.blurNsfw) var blurNsfw
    
    @ObservationIgnored @Dependency(\.persistenceRepository) private var persistenceRepository
    
    let visitContext: VisitHistory.VisitContext

    @State var community: AnyCommunity
    @State private var selectedTab: Tab = .posts
    @State var postFeedLoader: CommunityPostFeedLoader?
    @State var warningPresented: Bool
    
    @State var showingConfirmation: Bool = false
    @State var newMod: Person2?
    
    init(
        community: AnyCommunity,
        visitContext: VisitHistory.VisitContext
    ) {
        @Setting(\.showNsfwCommunityWarning) var showNsfwCommunityWarning
        self.community = community
        self.visitContext = visitContext
        self._warningPresented = .init(wrappedValue: showNsfwCommunityWarning && (community.wrappedValue.nsfw_ ?? false))
    }
    
    var body: some View {
        ContentLoader(model: community) { proxy in
            if let community = proxy.entity {
                content(community: community)
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
        .background(.themedGroupedBackground)
    }
        
    @ViewBuilder
    // swiftlint:disable:next function_body_length
    func content(community: any Community) -> some View {
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
                    if let postFeedLoader {
                        postsTab(community: community, postFeedLoader: postFeedLoader)
                            .padding(.bottom, -4)
                    }
                case .about:
                    aboutTab(community: community)
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
                MenuButtons { community.menuActions(appState: appState, navigation: navigation, feedLoader: postFeedLoader) }
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
    func postsTab(community: any Community, postFeedLoader: CommunityPostFeedLoader) -> some View {
        if community.removed {
            VStack(spacing: Constants.main.standardSpacing) {
                Image(systemName: Icons.remove)
                    .font(.title)
                Text("This community has been removed.")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.themedWarning)
            .padding(.top, Constants.main.doubleSpacing)
        } else {
            PostGridView(postFeedLoader: postFeedLoader)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        FeedSortPicker(feedLoader: postFeedLoader, showTopTimescaleInIcon: true)
                    }
                }
        }
    }

    @ViewBuilder
    func aboutTab(community: any Community) -> some View {
        VStack(spacing: Constants.main.standardSpacing) {
            if let banner = community.banner {
                MediaView.largeImage(url: banner, shouldBlur: false)
            }
            if let description = community.description {
                Markdown(description, configuration: .default(palette: palette))
                    .padding(Constants.main.standardSpacing)
                    .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
                    .paletteBorder(cornerRadius: Constants.main.standardSpacing)
            }
        }
        .padding([.horizontal, .bottom], Constants.main.standardSpacing)
    }
    
    @ViewBuilder
    func moderationTab(community: any Community) -> some View {
        VStack(spacing: Constants.main.standardSpacing) {
            ModlogButtonView(community: community)

            VStack(spacing: Constants.main.halfSpacing) {
                ForEach(community.moderators_ ?? []) { person in
                    PersonListRow(person)
                        .quickSwipes(moderatorQuickSwipes(community: community, person: person))
                }
            }
            
            if let firstPerson = appState.firstPerson,
               firstPerson.isAdmin || firstPerson.moderates(community: community) {
                Button("Add Moderator", systemImage: Icons.add, action: openAddModSheet)
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
            .background(subscribed ? .themedAccent : .themedSecondary.opacity(0.2), in: .capsule)
            .foregroundStyle(subscribed ? .themedContrastingLabel : .themedSecondary)
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
}

#if DEBUG
    #Preview(traits: .sampleEnvironment(api: .realistic)) {
        CommunityView(
            community: .init(Community2.mock(.realistic(.pics), api: .realistic)),
            visitContext: .other
        )
        .previewNavigationStack()
        .previewTabBar(selected: .feeds)
    }
#endif
