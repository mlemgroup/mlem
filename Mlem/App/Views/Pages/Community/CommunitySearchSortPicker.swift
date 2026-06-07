//
//  CommunitySearchSortPicker.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-12.
//

import MlemMiddleware
import SwiftUI

struct CommunitySearchSortPicker: View {
    @Environment(AppState.self) var appState

    var basicSortTypes: [CommunitySortType] {
        CommunitySortType.basicCases
            .filter {
                appState.firstApi.supports(.communitySortType($0), defaultValue: true)
            }
    }
    
    @Binding var sort: CommunitySortType
    
    var body: some View {
        Menu(sort.label, icon: sort.icon) {
            ForEach(basicSortTypes, id: \.self) { type in
                toggle(sort: type) {
                    Label(type.label, icon: type.icon)
                }
            }
            if appState.firstApi.supports(.communitySortType(.name(.ascending)), defaultValue: true) {
                Menu("Name", icon: .lemmy.alphabeticalSort) {
                    toggle(sort: .name(.ascending)) {
                        Text("A-Z")
                    }
                    toggle(sort: .name(.descending)) {
                        Text("Z-A")
                    }
                }
            }
            if appState.firstApi.supports(.communitySortType(.activeUserCount(.day)), defaultValue: true) {
                Menu("Active Users", icon: .lemmy.usersSort) {
                    ForEach(ActiveUserTimeRange.allCases, id: \.self) { type in
                        toggle(sort: .activeUserCount(type)) {
                            Label(type.label, icon: .lemmy.usersSort)
                        }
                    }
                }
            }
            if appState.firstApi.supports(.communitySortType(.federationDate(.ascending)), defaultValue: true) {
                Menu("Federated", icon: .lemmy.federation) {
                    toggle(sort: .federationDate(.descending)) {
                        Text("Newest")
                    }
                    toggle(sort: .federationDate(.ascending)) {
                        Text("Oldest")
                    }
                }
            }
        }
    }

    @ViewBuilder
    func toggle(
        sort: CommunitySortType,
        @ViewBuilder _ label: @escaping () -> some View
    ) -> some View {
        Toggle(
            isOn: .init(
                get: { self.sort == sort },
                set: { _ in self.sort = sort }
            ),
            label: label
        )
    }
}
