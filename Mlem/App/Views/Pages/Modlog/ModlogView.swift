//
//  ModlogView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-25.
//

import MlemMiddleware
import SwiftUI

struct ModlogView: View {
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    
    @Setting(\.showModlogWarning) var showModlogWarning
    
    let initialTarget: InitialTarget
    
    @State var feedLoader: ModlogFeedLoader
    @State var warningPresented: Bool = Settings.main.showModlogWarning
    @State var targetFilter: TargetFilter?
    
    init(initialTarget: InitialTarget) {
        self._feedLoader = .init(
            wrappedValue: .init(
                api: AppState.main.firstApi,
                pageSize: Settings.main.internetSpeed.pageSize,
                communityId: nil,
                sortType: .new
            )
        )
        self.initialTarget = initialTarget
        switch initialTarget {
        case let .community(community):
            if let community = community.wrappedValue as? any Community {
                self._targetFilter = .init(wrappedValue: .community(community))
            }
        case let .instance(instance):
            if let instance = instance.wrappedValue as? any Instance3Providing {
                self._targetFilter = .init(wrappedValue: .instance(instance.instance3.instanceSummary))
            }
        }
    }
    
    var body: some View {
        Group {
            switch initialTarget {
            case let .community(initialCommunity):
                ContentLoader(model: initialCommunity) { proxy in
                    Group {
                        if let targetFilter {
                            content(targetFilter: targetFilter)
                        } else {
                            ProgressView()
                                .onAppear {
                                    if targetFilter == nil, let community = proxy.entity {
                                        targetFilter = .community(community)
                                    }
                                }
                        }
                    }
                }
            case let .instance(instanceHashWrapper):
                if let targetFilter {
                    content(targetFilter: targetFilter)
                } else {
                    ProgressView()
                        .onAppear {
                            if targetFilter == nil {
                                Task { @MainActor in
                                    let instance = try await instanceHashWrapper.wrappedValue.upgradeLocal()
                                    targetFilter = .instance(instance.instanceSummary)
                                }
                            }
                        }
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
        .onChange(of: targetFilter, initial: true) { oldValue, newValue in
            // This prevents the feed from refreshing when changing tabs
            guard oldValue != newValue || (feedLoader.loadingState == .loading && feedLoader.items.isEmpty) else {
                return
            }
            if let targetFilter {
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
    func content(targetFilter: TargetFilter) -> some View {
        ScrollView {
            filtersView(targetFilter: targetFilter)
            LazyVStack(spacing: Constants.main.standardSpacing) {
                ForEach(Array(feedLoader.items.enumerated()), id: \.offset) { _, entry in
                    ModlogEntryView(entry: entry, targetCommunity: targetFilter.communityValue)
                        .onAppear {
                            do {
                                try feedLoader.loadIfThreshold(entry)
                            } catch {
                                handleError(error)
                            }
                        }
                }
                EndOfFeedView(loadingState: feedLoader.loadingState, loadMore: nil, viewType: .hobbit)
            }
            .padding([.horizontal, .bottom], Constants.main.standardSpacing)
        }
        .background(palette.groupedBackground)
    }
    
    @ViewBuilder
    func filtersView(targetFilter: TargetFilter) -> some View {
        ScrollView(.horizontal) {
            HStack {
                LocationPicker(
                    filter: .init(get: { targetFilter }, set: { self.targetFilter = $0 })
                )
                .buttonStyle(.feedFilter(isOn: locationFilterIsOn))
            }
            .padding(.horizontal, Constants.main.standardSpacing)
        }
    }
    
    var locationFilterIsOn: Bool {
        guard let targetFilter else { return false }
        switch targetFilter {
        case let .community(community):
            return initialTarget.communityValue?.actorId == community.actorId
        case let .instance(instanceSummary):
            return initialTarget.instanceValue?.host == instanceSummary.host
        }
    }
}
