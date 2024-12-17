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
    
    @Binding var sort: ApiSortType
    
    @State var topSortPopupPresented: Bool = false

    var sortTypes: [ApiSortType] {
        ApiSortType.communitySearchCases
            .filter { (appState.firstApi.fetchedVersion ?? .infinity) >= $0.minimumVersion }
    }
    
    var body: some View {
        Menu(sort.label(topFormat: .topAndTimescale), systemImage: sort.systemImage) {
            ForEach(sortTypes, id: \.self) { type in
                Toggle(
                    type.label(),
                    systemImage: type.systemImage,
                    isOn: .init(get: { sort == type }, set: { _ in sort = type })
                )
            }
            Toggle(
                "Top...",
                systemImage: Icons.topSort,
                isOn: .init(get: { ApiSortType.topCases.contains(sort) }, set: { _ in topSortPopupPresented = true })
            )
        }
        .popover(isPresented: $topSortPopupPresented) {
            TopSortPicker(selected: $sort, includeAll: true)
                .presentationBackground(.clear)
                .presentationCornerRadius(18)
                .presentationCompactAdaptation(.popover)
        }
    }
}
