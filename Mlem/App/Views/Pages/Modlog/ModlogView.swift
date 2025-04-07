//
//  ModlogView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-25.
//

import MlemMiddleware
import SwiftUI
import Theming

struct ModlogView: View {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    
    @Setting(\.safety_enableModlogWarning) var showModlogWarning
    
    let api: ApiClient
    let initialTarget: InitialTarget
    
    @State var feedLoader: ModlogFeedLoader
    @State var warningPresented: Bool = Settings.get(\.safety_enableModlogWarning)
    
    @State var communityFilter: CommunityFilter?
    @State var actionTypeFilter: ApiModlogActionType?
    
    init(initialTarget: InitialTarget) {
        self._feedLoader = .init(
            wrappedValue: .init(
                api: AppState.main.firstApi,
                pageSize: Settings.get(\.behavior_internetSpeed).pageSize,
                communityId: nil,
                sortType: .new
            )
        )
        self.initialTarget = initialTarget
        switch initialTarget {
        case let .community(community):
            if let community = community.wrappedValue as? any Community {
                self._communityFilter = .init(wrappedValue: .community(community))
            }
            self.api = community.wrappedValue.api
        case let .instance(instance):
            self._communityFilter = .init(wrappedValue: .any)
            self.api = instance.wrappedValue.api
        }
    }
    
    var body: some View {
        Group {
            switch initialTarget {
            case let .community(initialCommunity):
                ContentLoader(model: initialCommunity) { proxy in
                    Group {
                        if let communityFilter {
                            content(communityFilter: communityFilter)
                        } else {
                            ProgressView()
                                .onAppear {
                                    if communityFilter == nil, let community = proxy.entity {
                                        communityFilter = .community(community)
                                    }
                                }
                        }
                    }
                }
            case .instance:
                if let communityFilter {
                    content(communityFilter: communityFilter)
                } else {
                    ProgressView()
                }
            }
        }
        .navigationTitle("Modlog")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $warningPresented) {
            WarningOverlayView(
                text: "The modlog may contain disturbing or adult material.",
                isPresented: $warningPresented,
                showWarningAgain: $showModlogWarning
            )
        }
        .onChange(of: communityFilter, initial: true) { oldValue, newValue in
            // This prevents the feed from refreshing when changing tabs
            guard oldValue != newValue || (feedLoader.loadingState == .loading && feedLoader.items.isEmpty) else {
                return
            }
            if communityFilter != nil {
                Task {
                    do {
                        try await refresh()
                    } catch {
                        handleError(error)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func content(communityFilter: CommunityFilter) -> some View {
        ScrollView {
            filtersView(communityFilter: communityFilter)
            LazyVStack(spacing: Constants.main.standardSpacing) {
                ForEach(
                    Array(feedLoader.items(ofType: actionTypeFilter).enumerated()),
                    id: \.offset
                ) { _, entry in entryView(entry) }
                EndOfFeedView(feedLoader: activeFeedLoader, viewType: .hobbit)
            }
            .padding([.horizontal, .bottom], Constants.main.standardSpacing)
        }
        .themedGroupedBackground()
    }
    
    @ViewBuilder
    func entryView(_ entry: ModlogEntry) -> some View {
        ModlogEntryView(entry: entry, targetCommunity: communityFilter?.communityValue)
            .onAppear {
                do {
                    try activeFeedLoader.loadIfThreshold(entry)
                } catch {
                    handleError(error)
                }
            }
    }
    
    @ViewBuilder
    func filtersView(communityFilter: CommunityFilter) -> some View {
        ScrollView(.horizontal) {
            HStack {
                Button {
                    if communityFilter == .any {
                        navigation.openSheet(.communityPicker(api: api) { community in
                            self.communityFilter = .community(community)
                        })
                    } else {
                        self.communityFilter = .any
                    }
                } label: {
                    Label(communityFilter.label, systemImage: Icons.community)
                }
                .buttonStyle(
                    .feedFilter(
                        isOn: communityFilter != .any,
                        systemImage: communityFilter == .any ? Icons.dropDownCircleFill : Icons.closeCircleFill
                    )
                )
                typeFilterView()
                    .buttonStyle(.feedFilter(isOn: actionTypeFilter != nil))
            }
            .padding(.horizontal, Constants.main.standardSpacing)
        }
    }
    
    @ViewBuilder
    func typeFilterView() -> some View {
        Menu(
            String(localized: actionTypeFilter?.label ?? "Action Type"),
            systemImage: actionTypeFilter?.systemImage ?? Icons.action
        ) {
            Section {
                Toggle(
                    "Any",
                    systemImage: Icons.action,
                    isOn: .init(get: { actionTypeFilter == nil }, set: { _ in actionTypeFilter = nil })
                )
            }
            Section {
                Picker("Post", systemImage: Icons.posts, selection: $actionTypeFilter) {
                    typeFilterLabel(.modRemovePost)
                    typeFilterLabel(.modLockPost)
                    typeFilterLabel(.modFeaturePost)
                    typeFilterLabel(.adminPurgePost)
                }
                Picker("Comment", systemImage: Icons.replies, selection: $actionTypeFilter) {
                    typeFilterLabel(.modRemoveComment)
                    typeFilterLabel(.adminPurgeComment)
                }
                Picker("Community", systemImage: Icons.community, selection: $actionTypeFilter) {
                    typeFilterLabel(.modRemoveCommunity)
                    typeFilterLabel(.modHideCommunity)
                    typeFilterLabel(.modAddCommunity)
                    typeFilterLabel(.modTransferCommunity)
                    typeFilterLabel(.adminPurgeCommunity)
                }
                Picker("User", systemImage: Icons.person, selection: $actionTypeFilter) {
                    typeFilterLabel(.modBan)
                    typeFilterLabel(.modBanFromCommunity)
                    typeFilterLabel(.modAddCommunity)
                    typeFilterLabel(.modAdd)
                    typeFilterLabel(.adminPurgePerson)
                }
            }
        }
        .pickerStyle(.menu)
    }
    
    @ViewBuilder
    func typeFilterLabel(_ type: ApiModlogActionType) -> some View {
        if type.appliesToCommunity || communityFilter == .any {
            Label(String(localized: type.contextualLabel), systemImage: type.systemImage)
                .tag(type)
        }
    }
}
