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
    @State var people: [Person1] = []
    @State var communities: [Community1] = []
    @State var instances: [Instance1] = []
    
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
                SearchResultsView(results: people.filter(\.blocked)) { person in
                    PersonListRow(person, showBlockStatus: false)
                }
            case .communities:
                SearchResultsView(results: communities.filter(\.blocked)) { community in
                    CommunityListRow(community, showBlockStatus: false)
                }
            case .instances:
                SearchResultsView(results: instances.filter(\.blocked)) { instance in
                    InstanceListRow(instance)
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
}
