//
//  BlockListView.swift
//  Mlem
//
//  Created by Sjmarf on 19/04/2024.
//

import Dependencies
import SwiftUI

private enum BlockListTab: String, Identifiable, CaseIterable {
    var id: Self { self }
    
    case users, communities, instances
}

struct BlockListView: View {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.notifier) var notifier
    @State private var selected: BlockListTab = .users
    
    @Namespace var scrollToTop
    @State var scrollToTopAppeared = true
    
    @State var communities: [CommunityModel] = .init()
    @State var users: [UserModel] = .init()
    @State var instances: [APIInstance] = .init()
    
    @State var hasDoneInitialLoad: Bool = false
    @State var isLoading: Bool = true
    @State var errorDetails: ErrorDetails?
    
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
                            BlockListTab.allCases,
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
                    self.hasDoneInitialLoad = true
                }
                await self.loadItems()
            }
        }
        .refreshable {
            await Task {
                if !isLoading {
                    await self.loadItems()
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
                        swipeActions: swipeActions {
                            Task {
                                await user.toggleBlock(removeUser)
                            }
                        },
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
                        swipeActions: swipeActions {
                            Task {
                                try await community.toggleBlock(removeCommunity)
                            }
                        },
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
    
    func loadItems() async {
        isLoading = true
        errorDetails = nil
        do {
            let info = try await apiClient.loadSiteInformation()
            if let myUser = info.myUser {
                DispatchQueue.main.async {
                    self.communities = myUser.communityBlocks.map { .init(from: $0.community, blocked: true) }
                    self.users = myUser.personBlocks.map { .init(from: $0.target, blocked: true) }
                    self.instances = myUser.instanceBlocks?.map(\.instance) ?? .init()
                    self.isLoading = false
                }
            }
        } catch {
            isLoading = false
            errorDetails = .init(error: error)
        }
    }
    
    func unblockInstance(id: Int) {
        Task {
            do {
                try await apiClient.blockSite(id: id, shouldBlock: false)
                await notifier.add(.success("Unblocked instance"))
                if let index = instances.firstIndex(
                    where: { $0.id == id }
                ) {
                    instances.remove(at: index)
                }
            } catch {
                await notifier.add(.failure("Failed to unblock instance"))
            }
        }
    }
    
    func removeUser(_ user: UserModel) {
        if !user.blocked, let index = users.firstIndex(
            where: { $0.userId == user.userId }
        ) {
            users.remove(at: index)
        }
    }
    
    func removeCommunity(_ community: CommunityModel) {
        if !(community.blocked ?? true), let index = communities.firstIndex(
            where: { $0.communityId == community.communityId }
        ) {
            communities.remove(at: index)
        }
    }
}
