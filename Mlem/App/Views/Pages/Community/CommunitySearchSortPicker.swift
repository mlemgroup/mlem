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

    var sortTypes: [CommunitySortType] {
        CommunitySortType.allCases
            .filter { appState.firstApi.supports(.communitySortType($0), defaultValue: true) }
    }
    
    @Binding var sort: CommunitySortType
    
    var body: some View {
        Menu(sort.label, icon: sort.icon) {
            ForEach(sortTypes, id: \.self) { type in
                Toggle(
                    type.label,
                    icon: type.icon,
                    isOn: .init(get: { sort == type }, set: { _ in sort = type })
                )
            }
        }
    }
}
