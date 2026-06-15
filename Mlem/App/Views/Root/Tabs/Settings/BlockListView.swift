//
//  BlockListView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-11-09.
//

import MlemMiddleware
import SwiftUI
import Theming

struct BlockListView: View {
    @Environment(AppState.self) var appState
    
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
    
    @State var selectedTab: Tab = .people
    @State var people: [Person] = []
    @State var communities: [Community] = []
    @State var instances: [InstanceStub] = []
    
    var body: some View {
        FancyScrollView {
            BubblePicker(availableTabs, selected: $selectedTab, label: \.label, value: { tab in
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
                    PersonListRow(person, showBlockStatus: false)
                }
            case .communities:
                SearchResultsView(results: communities.filter(\.blocked_.realizedValue)) { community in
                    CommunityListRow(community, showBlockStatus: false)
                }
            case .instances:
                ForEach(instances.filter { $0.blocked.realizedValue }, id: \.self) { instance in
                    InstanceRow(instance: instance)
                        .padding(.horizontal, Constants.main.standardSpacing)
                        .padding(.bottom, Constants.main.halfSpacing)
                }
            }
        }
        .themedGroupedBackground()
        .onAppear {
            Task { @MainActor in
                do {
                    let result = try await appState.firstApi.getBlocked()
                    people = result.people
                    communities = result.communities
                    instances = result.instances
                } catch {
                    handleError(error)
                }
            }
        }
        .navigationTitle("Block List")
    }
    
    var availableTabs: [Tab] {
        var output: [Tab] = [.people, .communities]
        if appState.firstApi.supports(.viewInstanceBlockList, defaultValue: false) {
            output.append(.instances)
        }
        return output
    }
}

private struct InstanceRow: View {
    let instance: InstanceStub

    var body: some View {
        Text(instance.actorId.host)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
            .contextMenu(instance: instance)
    }
} 
