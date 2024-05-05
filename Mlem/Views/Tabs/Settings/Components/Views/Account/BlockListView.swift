//
//  BlockListView.swift
//  Mlem
//
//  Created by Sjmarf on 19/04/2024.
//

import Dependencies
import SwiftUI

enum BlockListTab: String, Identifiable, CaseIterable {
    var id: Self { self }
    
    case communities, users, instances
}

struct BlockListView: View {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.notifier) var notifier
    @Dependency(\.siteInformation) var siteInformation
    
    @State var selected: BlockListTab = .users
    
    @Namespace var scrollToTop
    @State var scrollToTopAppeared = true
    
    @State var communities: [CommunityModel] = .init()
    @State var users: [UserModel] = .init()
    @State var instances: [APIInstance] = .init()
    
    @State var hasDoneInitialLoad: Bool = false
    @State var isLoading: Bool = true
    @State var errorDetails: ErrorDetails?
    
    var availableTabs: [BlockListTab] {
        // TODO: 0.18 deprecation
        if (siteInformation.version ?? .infinity) >= .init("0.19.0") {
            return BlockListTab.allCases
        }
        return [.communities, .users]
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                ScrollToView(appeared: $scrollToTopAppeared)
                    .id(scrollToTop)
                Section {
                    if let errorDetails {
                        ErrorView(errorDetails)
                    } else if isLoading {
                        LoadingView(whatIsLoading: .blockList)
                    } else {
                        resultsView()
                    }
                } header: {
                    HStack {
                        BubblePicker(
                            availableTabs,
                            selected: $selected,
                            withDividers: [.bottom],
                            label: \.rawValue.capitalized
                        )
                    }
                    .background(Color.systemBackground.opacity(scrollToTopAppeared ? 1 : 0))
                    .background(.bar)
                    .animation(.easeOut(duration: 0.2), value: scrollToTopAppeared)
                }
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Block List")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if !hasDoneInitialLoad {
                DispatchQueue.main.async {
                    hasDoneInitialLoad = true
                }
                await loadItems()
            }
        }
        .refreshable {
            await Task {
                if !isLoading {
                    await loadItems()
                }
            }.value
        }
    }
    
    @ViewBuilder
    func resultsView() -> some View {
        switch selected {
        case .users:
            usersView()
        case .communities:
            communitiesView()
        case .instances:
            instancesView()
        }
    }
    
    @ViewBuilder
    func usersView() -> some View {
        if users.isEmpty {
            noItemsView()
        } else {
            ForEach(users) { user in
                VStack(spacing: 0) {
                    UserListRow(
                        user,
                        showBlockStatus: false,
                        swipeActions: swipeActions { user.blockCallback(removeUser) },
                        trackerCallback: removeUser
                    )
                    Divider()
                }
            }
        }
    }
    
    @ViewBuilder
    func communitiesView() -> some View {
        if communities.isEmpty {
            noItemsView()
        } else {
            ForEach(communities) { community in
                VStack(spacing: 0) {
                    CommunityListRow(
                        community,
                        showBlockStatus: false,
                        swipeActions: swipeActions { community.blockCallback(removeCommunity) },
                        trackerCallback: removeCommunity
                    )
                    Divider()
                }
            }
        }
    }
    
    @ViewBuilder
    func instancesView() -> some View {
        if instances.isEmpty {
            noItemsView()
        } else {
            ForEach(instances) { instance in
                VStack(alignment: .leading, spacing: 0) {
                    Text(instance.domain)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.vertical, 16)
                        .background(.background)
                        .addSwipeyActions(swipeActions { unblockInstance(id: instance.id) })
                        .contextMenu {
                            Button("Unblock", systemImage: Icons.show) {
                                unblockInstance(id: instance.id)
                            }
                        }
                    Divider()
                }
            }
        }
    }

    @ViewBuilder
    func noItemsView() -> some View {
        Text("Nothing to see here.")
            .foregroundStyle(.secondary)
            .padding(.top, 20)
    }
    
    func swipeActions(_ callback: @escaping () -> Void) -> SwipeConfiguration {
        .init(trailingActions: [
            .init(symbol: .init(emptyName: "eye", fillName: "eye.fill"), color: .gray, action: callback)
        ])
    }
}
