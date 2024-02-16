//
//  NewUserView.swift
//  Mlem
//
//  Created by Sjmarf on 27/12/2023.
//

import Dependencies
import SwiftUI

struct PersonView: View {
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.notifier) var notifier
    
    @Environment(\.navigationPathWithRoutes) private var navigationPath
    @Environment(\.scrollViewProxy) private var scrollViewProxy
    
    @Environment(AppState.self) var appState
        
    let internetSpeed: InternetSpeed
    let communityContext: (any CommunityStubProviding)?
    
    @State var person: any PersonStubProviding
    @State var selectedTab: UserViewTab = .overview
    @State var isLoadingContent: Bool = true
    
    @State var isPresentingAccountSwitcher: Bool = false
    
    @State private var isPresentingConfirmDestructive: Bool = false
    @State private var confirmationMenuFunction: StandardMenuFunction?
    
    @Namespace var scrollToTop
    @State private var scrollToTopAppeared = false
    
    func confirmDestructive(destructiveFunction: StandardMenuFunction) {
        confirmationMenuFunction = destructiveFunction
        isPresentingConfirmDestructive = true
    }
    
    init(person: any PersonStubProviding, communityContext: (any CommunityStubProviding)? = nil) {
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        
        self.internetSpeed = internetSpeed

        self._person = State(wrappedValue: person)
        self.communityContext = communityContext
    }
    
    var body: some View {
        ScrollView {
            ScrollToView(appeared: $scrollToTopAppeared)
                .id(scrollToTop)
            VStack(spacing: AppConstants.postAndCommentSpacing) {
                AvatarBannerView(person: person as? any Person)
                    .padding(.horizontal, AppConstants.postAndCommentSpacing)
                    .padding(.top, 10)
                Button {
                    person.copyFullNameWithPrefix(notifier: notifier)
                } label: {
                    VStack(spacing: 5) {
                        Text(person.displayName_ ?? person.name)
                            .font(.title)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                        Text(person.fullName ?? person.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, AppConstants.postAndCommentSpacing)
                .buttonStyle(.plain)
                
                flairs
                
                VStack(spacing: 0) {
                    let bioAlignment = bioAlignment
                    if let bio = person.description_ {
                        Divider()
                            .padding(.bottom, AppConstants.postAndCommentSpacing)
                        MarkdownView(text: bio, isNsfw: false, alignment: bioAlignment).padding(AppConstants.postAndCommentSpacing)
                    }
                    if let creationDate = person.creationDate_ {
                        HStack {
                            Label(creationDate.dateString, systemImage: Icons.cakeDay)
                            Text("•")
                            Label(creationDate.getRelativeTime(date: Date.now, unitsStyle: .abbreviated), systemImage: Icons.time)
                            if bioAlignment == .leading {
                                Spacer()
                            }
                        }
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                        .padding(.horizontal, AppConstants.postAndCommentSpacing)
                        .padding(.top, 2)
                    }
                    
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
                                    Text("Posts (\(abbreviateNumber(person.postCount_ ?? 0)))")
                                case .comments:
                                    Text("Comments (\(abbreviateNumber(person.commentCount_ ?? 0)))")
                                case .communities:
                                    Text("Communities (\(abbreviateNumber(person.moderatedCommunities_?.count ?? 0)))")
                                default:
                                    Text(tab.label)
                                }
                            }
                            .padding(.vertical, 4)
                            Divider()
//                            UserFeedView(
//                                user: user,
//                                privatePostTracker: privatePostTracker,
//                                privateCommentTracker: privateCommentTracker,
//                                communityTracker: communityTracker,
//                                selectedTab: $selectedTab
//                            )
                        }
                        .transition(.opacity)
                    }
                }
                .animation(.easeOut(duration: 0.2), value: isLoadingContent)
            }
        }
        .destructiveConfirmation(
            isPresentingConfirmDestructive: $isPresentingConfirmDestructive,
            confirmationMenuFunction: confirmationMenuFunction
        )
//        .toolbar {
//            ToolbarItemGroup(placement: .secondaryAction) {
//                let functions = user.menuFunctions({ user = $0 }, editorTracker: editorTracker)
//                ForEach(functions) { item in
//                    MenuButton(menuFunction: item, confirmDestructive: confirmDestructive)
//                }
//            }
//        }
//        .task(priority: .userInitiated) {
//            if isLoadingContent {
//                Task {
//                    await tryReloadUser()
//                }
//            }
//        }
//        .onChange(of: user.userId) { _ in
//            Task {
//                await tryReloadUser()
//            }
//        }
//        .refreshable {
//            Task {
//                await tryReloadUser()
//            }
//        }
//        .onChange(of: siteInformation.myUserInfo?.localUserView.person) { newValue in
//            if isOwnProfile {
//                if let newValue {
//                    user.update(with: newValue)
//                }
//            }
//        }
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
        .navigationTitle(person.displayName_ ?? person.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var flairs: some View {
        Group {
            let flairs = person.getFlairs(communityContext: communityContext as? any Community)
            if !flairs.isEmpty {
                VStack(spacing: AppConstants.postAndCommentSpacing) {
                    ForEach(flairs, id: \.self) { flair in
                        flairBackground(color: flair.color) {
                            HStack {
                                switch flair {
                                case .banned:
                                    Image(systemName: Icons.bannedFlair)
                                    switch person.instanceBan_ {
                                    case let .temporarilyBanned(expires: date):
                                        Text("Banned Until \(date.dateString)")
                                    default:
                                        Text("Permanently Banned")
                                    }
                                case .admin:
                                    Image(systemName: Icons.adminFlair)
                                    Text("\(person.host ?? "Instance") Administrator")
                                case .moderator:
                                    Image(systemName: Icons.moderationFill)
                                    Text("\(communityContext?.displayName_ ?? "Community") Moderator")
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
