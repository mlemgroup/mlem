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
    
    enum Tab: String, Identifiable, CaseIterable {
        var id: Self { self }
        case posts, about, moderators, statistics
    }
    
    @Environment(\.navigationPathWithRoutes) private var navigationPath
    @Environment(\.scrollViewProxy) private var scrollViewProxy
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
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
                    }
                    PostFeedView(community: community, postTracker: postTracker, postSortType: $postSortType)
                        .background(Color.secondarySystemBackground)
                case .about:
                    Divider()
                    VStack(spacing: AppConstants.postAndCommentSpacing) {
                        if let banner = community.banner {
                            CachedImage(url: banner, cornerRadius: AppConstants.largeItemCornerRadius)
                        }
                        MarkdownView(text: community.description ?? "", isNsfw: false)
                    }
                    .padding(AppConstants.postAndCommentSpacing)
                case .moderators:
                    if let moderators = community.moderators {
                        Divider()
                        ForEach(moderators, id: \.id) { user in
                            UserResultView(user, communityContext: community)
                            Divider()
                        }
                        Color.secondarySystemBackground
                            .frame(height: 100)
                    }
                case .statistics:
                    Divider()
                    CommunityStatsView(community: community)
                        .padding(.top, 10)
                        .background(Color.systemBackground)
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
                if selectedTab != .about {
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
                    AvatarView(community: community, avatarSize: 44, iconResolution: .unrestricted)
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
                    Spacer()
                    if let subscribed = community.subscribed {
                        let foregroundColor: Color = subscribed ? .green : .secondary
                        Button {
                            hapticManager.play(haptic: .lightSuccess, priority: .low)
                            Task {
                                var community = community
                                do {
                                    if subscribed {
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
                        } label: {
                            HStack(spacing: 4) {
                                if let subscriberCount = community.subscriberCount {
                                    Text(abbreviateNumber(subscriberCount))
                                }
                                Image(systemName: subscribed ? Icons.successCircle : Icons.personFill)
                                    .aspectRatio(contentMode: .fit)
                            }
                            .foregroundStyle(foregroundColor)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(
                                Capsule()
                                    .strokeBorder(foregroundColor, style: .init(lineWidth: 1))
                                    .background(Capsule().fill(subscribed ? .green.opacity(0.1) : .clear))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppConstants.postAndCommentSpacing)
                .padding(.bottom, 3)
                Divider()
                BubblePicker(availableTabs, selected: $selectedTab) {
                    Text($0.rawValue.capitalized)
                }
            }
            Divider()
                .padding(.bottom, 15)
                .background(Color.secondarySystemBackground)
        }
    }
}

// swiftlint:enable type_body_length
