//
//  ModlogView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-25.
//

import ComponentViews
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
    @State var targetPersonFilter: PersonFilter = .any
    @State var moderatorPersonFilter: PersonFilter = .any
    @State var actionTypeFilter: ModlogEntryType?
    
    init(
        initialTarget: InitialTarget,
        targetPerson: Person?,
        moderatorPerson: Person?
    ) {
        self._feedLoader = .init(
            wrappedValue: .init(
                api: AppState.main.firstApi,
                pageSize: Settings.get(\.behavior_internetSpeed).pageSize,
                communityId: nil,
                targetPersonId: nil,
                moderatorPersonId: nil,
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
        case .currentInstance:
            self._communityFilter = .init(wrappedValue: .any)
            self.api = AppState.main.firstApi
        }
        if let person = targetPerson {
            self._targetPersonFilter = .init(wrappedValue: .person(person))
        }
        if let person = moderatorPerson {
            self._moderatorPersonFilter = .init(wrappedValue: .person(person))
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
            case .instance, .currentInstance:
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
        .toolbar {
            if navigation.isInsideSheet {
                CloseButtonToolbarItem(ios18Label: .xmark)
            }
        }
        .onChange(of: refreshHashValue, initial: true) { oldValue, newValue in
            // This prevents the feed from refreshing when changing tabs
            guard oldValue != newValue || feedLoader.loadingState == .initial else {
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
}
