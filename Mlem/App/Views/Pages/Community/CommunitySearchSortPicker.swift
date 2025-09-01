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
    
    @Binding var sort: SearchSortType
    
    @State var topSortPopupPresented: Bool = false

    var sortTypes: [SearchSortType] {
        SearchSortType.nonTopCases
            .filter { appState.firstApi.supports(.searchSortType($0), defaultValue: true) }
    }
    
    var body: some View {
        Menu(sort.label(timeRangeFormat: .topAndTimescale), icon: sort.icon) {
            ForEach(sortTypes, id: \.self) { type in
                Toggle(
                    type.label(),
                    icon: type.icon,
                    isOn: .init(get: { sort == type }, set: { _ in sort = type })
                )
            }
            Toggle(
                "Top...",
                icon: .lemmy.topSort,
                isOn: .init(get: { sort.isTop }, set: { _ in topSortPopupPresented = true })
            )
        }
        .popover(isPresented: $topSortPopupPresented) {
            TopSortPicker(action: { sort = .top($0) })
                .presentationBackground(.clear)
                .presentationCornerRadius(18)
                .presentationCompactAdaptation(.popover)
        }
    }
}
