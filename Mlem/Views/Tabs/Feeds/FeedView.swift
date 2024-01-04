//
//  FeedView.swift
//  Mlem
//
//  Created by Sjmarf on 31/12/2023.
//

import SwiftUI
import Dependencies

struct FeedView: View {
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.siteInformation) var siteInformation
    
    @Environment(\.navigationPathWithRoutes) private var navigationPath
    @Environment(\.scrollViewProxy) private var scrollViewProxy
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject var appState: AppState

    @State var feedType: FeedType
    
    // MARK: Feed
    
    @StateObject var postTracker: PostTracker
    @State var postSortType: PostSortType
    
    @Binding var rootDetails: CommunityLinkWithContext?
    @Binding var splitViewColumnVisibility: NavigationSplitViewVisibility
    
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
        feedType: FeedType,
        splitViewColumnVisibility: Binding<NavigationSplitViewVisibility>? = nil,
        rootDetails: Binding<CommunityLinkWithContext?>? = nil
    ) {
        // need to grab some stuff from app storage to initialize post tracker with
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        
        self._feedType = State(initialValue: feedType)
        
        self._splitViewColumnVisibility = splitViewColumnVisibility ?? .constant(.automatic)
        self._rootDetails = rootDetails ?? .constant(nil)
        
        @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
        self._postSortType = .init(wrappedValue: defaultPostSorting)
        
        self._postTracker = StateObject(wrappedValue: .init(
            shouldPerformMergeSorting: false,
            internetSpeed: internetSpeed,
            upvoteOnSave: upvoteOnSave,
            type: .feed(feedType, sortedBy: defaultPostSorting)
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
                if !postTracker.items.isEmpty {
                    Divider()
                }
                PostFeedView(postTracker: postTracker, postSortType: $postSortType)
                    .background(Color.secondarySystemBackground)
            }
        }
        .refreshable {
            await Task {
                _ = await postTracker.refresh(clearBeforeFetch: true)
            }.value
        }
        .background {
            VStack(spacing: 0) {
                Color.systemBackground
                Color.secondarySystemBackground
            }
        }
        .frame(maxWidth: .infinity)
        .navigationBarTitleDisplayMode(.inline)
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
        .onChange(of: feedType) { newValue in
            postTracker.type = .feed(newValue, sortedBy: postSortType)
            scrollViewProxy?.scrollTo(scrollToTop, anchor: .top)
        }
        .fancyTabScrollCompatible()
        .toolbar {
            ToolbarItem(placement: .principal) {
                navBarTitle
                    .opacity(scrollToTopAppeared ? 0 : 1)
                    .animation(.easeOut(duration: 0.2), value: scrollToTopAppeared)
            }
        }
    }
    
    var subtitle: String {
        switch feedType {
        case .all:
            return "Posts from all federated instances"
        case .local:
            return "Posts from \(appState.currentActiveAccount?.instanceLink.host() ?? "your instance's") communities"
        case .subscribed:
            return "Posts from all subscribed communities"
        }
    }
    
    @ViewBuilder
    var headerView: some View {
        Group {
            VStack(spacing: 5) {
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: feedType.iconNameCircle)
                        .resizable()
                        .frame(width: 44, height: 44)
                        .foregroundStyle(feedType.color ?? .primary)
                    VStack(alignment: .leading, spacing: 0) {
                        Menu {
                            ForEach(genFeedSwitchingFunctions()) { menuFunction in
                                MenuButton(menuFunction: menuFunction, confirmDestructive: nil)
                            }
                        } label: {
                            HStack(spacing: 5) {
                                Text(feedType.label)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .fontWeight(.semibold)
                                Image(systemName: Icons.dropdown)
                                    .foregroundStyle(.secondary)
                            }
                            .font(.title2)
                        }
                        .buttonStyle(.plain)
                        Text(subtitle)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .frame(height: 44)
                    Spacer()
                }
                .padding(.horizontal, AppConstants.postAndCommentSpacing)
                .padding(.bottom, 3)
            }
            Divider()
            .padding(.bottom, 15)
            .frame(maxWidth: .infinity)
            .background(Color.secondarySystemBackground)
        }
    }
    
    @ViewBuilder
    var navBarTitle: some View {
        Menu {
            ForEach(genFeedSwitchingFunctions()) { menuFunction in
                MenuButton(menuFunction: menuFunction, confirmDestructive: nil)
            }
        } label: {
            HStack(alignment: .center, spacing: 0) {
                Text(feedType.label)
                    .font(.headline)
                Image(systemName: Icons.dropdown)
                    .scaleEffect(0.7)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.primary)
            .accessibilityElement(children: .combine)
            .accessibilityHint("Activate to change feeds.")
            // this disables the implicit animation on the header view...
            .transaction { $0.animation = nil }
        }
    }
}
