//
//  User View.swift
//  Mlem
//
//  Created by David Bureš on 02.04.2022.
//

// swiftlint:disable file_length

import Dependencies
import SwiftUI

// swiftlint:disable file_length

/// View for showing user profiles
/// Accepts the following parameters:
/// - **userID**: Non-optional ID of the user
struct UserView: View {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.notifier) var notifier
    @Dependency(\.personRepository) var personRepository

    @Namespace var scrollToTop

    // appstorage
    @AppStorage("shouldShowUserHeaders") var shouldShowUserHeaders: Bool = true
    let internetSpeed: InternetSpeed
    
    // environment
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    
    // parameters
    @State var userID: Int
    @State var userDetails: APIPersonView?

    @StateObject private var privatePostTracker: PostTracker
    @StateObject private var privateCommentTracker: CommentTracker = .init()
    @State private var avatarSubtext: String = ""
    @State private var showingCakeDay = false
    @State private var moderatedCommunities: [APICommunityModeratorView] = []
    
    @State private var selectionSection = UserViewTab.overview
    @State private var errorDetails: ErrorDetails?
    
    @State private var scrollToTopAppeared = false
    
    init(userID: Int, userDetails: APIPersonView? = nil) {
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        
        self.internetSpeed = internetSpeed
        
        self._userID = State(initialValue: userID)
        self._userDetails = State(initialValue: userDetails)
        
        self._privatePostTracker = StateObject(wrappedValue: .init(
            shouldPerformMergeSorting: false,
            internetSpeed: internetSpeed,
            upvoteOnSave: upvoteOnSave
        ))
    }
    
    // account switching
    @State private var isPresentingAccountSwitcher: Bool = false

    var body: some View {
        if let errorDetails {
            ErrorView(errorDetails)
                .fancyTabScrollCompatible()
                .hoistNavigation(dismiss: dismiss)
        } else {
            ScrollViewReader { proxy in
                contentView
                    .hoistNavigation(
                        dismiss: dismiss,
                        auxiliaryAction: {
                            withAnimation {
                                proxy.scrollTo(scrollToTop)
                            }
                            return true
                        }
                    )
                    .sheet(isPresented: $isPresentingAccountSwitcher) {
                        AccountsPage()
                    }
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if let userDetails {
            view(for: userDetails)
        } else {
            progressView
        }
    }
    
    @ViewBuilder
    private var moderatorButton: some View {
        if let user = userDetails, !moderatedCommunities.isEmpty {
            NavigationLink(.userModeratorLink(.init(user: user, moderatedCommunities: moderatedCommunities))) {
                Image(systemName: Icons.moderation)
            }
        }
    }
    
    @ViewBuilder
    private var accountSwitcher: some View {
        if isShowingOwnProfile() {
            Button {
                isPresentingAccountSwitcher = true
            } label: {
                Image(systemName: Icons.switchUser)
            }
        }
    }

    private func header(for userDetails: APIPersonView) -> some View {
        CommunitySidebarHeader(
            title: userDetails.person.displayName ?? userDetails.person.name,
            subtitle: "@\(userDetails.person.name)@\(userDetails.person.actorId.host()!)",
            avatarSubtext: $avatarSubtext,
            avatarSubtextClicked: toggleCakeDayVisible,
            bannerURL: shouldShowUserHeaders ? userDetails.person.bannerUrl : nil,
            avatarUrl: userDetails.person.avatarUrl,
            label1: "\(userDetails.counts.commentCount) Comments",
            label2: "\(userDetails.counts.postCount) Posts",
            avatarType: .user
        )
    }
    
    private func view(for userDetails: APIPersonView) -> some View {
        ScrollView {
            ScrollToView(appeared: $scrollToTopAppeared)
                .id(scrollToTop)
            
            header(for: userDetails)
            
            if let bio = userDetails.person.bio {
                MarkdownView(text: bio, isNsfw: false).padding()
            }
            
            Picker(selection: $selectionSection, label: Text("Profile Section")) {
                ForEach(UserViewTab.allCases, id: \.id) { tab in
                    // Skip tabs that are meant for only our profile
                    if tab.onlyShowInOwnProfile {
                        if isShowingOwnProfile() {
                            Text(tab.label).tag(tab.rawValue)
                        }
                    } else {
                        Text(tab.label).tag(tab.rawValue)
                    }
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            UserFeedView(
                userID: userID,
                privatePostTracker: privatePostTracker,
                privateCommentTracker: privateCommentTracker,
                selectedTab: $selectionSection
            )
        }
        .fancyTabScrollCompatible()
        .environmentObject(privatePostTracker)
        .environmentObject(privateCommentTracker)
        .navigationTitle(userDetails.person.displayName ?? userDetails.person.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarColor()
        .headerProminence(.standard)
        .refreshable {
            await tryReloadUser()
        }.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                accountSwitcher
                moderatorButton
            }
        }
    }
    
    private func updateAvatarSubtext() {
        if let user = userDetails {
            if showingCakeDay {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ddMMYY", options: 0, locale: Locale.current)
                
                avatarSubtext = "Joined \(dateFormatter.string(from: user.person.published))"
            } else {
                avatarSubtext = "Joined \(user.person.published.getRelativeTime(date: Date.now))"
            }
        } else {
            avatarSubtext = ""
        }
    }
    
    private func toggleCakeDayVisible() {
        showingCakeDay = !showingCakeDay
        updateAvatarSubtext()
    }
    
    private func isShowingOwnProfile() -> Bool {
        appState.isCurrentAccountId(userID)
    }
    
    @MainActor
    private var progressView: some View {
        ProgressView {
            if isShowingOwnProfile() {
                Text("Loading your profile…")
            } else {
                Text("Loading user profile…")
            }
        }
        .task(priority: .userInitiated) {
            await tryReloadUser()
        }
    }
    
    // swiftlint:disable function_body_length
    private func tryReloadUser() async {
        do {
            let authoredContent = try await personRepository.loadUserDetails(for: userID, limit: internetSpeed.pageSize)
            var savedContentData: GetPersonDetailsResponse?
            if isShowingOwnProfile() {
                savedContentData = try await personRepository.loadUserDetails(
                    for: userID,
                    limit: internetSpeed.pageSize,
                    savedOnly: true
                )
            }
            
            if isShowingOwnProfile(), let currentAccount = appState.currentActiveAccount {
                // take this opportunity to update the users avatar url to catch changes
                // we should be able to shift this down to the repository layer in the future so that we
                // catch anytime the app loads the signed in users details from any location in the app 🤞
                // -> we'll need to find a way to stop the state changes this creates from cancelling other in-flight requests
                let url = authoredContent.personView.person.avatarUrl
                let updatedAccount = SavedAccount(
                    id: currentAccount.id,
                    instanceLink: currentAccount.instanceLink,
                    accessToken: currentAccount.accessToken,
                    username: currentAccount.username,
                    storedNickname: currentAccount.storedNickname,
                    avatarUrl: url
                )
                appState.setActiveAccount(updatedAccount)
            }
            
            // accumulate comments and posts so we don't update state more than we need to
            var newComments = authoredContent.comments
                .sorted(by: { $0.comment.published > $1.comment.published })
                .map { HierarchicalComment(comment: $0, children: [], parentCollapsed: false, collapsed: false) }
            
            var newPosts = authoredContent.posts.map { PostModel(from: $0) }
            
            // add saved content, if present
            if let savedContent = savedContentData {
                newComments.append(contentsOf:
                    savedContent.comments
                        .sorted(by: { $0.comment.published > $1.comment.published })
                        .map { HierarchicalComment(comment: $0, children: [], parentCollapsed: false, collapsed: false) })
                
                newPosts.append(contentsOf: savedContent.posts.map { PostModel(from: $0) })
            }
            
            privateCommentTracker.comments = newComments
            privatePostTracker.reset(with: newPosts)
            
            userDetails = authoredContent.personView
            moderatedCommunities = authoredContent.moderates
            updateAvatarSubtext()
            
            errorDetails = nil
        } catch {
            if userDetails == nil {
                errorDetails = ErrorDetails(error: error, refresh: {
                    await tryReloadUser()
                    return userDetails != nil
                })
            } else {
                errorHandler.handle(
                    .init(
                        title: "Couldn't load user info",
                        message: "There was an error while loading user information.\nTry again later.",
                        underlyingError: error
                    )
                )
            }
        }
    }
    // swiftlint:enable function_body_length
}

// TODO: darknavi - Move these to a common area for reuse
struct UserViewPreview: PreviewProvider {
    static let previewAccount = SavedAccount(
        id: 0,
        instanceLink: URL(string: "lemmy.com")!,
        accessToken: "abcdefg",
        username: "Test Account"
    )
    
    // Only Admin and Bot work right now
    // Because the rest require post/comment context
    enum PreviewUserType: String, CaseIterable {
        case normal
        case mod
        case op
        case bot
        case admin
        case dev = "developer"
    }
    
    static func generatePreviewUser(
        name: String,
        displayName: String,
        userType: PreviewUserType
    ) -> APIPerson {
        .mock(
            id: name.hashValue,
            name: name,
            displayName: displayName,
            avatar: "https://lemmy.ml/pictrs/image/df86c06d-341c-4e79-9c80-d7c7eb64967a.jpeg?format=webp",
            published: Date.now.advanced(by: -10000),
            actorId: URL(string: "https://google.com")!,
            bio: "Just here for the good vibes!",
            banner: "https://i.imgur.com/wcayaCB.jpeg",
            admin: userType == .admin,
            botAccount: userType == .bot
        )
    }
    
    static func generatePreviewComment(creator: APIPerson, isMod: Bool) -> APIComment {
        APIComment(
            id: 0,
            creatorId: creator.id,
            postId: 0,
            content: "",
            removed: false,
            deleted: false,
            published: Date.now,
            updated: nil,
            apId: "foo.bar",
            local: false,
            path: "foo",
            distinguished: isMod,
            languageId: 0
        )
    }
    
    static func generateFakeCommunity(id: Int, namePrefix: String) -> APICommunity {
        .mock(
            id: id,
            name: "\(namePrefix) Fake Community \(id)",
            title: "\(namePrefix) Fake Community \(id) Title",
            description: "This is a fake community (#\(id))",
            published: Date.now,
            actorId: URL(string: "https://lemmy.google.com/c/\(id)")!
        )
    }
    
    static func generatePreviewPost(creator: APIPerson) -> PostModel {
        let community = generateFakeCommunity(id: 123, namePrefix: "Test")
        let post: APIPost = .mock(
            name: "Test Post Title",
            body: "This is a test post body",
            creatorId: creator.id,
            embedDescription: "Embeedded Description",
            embedTitle: "Embedded Title",
            published: Date.now
        )
        
        let postVotes = APIPostAggregates(
            id: 123,
            postId: post.id,
            comments: 0,
            score: 10,
            upvotes: 15,
            downvotes: 5,
            published: Date.now,
            newestCommentTime: Date.now,
            newestCommentTimeNecro: Date.now,
            featuredCommunity: false,
            featuredLocal: false
        )
        
        return PostModel(from: APIPostView(
            post: post,
            creator: creator,
            community: community,
            creatorBannedFromCommunity: false,
            counts: postVotes,
            subscribed: .notSubscribed,
            saved: false,
            read: false,
            creatorBlocked: false,
            unreadComments: 0
        ))
    }
    
    static func generateUserLinkView(name: String, userType: PreviewUserType) -> UserLinkView {
        let previewUser = generatePreviewUser(name: name, displayName: name, userType: userType)
        
        var postContext: PostModel?
        var commentContext: APIComment?
        
        if userType == .mod {
            commentContext = generatePreviewComment(creator: previewUser, isMod: true)
        }
        
        if userType == .op {
            commentContext = generatePreviewComment(creator: previewUser, isMod: false)
            postContext = generatePreviewPost(creator: previewUser)
        }
        
        return UserLinkView(
            user: previewUser,
            serverInstanceLocation: .bottom,
            overrideShowAvatar: true,
            postContext: postContext?.post,
            commentContext: commentContext
        )
    }
    
    static var previews: some View {
        UserView(
            userID: 123,
            userDetails: APIPersonView(
                person: generatePreviewUser(name: "actualUsername", displayName: "PreferredUsername", userType: .normal),
                counts: APIPersonAggregates(id: 123, personId: 123, postCount: 123, postScore: 567, commentCount: 14, commentScore: 974)
            )
        ).environmentObject(AppState())
    }
}

// swiftlint:enable file_length
