//
//  CommunityFeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-19.
//

import Dependencies
import Foundation
import SwiftUI

/// View for a single community
struct CommunityFeedView: View {
    enum Tab: String, Identifiable, CaseIterable {
        var id: Self { self }
        case posts, about, moderators, details
    }
    
    @AppStorage("shouldShowCommunityHeaders") var shouldShowCommunityHeaders: Bool = true
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.notifier) var notifier
    
    @Environment(AppState.self) var appState
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.scrollViewProxy) var scrollProxy
    @Environment(\.navigationPathWithRoutes) private var navigationPath
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var postTracker: StandardPostTracker?
    
    @State var postSortType: PostSortType
    @State var selectedTab: Tab = .posts
    
    @State var community: any CommunityStubProviding
    
    // destructive confirmation
    @State private var isPresentingConfirmDestructive: Bool = false
    @State private var confirmationMenuFunction: StandardMenuFunction?
    
    func confirmDestructive(destructiveFunction: StandardMenuFunction) {
        confirmationMenuFunction = destructiveFunction
        isPresentingConfirmDestructive = true
    }
    
    // scroll to top
    @Namespace var scrollToTop
    @State private var scrollToTopAppeared = false
    private var scrollToTopId: Int? {
        postTracker?.items.first?.id
    }
    
    var availableTabs: [Tab] {
        var output: [Tab] = [.posts, .moderators, .details]
        if (community as? any Community1Providing)?.description != nil {
            output.insert(.about, at: 1)
        }
        return output
    }
    
    init(community: any CommunityStubProviding) {
        // need to grab some stuff from app storage to initialize post tracker with
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        @AppStorage("showReadPosts") var showReadPosts = true
        @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
        
        self._community = .init(wrappedValue: community)
        self._postSortType = .init(wrappedValue: defaultPostSorting)
        
        if let community = community as? any Community {
            self._postTracker = .init(wrappedValue: .init(
                internetSpeed: internetSpeed,
                sortType: defaultPostSorting,
                showReadPosts: showReadPosts,
                feedType: .community(community)
            ))
        } else {
            self._postTracker = .init(wrappedValue: nil)
        }
    }
    
    var body: some View {
        content
            .onAppear {
                if !(community is any Community3Providing) {
                    Task(priority: .userInitiated) {
                        do {
                            print("START COMM")
                            community = try await community.upgrade()
                            print("END COMM")
                        } catch {
                            errorHandler.handle(error)
                        }
                    }
                }
            }
            .refreshable {
                await Task {
                    do {
                        _ = try await postTracker?.refresh(clearBeforeRefresh: false)
                    } catch {
                        errorHandler.handle(error)
                    }
                }.value
            }
            .destructiveConfirmation(
                isPresentingConfirmDestructive: $isPresentingConfirmDestructive,
                confirmationMenuFunction: confirmationMenuFunction
            )
            .fancyTabScrollCompatible()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(community.name)
                        .font(.headline)
                        .opacity(scrollToTopAppeared ? 0 : 1)
                        .animation(.easeOut(duration: 0.2), value: scrollToTopAppeared)
                }
