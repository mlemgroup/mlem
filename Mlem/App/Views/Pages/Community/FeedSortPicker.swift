//
//  FeedSortPicker.swift
//  Mlem
//
//  Created by Sjmarf on 10/08/2024.
//

import Flow
import MlemMiddleware
import SwiftUI

struct FeedSortPicker: View {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    
    let showTopTimescaleInIcon: Bool
    @Binding var sort: ApiSortType
    
    @State var topSortPopupPresented: Bool = false
    
    init(sort: Binding<ApiSortType>, showTopTimescaleInIcon: Bool = false) {
        self._sort = sort
        self.showTopTimescaleInIcon = showTopTimescaleInIcon
    }
    
    init(feedLoader: CorePostFeedLoader, showTopTimescaleInIcon: Bool = false) {
        self.init(sort: .init(get: { feedLoader.sortType }, set: { newSort in
            Task { @MainActor in
                do {
                    try await feedLoader.changeSortType(to: newSort, forceRefresh: false)
                } catch {
                    handleError(error)
                }
            }
        }), showTopTimescaleInIcon: showTopTimescaleInIcon)
    }
    
    var nonTopSortTypes: [ApiSortType] {
        ApiSortType.nonTopCases
            .filter { PinnedSortTracker.main.pinnedSortTypes.contains($0) }
            .filter { (appState.firstApi.fetchedVersion ?? .infinity) >= $0.minimumVersion }
    }
    
    var topSortTypes: [ApiSortType] {
        ApiSortType.topCases
            .filter { PinnedSortTracker.main.pinnedSortTypes.contains($0) }
            .filter { (appState.firstApi.fetchedVersion ?? .infinity) >= $0.minimumVersion }
    }
    
    var body: some View {
        Menu {
            Section {
                ForEach(nonTopSortTypes, id: \.self) { type in
                    Toggle(
                        type.label(),
                        systemImage: type.systemImage,
                        isOn: .init(get: { sort == type }, set: { _ in sort = type })
                    )
                }
                let topSortTypes = topSortTypes
                if topSortTypes.count > 3 {
                    Toggle(
                        "Top...",
                        systemImage: Icons.topSort,
                        isOn: .init(get: { ApiSortType.topCases.contains(sort) }, set: { _ in topSortPopupPresented = true })
                    )
                } else {
                    ForEach(topSortTypes, id: \.self) { type in
                        Toggle(
                            type.label(topFormat: .topAndTimescale),
                            systemImage: type.systemImage,
                            isOn: .init(get: { sort == type }, set: { _ in sort = type })
                        )
                    }
                }
            }
            Section {
                Button("More...", systemImage: Icons.menuCircle) {
                    navigation.openSheet(.advancedSorting($sort))
                }
            }
        } label: {
            if showTopTimescaleInIcon, ApiSortType.topCases.contains(sort) {
                HStack {
                    Image(systemName: Icons.topSort)
                        .imageScale(.small)
                    Text(sort.label(topFormat: .timescaleAbbreviated))
                        .font(.footnote)
                        .fontDesign(.rounded)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background {
                    Capsule()
                        // 1.51 is intentional - iOS doesn't render it quite right at 1.5 (iPhone 12)
                        .strokeBorder(palette.accent, lineWidth: 1.51)
                }
                .accessibilityLabel(sort.label(topFormat: .topAndTimescale))
            } else {
                Label(sort.label(topFormat: topSortTypes.count == 1 ? .topOnly : .topAndTimescale), systemImage: sort.systemImage)
            }
        }
        .disabled(appState.firstApi.fetchedVersion == nil)
        .popover(isPresented: $topSortPopupPresented) {
            TopSortPicker(selected: $sort)
                // This background is always drawn over a material background unfortunately,
                // meaning that we can't use thin materials
                .presentationBackground(.clear)
                .presentationCornerRadius(18)
                .presentationCompactAdaptation(.popover)
        }
    }
    
    var formatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        return formatter
    }
}
