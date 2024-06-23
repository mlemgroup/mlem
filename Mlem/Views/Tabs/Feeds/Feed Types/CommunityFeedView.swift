//
//  CommunityFeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-19.
//

import Dependencies
import Foundation
import SwiftUI

// swiftlint:disable type_body_length

/// View for a single community
struct CommunityFeedView: View {
    enum Tab: String, Identifiable, CaseIterable {
        var id: Self { self }
        case posts, about, moderation, details
    }
    
    @AppStorage("shouldShowCommunityHeaders") var shouldShowCommunityHeaders: Bool = true
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.communityRepository) var communityRepository
    @Dependency(\.siteInformation) var siteInformation
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.scrollViewProxy) var scrollProxy
    @Environment(\.navigationPathWithRoutes) private var navigationPath
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var modToolTracker: ModToolTracker
    
    @StateObject var postTracker: StandardPostTracker
    
    @State var postSortType: PostSortType
    @State var selectedTab: Tab = .posts
    
    @State var communityModel: CommunityModel
    
    @State private var menuFunctionPopup: MenuFunctionPopup?
    
    // scroll to top
    @Namespace var scrollToTop
    @State private var scrollToTopAppeared = false
    private var scrollToTopId: Int? {
        postTracker.items.first?.id
    }
    
    var availableTabs: [Tab] {
        var output: [Tab] = [.posts, .moderation, .details]
        if communityModel.description != nil {
            output.insert(.about, at: 1)
        }
        return output
    }
    
    init(communityModel: CommunityModel) {
        // need to grab some stuff from app storage to initialize post tracker with
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        @AppStorage("showReadPosts") var showReadPosts = true
        @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
        
        self._communityModel = .init(wrappedValue: communityModel)
        self._postSortType = .init(wrappedValue: defaultPostSorting)
        self._postTracker = .init(wrappedValue: .init(
            internetSpeed: internetSpeed,
            sortType: defaultPostSorting,
            showReadPosts: showReadPosts,
            feedType: .community(communityModel)
        ))
    }
    
    var body: some View {
        content
            .refreshable {
                await Task {
                    do {
                        communityModel = try await communityRepository.loadDetails(for: communityModel.communityId)
                        _ = try await postTracker.refresh(clearBeforeRefresh: false)
                    } catch {
                        errorHandler.handle(error)
                    }
                }.value
            }
            .destructiveConfirmation(menuFunctionPopup: $menuFunctionPopup)
            .fancyTabScrollCompatible()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(communityModel.name)
                        .font(.headline)
                        .opacity(scrollToTopAppeared ? 0 : 1)
                        .animation(.easeOut(duration: 0.2), value: scrollToTopAppeared)
                }
                
                ToolbarItemGroup(placement: .primaryAction) {
                    ToolbarEllipsisMenu {
                        ForEach(
                            communityModel.menuFunctions(
                                editorTracker: editorTracker,
                                postTracker: postTracker,
                                modToolTracker: modToolTracker
                            ) { communityModel = $0 }
                        ) { item in
                            MenuButton(menuFunction: item, menuFunctionPopup: $menuFunctionPopup)
                        }
                        Divider()
                        FeedToolbarContent()
                    }
                }
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
                case .posts: posts()
                case .about: about()
                case .moderation: ModeratorListView(community: $communityModel)
                case .details: details()
                }
            }
        }
    }
    
    func posts() -> some View {
        PostFeedView(postSortType: $postSortType, showCommunity: false, communityContext: communityModel)
            .environmentObject(postTracker)
    }
    
    func about() -> some View {
        VStack(spacing: AppConstants.standardSpacing) {
            if shouldShowCommunityHeaders, let banner = communityModel.banner {
                CachedImage(url: banner, cornerRadius: AppConstants.largeItemCornerRadius)
            }
            MarkdownView(text: communityModel.description ?? "", isNsfw: false)
        }
        .padding(AppConstants.standardSpacing)
    }
    
    func details() -> some View {
        VStack(spacing: 0) {
            CommunityDetailsView(community: communityModel)
                .padding(.vertical, 16)
                .background(Color(uiColor: .systemGroupedBackground))
            
            if colorScheme == .light {
                Divider()
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    // MARK: Header
    
    @ViewBuilder
    var headerView: some View {
        Group {
            VStack(spacing: AppConstants.standardSpacing) {
                HStack(alignment: .center, spacing: AppConstants.standardSpacing) {
                    if shouldShowCommunityIcons {
                        AvatarView(community: communityModel, avatarSize: 44, iconResolution: .unrestricted)
                    }
                    Button(action: communityModel.copyFullyQualifiedName) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(communityModel.displayName)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                            if let fullyQualifiedName = communityModel.fullyQualifiedName {
                                Text(fullyQualifiedName)
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
                .padding(.horizontal, AppConstants.standardSpacing)
                
                BubblePicker(
                    availableTabs,
                    selected: $selectedTab,
                    withDividers: [.top, .bottom],
                    label: \.rawValue.capitalized
                )
            }
        }
    }
    
    var subscribeButtonForegroundColor: Color {
        if communityModel.favorited {
            return .blue
        } else if communityModel.subscribed ?? false {
            return .green
        }
        return .secondary
    }
    
    var subscribeButtonBackgroundColor: Color {
        if communityModel.favorited {
            return .blue.opacity(0.1)
        } else if communityModel.subscribed ?? false {
            return .green.opacity(0.1)
        }
        return .clear
    }
    
    var subscribeButtonIcon: String {
        if communityModel.favorited {
            return Icons.favoriteFill
        } else if communityModel.subscribed ?? false {
            return Icons.successCircle
        }
        return Icons.personFill
    }
    
    @ViewBuilder
    var subscribeButton: some View {
        if let subscribed = communityModel.subscribed {
            capsuleButton(
                text: communityModel.subscriberCount?.abbreviated,
                imageName: subscribeButtonIcon,
                foregroundColor: subscribeButtonForegroundColor,
                backgroundColor: subscribeButtonBackgroundColor
            )
            .gesture(TapGesture().onEnded { _ in
                hapticManager.play(haptic: .lightSuccess, priority: .low)
                print("tapped subscribe")
                Task {
                    do {
                        if communityModel.favorited {
                            menuFunctionPopup = .init(
                                prompt: "Are you sure you want to unfavorite \(communityModel.name!)?",
                                actions: [.init(text: "Yes", callback: {
                                    Task {
                                        do {
                                            try await communityModel.toggleFavorite { item in
                                                DispatchQueue.main.async { communityModel = item }
                                            }
                                        } catch {
                                            errorHandler.handle(error)
                                        }
                                    }
                                })]
                            )

                        } else if subscribed {
                            menuFunctionPopup = .init(
                                prompt: "Are you sure you want to unsubscribe from \(communityModel.name!)?",
                                actions: [.init(text: "Yes", callback: {
                                    Task {
                                        do {
                                            try await communityModel.toggleSubscribe { item in
                                                DispatchQueue.main.async { communityModel = item }
                                            }
                                        } catch {
                                            errorHandler.handle(error)
                                        }
                                    }
                                })]
                            )
                        } else {
                            print("not subscribed")
                            try await communityModel.toggleSubscribe { item in
                                DispatchQueue.main.async { communityModel = item }
                            }
                        }
                    } catch {
                        errorHandler.handle(error)
                    }
                }
            })
            .simultaneousGesture(LongPressGesture().onEnded { _ in
                hapticManager.play(haptic: .lightSuccess, priority: .low)
                Task {
                    do {
                        // TODO: this doesn't update view state when favoriting, but it does when unfavoriting
                        try await communityModel.toggleFavorite { item in
                            DispatchQueue.main.async { communityModel = item }
                        }
                    } catch {
                        errorHandler.handle(error)
                    }
                }
            })
        }
    }
    
    func capsuleButton(text: String?, imageName: String, foregroundColor: Color, backgroundColor: Color) -> some View {
        HStack(spacing: 4) {
            if let text {
                Text(text)
            }
            
            Image(systemName: imageName)
        }
        .foregroundStyle(foregroundColor)
        .padding(.vertical, AppConstants.halfSpacing)
        .padding(.horizontal, AppConstants.standardSpacing)
        .background {
            Capsule()
                .strokeBorder(foregroundColor, style: .init(lineWidth: 1))
                .background {
                    Capsule().fill(backgroundColor)
                }
        }
    }
}

// swiftlint:enable type_body_length
