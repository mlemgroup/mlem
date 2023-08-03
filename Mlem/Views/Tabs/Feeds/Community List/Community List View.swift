//
//  Community List View.swift
//  Mlem
//
//  Created by Jake Shirey on 17.06.2023.
//

import SwiftUI
import Dependencies

struct CommunitySection: Identifiable {
    let id = UUID()
    let viewId: String
    let sidebarEntry: any SidebarEntry
    let inlineHeaderLabel: String?
    let accessibilityLabel: String
}

struct CommunityListView: View {
    @EnvironmentObject var favoritedCommunitiesTracker: FavoriteCommunitiesTracker
    @EnvironmentObject var appState: AppState
    @Environment(\.openURL) var openURL
    @Environment(\.navigationPath) var navigationPath
    @AppStorage("defaultFeed") var defaultFeed: FeedType = .subscribed

    @State var subscribedCommunities = [APICommunity]()

    private var hasTestCommunities = false

    // swiftlint:disable line_length
    private static let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    // swiftlint:enable line_length

    // Note: These are in order that they appear in the sidebar
    @State var communitySections: [CommunitySection] = []

    @Binding var selectedCommunity: CommunityLinkWithContext?

    init(testCommunities: [APICommunity]? = nil,
         selectedCommunity: Binding<CommunityLinkWithContext?>
    ) {
        if testCommunities != nil {
            self._subscribedCommunities = State(initialValue: testCommunities!)
            self.hasTestCommunities = true
        }
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
                // NOTE: This will not auto request if data is provided
                // This is normally only during preview
                if hasTestCommunities == false {
                    await refreshCommunitiesList()
                }
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
        let communitiesRequestCount = 50
        do {
            var moreCommunities = true
            var refreshedCommunities: [APICommunity] = []
            var communitiesPage = 1
            repeat {
                let request = ListCommunitiesRequest(
                    account: appState.currentActiveAccount,
                    sort: nil,
                    page: communitiesPage,
                    limit: communitiesRequestCount,
                    type: FeedType.subscribed
                )

                let response = try await APIClient().perform(request: request)

                let newSubscribedCommunities = response.communities.map({
                    return $0.community
                })

                refreshedCommunities.append(contentsOf: newSubscribedCommunities)

                communitiesPage += 1

                // Go until we get less than the count we ask for
                moreCommunities = response.communities.count == communitiesRequestCount
            } while (moreCommunities)

            subscribedCommunities = refreshedCommunities.sorted()
        } catch {
            appState.contextualError = .init(underlyingError: error)
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
                    hapticManager.play(haptic: .rigidInfo)
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

// TODO: darknavi - Move API struct generation
// to a common test area for easier discoverability
// and broader usage
let fakeCommunityPrefixes: [String] =
// Generate A-Z
Array(65...90).map({
    var asciiStr = ""
    asciiStr.append(Character(UnicodeScalar($0)!))
    return asciiStr
}) +
// Generate a-z
Array(97...122).map({
    var asciiStr = ""
    asciiStr.append(Character(UnicodeScalar($0)!))
    return asciiStr
}) +
// Generate A bunch of randomm ASCII to make sure sorting works
Array(33...95).map({
    var asciiStr = ""
    asciiStr.append(Character(UnicodeScalar($0)!))
    return asciiStr
})

func generateFakeCommunity(id: Int, namePrefix: String) -> APICommunity {
    APICommunity(
        id: id,
        name: "\(namePrefix) Fake Community \(id)",
        title: "\(namePrefix) Fake Community \(id) Title",
        description: "This is a fake community (#\(id))",
        published: Date.now,
        updated: nil,
        removed: false,
        deleted: false,
        nsfw: false,
        actorId: URL(string: "https://lemmy.google.com/c/\(id)")!,
        local: false,
        icon: nil,
        banner: nil,
        hidden: false,
        postingRestrictedToMods: false,
        instanceId: 0
    )
}

func generateFakeAccount() -> SavedAccount {
    return SavedAccount(id: 12345,
                        instanceLink: URL(string: "https://lemmy.world")!,
                        accessToken: "TOKEN",
                        username: "mlemguy")
}

func generateFakeFavoritedCommunity(id: Int, namePrefix: String) -> FavoriteCommunity {
    return FavoriteCommunity(forAccountID: 0, community: generateFakeCommunity(id: id, namePrefix: namePrefix))
}

// TODO: commenting this out for now as the tracker no longer takes an argument purely for constructing previews
// I'll look at moving the community calls into a repostiory next and that way we can stub mock data via the dependency 🤞

// struct CommunityListViewPreview: PreviewProvider {
//    static let favoritesTracker: FavoriteCommunitiesTracker = FavoriteCommunitiesTracker(favoriteCommunities: [
//        generateFakeFavoritedCommunity(id: 0, namePrefix: fakeCommunityPrefixes[0]),
//        generateFakeFavoritedCommunity(id: 20, namePrefix: fakeCommunityPrefixes[20]),
//        generateFakeFavoritedCommunity(id: 10, namePrefix: fakeCommunityPrefixes[10])
//    ])
//    static var previews: some View {
//        CommunityListView(
//            testCommunities: fakeCommunityPrefixes.enumerated().map({ index, element in
//                generateFakeCommunity(id: index, namePrefix: element)
//            }),
//            selectedCommunity: .constant(nil)
//        ).environmentObject(favoritesTracker)
//    }
// }
