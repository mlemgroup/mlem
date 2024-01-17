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
    
    let internetSpeed: InternetSpeed
    let communityContext: CommunityModel?
    
    @State var user: UserModel
    @State var selectedTab: UserViewTab = .overview
    @State var isLoadingContent: Bool = true
    
    @StateObject var privatePostTracker: PostTracker
    @StateObject var privateCommentTracker: CommentTracker = .init()
    
    @StateObject var communityTracker: ContentTracker<CommunityModel> = .init()
    
    @State private var isPresentingConfirmDestructive: Bool = false
    @State private var confirmationMenuFunction: StandardMenuFunction?
    
    @Namespace var scrollToTop
    @State private var scrollToTopAppeared = false
    
    func confirmDestructive(destructiveFunction: StandardMenuFunction) {
        confirmationMenuFunction = destructiveFunction
        isPresentingConfirmDestructive = true
    }
    
    init(user: UserModel, communityContext: CommunityModel? = nil) {
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        
        self.internetSpeed = internetSpeed
        
        self._privatePostTracker = StateObject(wrappedValue: .init(
            shouldPerformMergeSorting: false,
            internetSpeed: internetSpeed,
            upvoteOnSave: upvoteOnSave
        ))
        
        self._user = State(wrappedValue: user)
        self.communityContext = communityContext
    }
    
    var body: some View {
        ScrollView {
            ScrollToView(appeared: $scrollToTopAppeared)
                .id(scrollToTop)
            VStack(spacing: AppConstants.postAndCommentSpacing) {
                AvatarBannerView(user: user)
                    .padding(.horizontal, AppConstants.postAndCommentSpacing)
                    .padding(.top, 10)
                Button(action: user.copyFullyQualifiedUsername) {
                    VStack(spacing: 5) {
                        Text(user.displayName)
                            .font(.title.bold())
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                        Text(user.fullyQualifiedUsername ?? user.name)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, AppConstants.postAndCommentSpacing)
                .buttonStyle(.plain)
                
                flairs
                
                VStack(spacing: 0) {
                    let bioAlignment = bioAlignment
                    if let bio = user.bio {
                        Divider()
                            .padding(.bottom, AppConstants.postAndCommentSpacing)
                        MarkdownView(text: bio, isNsfw: false, alignment: bioAlignment).padding(AppConstants.postAndCommentSpacing)
                    }
                    HStack {
                        Label(cakeDayFormatter.string(from: user.creationDate), systemImage: Icons.cakeDay)
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
                    
                    Divider()
                        .padding(.top, AppConstants.postAndCommentSpacing * 2)
                    
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
                .animation(.easeOut(duration: 0.2), value: isLoadingContent)
            }
        }
        .environmentObject(privatePostTracker)
        .environmentObject(privateCommentTracker)
        .destructiveConfirmation(
            isPresentingConfirmDestructive: $isPresentingConfirmDestructive,
            confirmationMenuFunction: confirmationMenuFunction
        )
        .toolbar {
            ToolbarItemGroup(placement: .secondaryAction) {
                let functions = user.menuFunctions { user = $0 }
                ForEach(functions) { item in
                    MenuButton(menuFunction: item, confirmDestructive: confirmDestructive)
                }
            }
        }
        .task(priority: .userInitiated) {
            if isLoadingContent {
                Task {
                    await tryReloadUser()
                }
            }
        }
        .onChange(of: user.userId) { _ in
            Task {
                await tryReloadUser()
            }
        }
        .refreshable {
            Task {
                await tryReloadUser()
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
    
    var flairs: some View {
        Group {
            let flairs = user.getFlairs(communityContext: communityContext)
            if !flairs.isEmpty {
                VStack(spacing: AppConstants.postAndCommentSpacing) {
                    ForEach(flairs, id: \.self) { flair in
                        switch flair {
                        case .developer:
                            flairBackground(color: flair.color) {
                                HStack {
                                    Image(systemName: Icons.developerFlair)
                                    Text("Mlem Developer")
                                }
                            }
                        case .banned:
                            flairBackground(color: flair.color) {
                                HStack {
                                    Image(systemName: Icons.bannedFlair)
                                    if let expirationDate = user.banExpirationDate {
                                        Text("Banned Until \(cakeDayFormatter.string(from: expirationDate))")
                                    } else {
                                        Text("Permanently Banned")
                                    }
                                }
                            }
                        case .bot:
                            flairBackground(color: flair.color) {
                                HStack {
                                    Image(systemName: Icons.botFlair)
                                    Text("Bot Account")
                                }
                            }
                        case .admin:
                            flairBackground(color: flair.color) {
                                HStack {
                                    Image(systemName: Icons.adminFlair)
                                    let host = try? apiClient.session.instanceUrl.host()
                                    Text("\(host ?? "Instance") Administrator")
                                }
                            }
                        case .moderator:
                            flairBackground(color: flair.color) {
                                HStack {
                                    Image(systemName: Icons.moderationFill)
                                    Text("\(communityContext?.displayName ?? "Community") Moderator")
                                }
                            }
                        default:
                            EmptyView()
                        }
                    }
                }
                .padding(.bottom, AppConstants.postAndCommentSpacing)
            }
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
