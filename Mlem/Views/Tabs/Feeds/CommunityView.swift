//
//  CommunityView.swift
//  Mlem
//
//  Created by Sjmarf on 31/12/2023.
//

import SwiftUI
import Dependencies

// swiftlint:disable type_body_length
struct CommunityView: View {
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.communityRepository) var communityRepository
    
    @AppStorage("shouldShowCommunityHeaders") var shouldShowCommunityHeaders: Bool = true
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    
    enum Tab: String, Identifiable, CaseIterable {
        var id: Self { self }
        case posts, about, moderators, statistics
    }
    
    @Environment(\.navigationPathWithRoutes) private var navigationPath
    @Environment(\.scrollViewProxy) private var scrollViewProxy
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var editorTracker: EditorTracker
    
    @State var community: CommunityModel
    @State var selectedTab: Tab = .posts
    
    @Binding var rootDetails: CommunityLinkWithContext?
    @Binding var splitViewColumnVisibility: NavigationSplitViewVisibility
    
    // MARK: Feed
    
    @StateObject var postTracker: PostTracker
    @State var postSortType: PostSortType
    
    // MARK: Scroll to top
    
    @Namespace var scrollToTop
    @State private var scrollToTopAppeared = false
    private var scrollToTopId: Int? {
        postTracker.items.first?.id
    }
    
    // MARK: Destructive confirmation
    
    @State private var isPresentingConfirmDestructive: Bool = false
    @State private var confirmationMenuFunction: StandardMenuFunction?
    
    func confirmDestructive(destructiveFunction: StandardMenuFunction) {
        confirmationMenuFunction = destructiveFunction
        isPresentingConfirmDestructive = true
    }
    
    init(
        community: CommunityModel,
        splitViewColumnVisibility: Binding<NavigationSplitViewVisibility>? = nil,
        rootDetails: Binding<CommunityLinkWithContext?>? = nil
    ) {
        // need to grab some stuff from app storage to initialize post tracker with
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        
        self._community = State(initialValue: community)
        
        self._rootDetails = rootDetails ?? .constant(nil)
        self._splitViewColumnVisibility = splitViewColumnVisibility ?? .constant(.automatic)
        
        @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
        self._postSortType = .init(wrappedValue: defaultPostSorting)
        
        self._postTracker = StateObject(wrappedValue: .init(
            shouldPerformMergeSorting: false,
            internetSpeed: internetSpeed,
            upvoteOnSave: upvoteOnSave,
            type: .community(community, sortedBy: defaultPostSorting)
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    ScrollToView(appeared: $scrollToTopAppeared)
                        .id(scrollToTop)
                    headerView
                        .padding(.top, 5)
                }
                .background(Color.systemBackground)
                switch selectedTab {
                case .posts:
                    if !postTracker.items.isEmpty {
                        Divider()
                            .padding(.top, 15)
                            .background(Color.secondarySystemBackground)
                    }
                    PostFeedView(community: community, postTracker: postTracker, postSortType: $postSortType)
                        .background(Color.secondarySystemBackground)
                case .about:
                    Divider()
                        .padding(.top, 15)
                        .background(Color.secondarySystemBackground)
                    VStack(spacing: AppConstants.postAndCommentSpacing) {
                        if shouldShowCommunityHeaders, let banner = community.banner {
                            CachedImage(url: banner, cornerRadius: AppConstants.largeItemCornerRadius)
                        }
                        MarkdownView(text: community.description ?? "", isNsfw: false)
                    }
                    .padding(AppConstants.postAndCommentSpacing)
                case .moderators:
                    if let moderators = community.moderators {
                        Divider()
                            .padding(.top, 15)
                            .background(Color.secondarySystemBackground)
                        ForEach(moderators, id: \.id) { user in
                            UserResultView(user, communityContext: community)
                            Divider()
                        }
                        Color.secondarySystemBackground
                            .frame(height: 100)
                    }
                case .statistics:
                    CommunityStatsView(community: community)
                        .padding(.top, 16)
                        .background(Color(uiColor: .systemGroupedBackground))
                }
            }
        }
        .refreshable {
            await postTracker.refresh()
        }
        .background {
            VStack(spacing: 0) {
                Color.systemBackground
                    .frame(height: 200)
                if selectedTab != .about && (selectedTab != .statistics || colorScheme == .light) {
                    Color.secondarySystemBackground
                } else {
                    Color.systemBackground
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fancyTabScrollCompatible()
        .navigationBarColor(visibility: .automatic)
        .hoistNavigation {
            if navigationPath.isEmpty {
                // Need to check `scrollToTopAppeared` because we want to scroll to top before popping back to sidebar. [2023.09]
                if scrollToTopAppeared {
                    if horizontalSizeClass == .regular {
                        print("show/hide sidebar in regular size class")
                        splitViewColumnVisibility = splitViewColumnVisibility == .all ? .detailOnly : .all
                        return true
                    } else {
                        print("show/hide sidebar in compact size class")
                        // This seems a lot more reliable than dismiss action for some reason. [2023.09]
                        rootDetails = nil
                        return true
                    }
                } else {
                    print("scroll to top")
                    withAnimation {
                        scrollViewProxy?.scrollTo(scrollToTop, anchor: .top)
                    }
                    return true
                }
            } else {
                if scrollToTopAppeared {
                    print("exhausted auxiliary actions, perform dismiss action instead...")
                    return false
                } else {
                    withAnimation {
                        scrollViewProxy?.scrollTo(scrollToTop, anchor: .top)
                    }
                    return true
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(community.name)
                    .font(.headline)
                    .opacity(scrollToTopAppeared ? 0 : 1)
                    .animation(.easeOut(duration: 0.2), value: scrollToTopAppeared)
            }
            ToolbarItemGroup(placement: .secondaryAction) {
                ForEach(
                    community.menuFunctions({ community = $0 },
                                            editorTracker: editorTracker,
                                            postTracker: postTracker
                                           )
                ) { menuFunction in
                    MenuButton(menuFunction: menuFunction, confirmDestructive: confirmDestructive)
                }
                .destructiveConfirmation(
                    isPresentingConfirmDestructive: $isPresentingConfirmDestructive,
                    confirmationMenuFunction: confirmationMenuFunction
                )
            }
        }
        .onAppear {
            if community.moderators == nil {
                Task(priority: .userInitiated) {
                    do {
                        self.community = try await communityRepository.loadDetails(for: community.communityId)
                    } catch {
                        errorHandler.handle(error)
                    }
                }
            }
        }
    }
    
    var availableTabs: [Tab] {
        var output: [Tab] = [.posts, .moderators, .statistics]
        if community.description != nil {
            output.insert(.about, at: 1)
        }
        return output
    }
    
    @ViewBuilder
    var headerView: some View {
        Group {
            VStack(spacing: 5) {
                HStack(alignment: .center, spacing: 10) {
                    if shouldShowCommunityIcons {
                        AvatarView(community: community, avatarSize: 44, iconResolution: .unrestricted)
                    }
                    Button(action: community.copyFullyQualifiedName) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(community.displayName)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                            if let fullyQualifiedName = community.fullyQualifiedName {
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
    
    var subscribeButtonForegroundColor: Color {
        if community.favorited {
            return .blue
        } else if community.subscribed ?? false {
            return .green
        }
        return .secondary
    }
    
    var subscribeButtonBackgroundColor: Color {
        if community.favorited {
            return .blue.opacity(0.1)
        } else if community.subscribed ?? false {
            return .green.opacity(0.1)
        }
        return .clear
    }
    
    var subscribeButtonIcon: String {
        if community.favorited {
            return Icons.favoriteFill
        } else if community.subscribed ?? false {
            return Icons.successCircle
        }
        return Icons.personFill
    }
    
    @ViewBuilder
    var subscribeButton: some View {
        let foregroundColor = subscribeButtonForegroundColor
        if let subscribed = community.subscribed {
            HStack(spacing: 4) {
                if let subscriberCount = community.subscriberCount {
                    Text(abbreviateNumber(subscriberCount))
                }
                Image(systemName: subscribeButtonIcon)
                    .aspectRatio(contentMode: .fit)
            }
            .foregroundStyle(foregroundColor)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(
                Capsule()
                    .strokeBorder(foregroundColor, style: .init(lineWidth: 1))
                    .background(Capsule().fill(subscribeButtonBackgroundColor))
            )
            .gesture(TapGesture().onEnded { _ in
                hapticManager.play(haptic: .lightSuccess, priority: .low)
                Task {
                    var community = community
                    do {
                        if community.favorited {
                            confirmDestructive(destructiveFunction: community.favoriteMenuFunction { self.community = $0 })
                        } else if subscribed {
                            confirmDestructive(destructiveFunction: try community.subscribeMenuFunction { self.community = $0 })
                        } else {
                            try await community.toggleSubscribe { item in
                                DispatchQueue.main.async { self.community = item }
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
                    var community = community
                    do {
                        try await community.toggleFavorite { item in
                            DispatchQueue.main.async { self.community = item }
                        }
                    } catch {
                        errorHandler.handle(error)
                    }
                }
            })
        }
    }
}

// swiftlint:enable type_body_length
