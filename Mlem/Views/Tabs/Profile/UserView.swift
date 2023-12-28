//
//  NewUserView.swift
//  Mlem
//
//  Created by Sjmarf on 27/12/2023.
//

import SwiftUI
import Dependencies

struct UserView: View {
    // @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.notifier) var notifier
    @Dependency(\.personRepository) var personRepository
    @Dependency(\.siteInformation) var siteInformation
    
    let internetSpeed: InternetSpeed
    
    @State var user: UserModel
    @State var selectedTab: UserViewTab = .overview
    @State var isLoadingContent: Bool = true
    
    @StateObject var privatePostTracker: PostTracker
    @StateObject var privateCommentTracker: CommentTracker = .init()
    
    @State private var isPresentingConfirmDestructive: Bool = false
    @State private var confirmationMenuFunction: StandardMenuFunction?
    
    func confirmDestructive(destructiveFunction: StandardMenuFunction) {
        confirmationMenuFunction = destructiveFunction
        isPresentingConfirmDestructive = true
    }
    
    var isOwnProfile: Bool { user.userId == siteInformation.myUserInfo?.localUserView.person.id }
    
    init(user: UserModel) {
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        
        self.internetSpeed = internetSpeed
        
        self._privatePostTracker = StateObject(wrappedValue: .init(
            shouldPerformMergeSorting: false,
            internetSpeed: internetSpeed,
            upvoteOnSave: upvoteOnSave
        ))
        
        self._user = State(wrappedValue: user)
    }
    
    @ViewBuilder
    var separator: some View {
        VStack(spacing: 0) {
            Divider()
            Color.secondarySystemBackground
                .frame(height: 16)
            Divider()
        }
    }
    
    var cakeDayFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ddMMYY", options: 0, locale: Locale.current)
        return dateFormatter
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                UserHeaderView(user: user)
                    .padding(.horizontal, AppConstants.postAndCommentSpacing)
                    .padding(.top, 10)
                Button(action: user.copyFullyQualifiedUsername) {
                    VStack(spacing: 5) {
                        Text(user.displayName)
                            .font(.title.bold())
                        Text("@\(user.name)@\(user.profileUrl.host() ?? "unknown")")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
                .padding(.bottom, AppConstants.postAndCommentSpacing)
                
                VStack(spacing: 0) {
                    if let bio = user.bio {
                        MarkdownView(text: bio, isNsfw: false, alignment: .center).padding(AppConstants.postAndCommentSpacing)
                            
                    }
                    let date1 = cakeDayFormatter.string(from: user.creationDate)
                    let date2 = user.creationDate.getRelativeTime(date: Date.now, unitsStyle: .abbreviated)
                    Label("Joined \(date1), \(date2)", systemImage: Icons.cakeDay)
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                        .padding(.leading, AppConstants.postAndCommentSpacing)
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
                            ScrollView(.horizontal) {
                                BubblePicker([.overview, .posts, .comments, .saved], selected: $selectedTab) { tab in
                                    switch tab {
                                    case .posts:
                                        Text("Posts (\(abbreviateNumber(user.postCount ?? 0)))")
                                    case .comments:
                                        Text("Comments (\(abbreviateNumber(user.commentCount ?? 0)))")
                                    default:
                                        Text(tab.label)
                                    }
                                }
                                .padding(.horizontal, AppConstants.postAndCommentSpacing)
                                .padding(.vertical, 4)
                            }
                            .scrollIndicators(.hidden)
                            Divider()
                            UserFeedView(
                                userID: user.userId,
                                privatePostTracker: privatePostTracker,
                                privateCommentTracker: privateCommentTracker,
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
            ToolbarItem(placement: .topBarTrailing) {
                let functions = user.menuFunctions { user = $0 }
                if functions.count == 1, let first = functions.first {
                    MenuButton(menuFunction: first, confirmDestructive: confirmDestructive)
                } else {
                    Menu {
                        ForEach(functions) { item in
                            MenuButton(menuFunction: item, confirmDestructive: confirmDestructive)
                        }
                    } label: {
                        Label("Menu", systemImage: Icons.menu)
                    }
                }
            }
        }
        .task(priority: .userInitiated) {
            await tryReloadUser()
        }
        .onChange(of: user.userId) { _ in
            Task {
                await tryReloadUser()
            }
        }
        .refreshable {
            await tryReloadUser()
        }
        .fancyTabScrollCompatible()
        .navigationTitle(user.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
