//
//  NewUserView.swift
//  Mlem
//
//  Created by Sjmarf on 27/12/2023.
//

import Dependencies
import SwiftUI

struct UserView: View {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.notifier) var notifier
    @Dependency(\.personRepository) var personRepository
    @Dependency(\.siteInformation) var siteInformation
    
    @Environment(\.navigationPathWithRoutes) private var navigationPath
    @Environment(\.scrollViewProxy) private var scrollViewProxy
    
    @EnvironmentObject var modToolTracker: ModToolTracker
    
    let internetSpeed: InternetSpeed
    let communityContext: CommunityModel?
    
    @State var user: UserModel
    @State var selectedTab: UserViewTab = .overview
    @State var isLoadingContent: Bool = true
    
    @State var isPresentingAccountSwitcher: Bool = false
    
    @StateObject var privatePostTracker: StandardPostTracker
    @StateObject var privateCommentTracker: CommentTracker = .init()
    
    @StateObject var communityTracker: ContentTracker<CommunityModel> = .init()
    
    @State private var menuFunctionPopup: MenuFunctionPopup?
    
    @Namespace var scrollToTop
    @State private var scrollToTopAppeared = false
    
    init(user: UserModel, communityContext: CommunityModel? = nil) {
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        
        self.internetSpeed = internetSpeed
        
        self._privatePostTracker = .init(wrappedValue: .init(
            internetSpeed: internetSpeed,
            sortType: .new,
            showReadPosts: true,
            feedType: .all
        ))
        
        self._user = State(wrappedValue: user)
        self.communityContext = communityContext
    }
    
    var body: some View {
        content
            .environmentObject(privatePostTracker)
            .environmentObject(privateCommentTracker)
            .task(priority: .userInitiated) {
                if isLoadingContent {
                    Task {
                        await tryReloadUser()
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .secondaryAction) {
                    let functions = user.menuFunctions({ user = $0 }, modToolTracker: modToolTracker)
                    ForEach(functions) { item in
                        MenuButton(menuFunction: item, menuFunctionPopup: $menuFunctionPopup)
                    }
                }
            }
            .onChange(of: siteInformation.myUserInfo?.localUserView.person) { newValue in
                if isOwnProfile {
                    if let newValue {
                        user.update(with: newValue)
                    }
                }
            }
            .hoistNavigation {
                if navigationPath.isEmpty {
                    withAnimation {
                        scrollViewProxy?.scrollTo(scrollToTop)
                    }
                    return true
                } else {
                    if scrollToTopAppeared {
                        return false
                    } else {
                        withAnimation {
                            scrollViewProxy?.scrollTo(scrollToTop)
                        }
                        return true
                    }
                }
            }
            .fancyTabScrollCompatible()
            .navigationBarColor()
            .navigationTitle(user.displayName)
            .navigationBarTitleDisplayMode(.inline)
    }
    
    var content: some View {
        ScrollView {
            ScrollToView(appeared: $scrollToTopAppeared)
                .id(scrollToTop)
            
            VStack(spacing: AppConstants.postAndCommentSpacing) {
                header
                
                flairs
                
                VStack(spacing: 0) {
                    bio
                    
                    Divider()
                        .padding(.top, AppConstants.postAndCommentSpacing * 2)
                    
                    userContent
                }
                .animation(.easeOut(duration: 0.2), value: isLoadingContent)
            }
        }
    }
    
    @ViewBuilder
    var header: some View {
        AvatarBannerView(user: user)
            .padding(.horizontal, AppConstants.postAndCommentSpacing)
            .padding(.top, 10)
        Button(action: user.copyFullyQualifiedUsername) {
            VStack(spacing: 5) {
                Text(user.displayName)
                    .font(.title)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.01)
                Text(user.fullyQualifiedUsername ?? user.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, AppConstants.postAndCommentSpacing)
        .buttonStyle(.plain)
    }
    
    var flairs: some View {
        Group {
            let flairs = user.getFlairs(communityContext: communityContext)
            if !flairs.isEmpty {
                VStack(spacing: AppConstants.postAndCommentSpacing) {
                    ForEach(flairs, id: \.self) { flair in
                        flairBackground(color: flair.color) {
                            HStack {
                                switch flair {
                                case .bannedFromInstance:
                                    Image(systemName: Icons.instanceBannedFlair)
                                    if let expirationDate = user.banExpirationDate {
                                        Text("Banned Until \(expirationDate.dateString)")
                                    } else {
                                        Text("Permanently Banned")
                                    }
                                case .admin:
                                    Image(systemName: Icons.adminFlair)
                                    let host = user.profileUrl.host()
                                    Text("\(host ?? "Instance") Administrator")
                                case .moderator:
                                    Image(systemName: Icons.moderationFill)
                                    Text("\(communityContext?.displayName ?? "Community") Moderator")
                                default:
                                    Image(systemName: flair.icon)
                                    Text(flair.label)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, AppConstants.postAndCommentSpacing)
            }
        }
    }
    
    @ViewBuilder
    var bio: some View {
        let bioAlignment = bioAlignment
        if let userBio = user.bio {
            Divider()
                .padding(.bottom, AppConstants.postAndCommentSpacing)
            MarkdownView(text: userBio, isNsfw: false, alignment: bioAlignment).padding(AppConstants.postAndCommentSpacing)
        }
        HStack {
            Label(user.creationDate.dateString, systemImage: Icons.cakeDay)
            Text("•")
            Label(user.creationDate.getRelativeTime(date: Date.now, unitsStyle: .abbreviated), systemImage: Icons.time)
            if bioAlignment == .leading {
                Spacer()
            }
        }
        .foregroundStyle(.secondary)
        .font(.footnote)
        .padding(.horizontal, AppConstants.postAndCommentSpacing)
        .padding(.top, 2)
    }
    
    @ViewBuilder
    var userContent: some View {
        if isLoadingContent {
            VStack(spacing: 0) {
                LoadingView(whatIsLoading: .content)
            }
            .transition(.opacity)
        } else {
            VStack(spacing: 0) {
                BubblePicker(tabs, selected: $selectedTab) { tab in
                    switch tab {
                    case .posts:
                        Text("Posts (\(abbreviateNumber(user.postCount ?? 0)))")
                    case .comments:
                        Text("Comments (\(abbreviateNumber(user.commentCount ?? 0)))")
                    case .communities:
                        Text("Communities (\(abbreviateNumber(user.moderatedCommunities?.count ?? 0)))")
                    default:
                        Text(tab.label)
                    }
                }
                .padding(.vertical, 4)
                Divider()
                UserFeedView(
                    user: user,
                    privatePostTracker: privatePostTracker,
                    privateCommentTracker: privateCommentTracker,
                    communityTracker: communityTracker,
                    selectedTab: $selectedTab
                )
            }
            .transition(.opacity)
        }
    }
    
    @ViewBuilder
    func flairBackground(color: Color, @ViewBuilder content: () -> some View) -> some View {
        content()
            .foregroundStyle(color)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius).fill(color.opacity(0.2))
            )
            .padding(.horizontal, AppConstants.postAndCommentSpacing)
    }
}