//                ToolbarItemGroup(placement: .secondaryAction) {
//                    ForEach(
//                        communityModel.menuFunctions(
//                            editorTracker: editorTracker,
//                            postTracker: postTracker
//                        ) { communityModel = $0 }
//                    ) { menuFunction in
//                        MenuButton(menuFunction: menuFunction, confirmDestructive: confirmDestructive)
//                    }
//                    .destructiveConfirmation(
//                        isPresentingConfirmDestructive: $isPresentingConfirmDestructive,
//                        confirmationMenuFunction: confirmationMenuFunction
//                    )
//                }
            }
            .hoistNavigation {
                if let scrollProxy {
                    withAnimation {
                        scrollProxy.scrollTo(scrollToTop)
                    }
                }
                return !scrollToTopAppeared
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarColor(visibility: .automatic)
    }
    
    @ViewBuilder
    var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                ScrollToView(appeared: $scrollToTopAppeared)
                    .id(scrollToTop)
                headerView
                    .padding(.top, 5)
                    .background(Color.systemBackground)
                
                switch selectedTab {
                case .posts: posts
                case .about: about
                case .moderators: moderators
                case .details: details
                }
            }
        }
    }
    
    @ViewBuilder
    var posts: some View {
        if let postTracker, let community = community as? any Community1Providing {
            PostFeedView(appState: appState, postSortType: $postSortType, showCommunity: false, communityContext: community)
                .environment(postTracker)
        }
    }
    
    @ViewBuilder
    var about: some View {
        if let community = community as? any Community1Providing {
            VStack(spacing: AppConstants.postAndCommentSpacing) {
                if shouldShowCommunityHeaders, let banner = community.banner {
                    CachedImage(url: banner, cornerRadius: AppConstants.largeItemCornerRadius)
                }
                if let description = community.description {
                    MarkdownView(text: description, isNsfw: false)
                }
            }
            .padding(AppConstants.postAndCommentSpacing)
        }
    }
    
    @ViewBuilder
    var moderators: some View {
        if let moderators = community.moderators_ {
            ForEach(moderators, id: \.id) { user in
                UserResultView(user, communityContext: community)
                Divider()
            }
        }
    }
    
    @ViewBuilder
    var details: some View {
        if let community = community as? any Community2Providing {
            VStack(spacing: 0) {
                CommunityDetailsView(community: community)
                    .padding(.vertical, 16)
                    .background(Color(uiColor: .systemGroupedBackground))
                
                if colorScheme == .light {
                    Divider()
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
    
    // MARK: Header
    
    @ViewBuilder
    var headerView: some View {
        Group {
            VStack(spacing: 5) {
                HStack(alignment: .center, spacing: 10) {
                    if shouldShowCommunityIcons {
                        AvatarView(community: community, avatarSize: 44, iconResolution: .unrestricted)
                    }
                    Button {
                        community.copyFullNameWithPrefix(notifier: notifier)
                    } label: {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(community.displayName_ ?? community.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                            if let fullName = community.fullName {
                                Text(fullName)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .frame(height: 44)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    subscribeButton
                }
                .padding(.horizontal, AppConstants.postAndCommentSpacing)
                .padding(.bottom, 3)
                Divider()
                BubblePicker(availableTabs, selected: $selectedTab) {
                    Text($0.rawValue.capitalized)
                }
            }
            Divider()
        }
    }
    
    @ViewBuilder
    var subscribeButton: some View {
        if let subscriptionTier = community.subscriptionTier_ {
            HStack(spacing: 4) {
                if let subscriberCount = community.subscriberCount_ {
                    Text(abbreviateNumber(subscriberCount))
                }
                Image(systemName: subscriptionTier.systemImage)
                    .aspectRatio(contentMode: .fit)
            }
            .foregroundStyle(subscriptionTier.foregroundColor)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(
                Capsule()
                    .strokeBorder(subscriptionTier.foregroundColor, style: .init(lineWidth: 1))
                    .background(Capsule().fill(subscriptionTier.backgroundColor.opacity(0.1)))
            )
            .gesture(TapGesture().onEnded { _ in
                hapticManager.play(haptic: .lightSuccess, priority: .low)
                print("tapped subscribe")
//                Task {
//                    do {
//                        if communityModel.favorited {
//                            print("favorited")
//                            confirmDestructive(destructiveFunction: communityModel.favoriteMenuFunction { communityModel = $0 })
//                        } else if subscribed {
//                            print("subscribed")
//                            try confirmDestructive(destructiveFunction: communityModel.subscribeMenuFunction { communityModel = $0 })
//                        } else {
//                            print("not subscribed")
//                            try await communityModel.toggleSubscribe { item in
//                                DispatchQueue.main.async { communityModel = item }
//                            }
//                        }
//                    } catch {
//                        errorHandler.handle(error)
//                    }
//                }
            })
//            .simultaneousGesture(LongPressGesture().onEnded { _ in
//                hapticManager.play(haptic: .lightSuccess, priority: .low)
//                Task {
//                    do {
//                        // TODO: this doesn't update view state when favoriting, but it does when unfavoriting
//                        try await communityModel.toggleFavorite { item in
//                            DispatchQueue.main.async { communityModel = item }
//                        }
//                    } catch {
//                        errorHandler.handle(error)
//                    }
//                }
//            })
        }
    }
}
