//
//  Community List View.swift
//  Mlem
//
//  Created by Jake Shirey on 17.06.2023.
//

import Dependencies
import SwiftUI

struct CommunitySection: Identifiable {
    let id = UUID()
    let viewId: String
    let sidebarEntry: any SidebarEntry
    let inlineHeaderLabel: String?
    let accessibilityLabel: String
}

struct CommunityListView: View {
    
    @Dependency(\.communityRepository) var communityRepository
    @Dependency(\.errorHandler) var errorHandler
    
    @EnvironmentObject var favoritedCommunitiesTracker: FavoriteCommunitiesTracker
    @EnvironmentObject var appState: AppState
    @Environment(\.openURL) var openURL
    @Environment(\.navigationPath) var navigationPath
    @AppStorage("defaultFeed") var defaultFeed: FeedType = .subscribed

    @State var subscribedCommunities = [APICommunity]()

    // swiftlint:disable line_length
    private static let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    // swiftlint:enable line_length

    // Note: These are in order that they appear in the sidebar
    @State var communitySections: [CommunitySection] = []

    @Binding var selectedCommunity: CommunityLinkWithContext?

    init(selectedCommunity: Binding<CommunityLinkWithContext?>) {
        self._selectedCommunity = selectedCommunity
    }

    var body: some View {
            ScrollViewReader { scrollProxy in
                HStack {
                    List(selection: $selectedCommunity) {
                        HomepageFeedRowView(
                            feedType: .subscribed,
                            iconName: AppConstants.subscribedFeedSymbolNameFill,
                            iconColor: .red,
                            description: "Subscribed communities from all servers"
                        )
                            .id("top") // For "scroll to top" sidebar item
                        HomepageFeedRowView(
                            feedType: .local,
                            iconName: AppConstants.localFeedSymbolNameFill,
                            iconColor: .green,
                            description: "Local communities from your server"
                        )
                        HomepageFeedRowView(
                            feedType: .all,
                            iconName: AppConstants.federatedFeedSymbolNameFill,
                            iconColor: .blue,
                            description: "All communities that federate with your server"
                        )

                        ForEach(calculateVisibleCommunitySections()) { communitySection in
                            Section(header:
                                        HStack {
                                Text(communitySection.inlineHeaderLabel!).accessibilityLabel(communitySection.accessibilityLabel)
                                Spacer()
                            }.id(communitySection.viewId)) {
                                ForEach(
                                    calculateCommunityListSections(for: communitySection),
                                    id: \.id
                                ) { listedCommunity in
                                    CommuntiyFeedRowView(
                                        community: listedCommunity,
                                        subscribed: subscribedCommunities.contains(listedCommunity),
                                        communitySubscriptionChanged: self.hydrateCommunityData
                                    )
                                }
                            }
                        }

                    }
                    .fancyTabScrollCompatible()
                    .navigationTitle("Communities")
                    .navigationBarColor()
                    .listStyle(PlainListStyle())
                    .scrollIndicators(.hidden)

                    SectionIndexTitles(proxy: scrollProxy, communitySections: communitySections)
                }
            }
        .refreshable {
            await refreshCommunitiesList()
        }
        .onAppear {
            Task(priority: .high) {
                await refreshCommunitiesList()
            }
            // Set up sections after we body is called
            // so we can use the favorite tracker environment
            communitySections = [
                CommunitySection(
                    viewId: "top",
                    sidebarEntry: EmptySidebarEntry(
                        sidebarLabel: nil,
                        sidebarIcon: "line.3.horizontal"
                    ),
                    inlineHeaderLabel: nil,
                    accessibilityLabel: "Top of communities"
                ),
                CommunitySection(
                    viewId: "favorites",
                    sidebarEntry: FavoritesSidebarEntry(
                        account: appState.currentActiveAccount,
                        favoritesTracker: favoritedCommunitiesTracker,
                        sidebarLabel: nil,
                        sidebarIcon: "star.fill"
                    ),
                    inlineHeaderLabel: "Favorites",
                    accessibilityLabel: "Favorited Communities"
                )
            ] +
            CommunityListView.alphabet.map {
                // This looks sinister but I didn't know how to string replace in a non-string based regex
                CommunitySection(
                    viewId: $0,
                    sidebarEntry: RegexCommunityNameSidebarEntry(
                        communityNameRegex: (try? Regex("^[\($0.uppercased())\($0.lowercased())]"))!,
                        sidebarLabel: $0,
                        sidebarIcon: nil
                    ),
                    inlineHeaderLabel: $0,
                    accessibilityLabel: "Communities starting with the letter '\($0)'")} +
            [CommunitySection(
                viewId: "non_letter_titles",
                sidebarEntry: RegexCommunityNameSidebarEntry(
                    communityNameRegex: /^[^a-zA-Z]/,
                    sidebarLabel: "#",
                    sidebarIcon: nil
                ),
                inlineHeaderLabel: "#",
                accessibilityLabel: "Communities starting with a symbol or number"
            )]
        }
    }

    private func refreshCommunitiesList() async {
        do {
            subscribedCommunities = try await communityRepository
                .loadSubscriptions()
                .map { $0.community }
                .sorted()
        } catch {
            errorHandler.handle(error)
        }
    }

