//
//  BlockListView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-11-09.
//

import Actions
import Haptics
import MlemBackend
import MlemMiddleware
import SwiftUI
import Theming

struct BlockListView: View {
    @Environment(AppState.self) var appState
    @Environment(HapticManager.self) var hapticManager
    
    enum Tab: CaseIterable, Identifiable {
        case people, communities, instances
        
        var id: Self { self }
        
        var label: LocalizedStringResource {
            switch self {
            case .people: "Users"
            case .communities: "Communities"
            case .instances: "Instances"
            }
        }
    }

    enum InstanceInfo {
        case stubs([InstanceStub])
        case summaries([InstanceSummary])
    }
    
    @State var selectedTab: Tab = .people
    @State var people: [Person] = []
    @State var communities: [Community] = []
    @State var instances: InstanceInfo = .stubs([])

    @State var isEditing: Bool = false
    
    var body: some View {
        FancyScrollView {
            BubblePicker(Tab.allCases, selected: $selectedTab, label: \.label, value: { tab in
                guard let blockList = (appState.firstSession as? UserSession)?.blocks else { return 0 }
                switch tab {
                case .people:
                    return blockList.personCount
                case .communities:
                    return blockList.communityCount
                case .instances:
                    return blockList.instanceCount
                }
            })
            switch selectedTab {
            case .people:
                SearchResultsView(results: people.filter(\.blocked_.realizedValue)) { person in
                    deleteButton(entity: person) {
                        PersonListRow(person, showBlockStatus: false)
                    }
                }
            case .communities:
                SearchResultsView(results: communities.filter(\.blocked_.realizedValue)) { community in
                    deleteButton(entity: community) {
                        CommunityListRow(community, showBlockStatus: false)
                    }
                }
            case .instances:
                instancesView
            }
        }
        .themedGroupedBackground()
        .toolbar {
            Button(isEditing ? "Done" : "Edit") {
                isEditing.toggle()
            }
        }
        .onAppear {
            Task { @MainActor in
                await refresh()
            }
        }
        .navigationTitle("Block List")
    }

    @ViewBuilder
    var instancesView: some View {
        switch instances {
        case let .stubs(stubs):
            ForEach(stubs.filter { $0.blocked.realizedValue }, id: \.self) { instance in
                deleteButton(entity: instance) {
                    InstanceRow(instance: instance)
                }
                .padding(.horizontal, Constants.main.standardSpacing)
                .padding(.bottom, Constants.main.halfSpacing)
            }
        case let .summaries(summaries):
            SearchResultsView(results: summaries.filter { $0.blocked.realizedValue }) { instance in
                deleteButton(entity: instance) {
                    InstanceListRow(instance, showBlockStatus: false)
                }
            }
        }
    }

    @ViewBuilder
    func deleteButton(
        entity: any Blockable,
        @ViewBuilder content: () -> some View
    ) -> some View {
        HStack {
            content()
            if isEditing {
                Button("Unblock", icon: .lemmy.unblock) {
                    withAnimation {
                        if entity is any InstanceActionProviding, let session = (appState.firstSession as? UserSession) {
                            session.updateInstanceBlock(actorId: entity.actorId, shouldBlock: false) 
                        } else {
                            entity.updateBlocked?(false, nil)
                        }
                        hapticManager.play(haptic: .lightSuccess, tier: .low)
                    }
                }
                .labelStyle(.iconOnly)
                .foregroundStyle(.themedNegative)
                .padding(.horizontal, Constants.main.halfSpacing)
            }
        }
        .animation(.default, value: isEditing)
    }

    func refresh() async {
        do {
            let result = try await appState.firstApi.getBlocked()
            people = result.people
            communities = result.communities
            if let summaries = MlemStats.main.findInstances(stubs: result.instances) {
                instances = .summaries(summaries)
            } else {
                instances = .stubs(result.instances)
            }
        } catch {
            handleError(error)
        }
    }
}

private struct InstanceRow: View {
    @Environment(NavigationLayer.self) var navigation

    let instance: InstanceStub

    var body: some View {
        Text(instance.actorId.host)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
            .contextMenu(instance: instance)
            .onTapGesture {
                navigation.push(.instanceStub(instance))
            }
    }
} 