    private func calculateCommunityListSections(for section: CommunitySection) -> [APICommunity] {
        // Filter down to sidebar entry which wants us
        return getSubscriptionsAndFavorites()
            .filter({ (listedCommunity) -> Bool in
                section.sidebarEntry.contains(community: listedCommunity, isSubscribed: subscribedCommunities.contains(listedCommunity))
            })
    }

    private func calculateVisibleCommunitySections() -> [CommunitySection] {
        return communitySections

        // Only show letter headers for letters we have in our community list
            .filter({ communitySection -> Bool in
                getSubscriptionsAndFavorites()
                    .contains(where: { communitySection.sidebarEntry
                        .contains(community: $0, isSubscribed: subscribedCommunities.contains($0)) })
            })
        // Only show sections which have labels to show
            .filter({ (communitySection) -> Bool in
                communitySection.inlineHeaderLabel != nil
            })
    }

    private func hydrateCommunityData(community: APICommunity, isSubscribed: Bool) {
        // Add or remove subscribed sub locally
        if isSubscribed {
            subscribedCommunities.append(community)
            subscribedCommunities = subscribedCommunities.sorted()
        } else {
            if let index = subscribedCommunities.firstIndex(where: { $0 == community }) {
                subscribedCommunities.remove(at: index)
            }
        }
    }

    func getSubscriptionsAndFavorites() -> [APICommunity] {
        var result = subscribedCommunities

        // Merge in our favorites list too just incase we aren't subscribed to our favorites
        result.append(contentsOf: favoritedCommunitiesTracker.favoriteCommunities.map({ $0.community }))

        // Remove duplicates and sort by name
        result = Array(Set(result)).sorted()

        return result
    }
}

// Original article here: https://www.fivestars.blog/code/section-title-index-swiftui.html
struct SectionIndexTitles: View {
    
    @Dependency(\.hapticManager) var hapticManager
    
    let proxy: ScrollViewProxy
    let communitySections: [CommunitySection]
    @GestureState private var dragLocation: CGPoint = .zero

    // Track which sidebar label we picked last to we
    // only haptic when selecting a new one
    @State var lastSelectedLabel: String = ""

    var body: some View {
        VStack {
            ForEach(communitySections) { communitySection in
                HStack {
                    if communitySection.sidebarEntry.sidebarIcon != nil {
                        SectionIndexImage(image: communitySection.sidebarEntry.sidebarIcon!)
                            .padding(.trailing)
                    } else if communitySection.sidebarEntry.sidebarLabel != nil {
                        SectionIndexText(label: communitySection.sidebarEntry.sidebarLabel!)
                            .padding(.trailing)
                    } else {
                        EmptyView()
                    }
                }
                .background(dragObserver(viewId: communitySection.viewId))
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .updating($dragLocation) { value, state, _ in
                    state = value.location
                }
        )
    }

    func dragObserver(viewId: String) -> some View {
        GeometryReader { geometry in
            dragObserver(geometry: geometry, viewId: viewId)
        }
    }

    func dragObserver(geometry: GeometryProxy, viewId: String) -> some View {
        if geometry.frame(in: .global).contains(dragLocation) {
            if viewId != lastSelectedLabel {
                DispatchQueue.main.async {
                    lastSelectedLabel = viewId
                    proxy.scrollTo(viewId, anchor: .center)

                    // Play nice tappy taps
                    // HapticManager.shared.rigidInfo()
                    hapticManager.play(haptic: .rigidInfo, priority: .low)
                }
            }
        }
        return Rectangle().fill(Color.clear)
    }
}

// Sidebar Label Views
struct SectionIndexText: View {
    let label: String
    var body: some View {
        Text(label).font(.system(size: 12)).bold()
    }
}

struct SectionIndexImage: View {
    let image: String
    var body: some View {
        Image(systemName: image).resizable()
            .frame(width: 8, height: 8)
    }
}

struct CommunityListViewPreview: PreviewProvider {
    
    static var appState = AppState(
        defaultAccount: .mock(),
        selectedAccount: .constant(nil)
    )
    
    static var previews: some View {
        Group {
            NavigationStack {
                CommunityListView(
                    selectedCommunity: .constant(nil)
                )
                .environmentObject(
                    FavoriteCommunitiesTracker()
                )
                .environmentObject(appState)
            }
            .previewDisplayName("Populated")
            
            NavigationStack {
                withDependencies {
                    // return no subscriptions...
                    $0.communityRepository.subscriptions = { _ in [] }
                } operation: {
                    CommunityListView(
                        selectedCommunity: .constant(nil)
                    )
                    .environmentObject(
                        FavoriteCommunitiesTracker()
                    )
                    .environmentObject(appState)
                }
            }
            .previewDisplayName("Empty")
            
            NavigationStack {
                withDependencies {
                    // return an error when calling subscriptions
                    $0.communityRepository.subscriptions = { _ in
                        throw APIClientError.response(.init(error: "Borked"), nil)
                    }
                } operation: {
                    CommunityListView(
                        selectedCommunity: .constant(nil)
                    )
                    .environmentObject(
                        FavoriteCommunitiesTracker()
                    )
                    .environmentObject(appState)
                }
            }
            .previewDisplayName("Error")
        }
    }
}
