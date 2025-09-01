//
//  FeedSortPicker.swift
//  Mlem
//
//  Created by Sjmarf on 10/08/2024.
//

import Flow
import Icons
import MlemMiddleware
import SwiftUI
import Theming

struct FeedSortPicker: View {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    
    enum Value: Hashable {
        case known(PostSortType)
        case unknown
        
        var sortType: PostSortType? {
            switch self {
            case let .known(postSortType): postSortType
            case .unknown: nil
            }
        }
    }
    
    let showTopTimescaleInIcon: Bool
    @Binding var value: Value
    
    @State var topSortPopupPresented: Bool = false
    
    init(sort: Binding<PostSortType>, showTopTimescaleInIcon: Bool = false) {
        self._value = .init(get: { .known(sort.wrappedValue) }, set: {
            if let sortType = $0.sortType {
                sort.wrappedValue = sortType
            } else {
                assertionFailure()
            }
        })
        self.showTopTimescaleInIcon = showTopTimescaleInIcon
    }
    
    init(feedLoader: CommunityPostFeedLoader?, showTopTimescaleInIcon: Bool = false) {
        self._value = .init(get: {
            if let feedLoader {
                .known(feedLoader.sortType)
            } else {
                .unknown
            }
        }, set: { value in
            if let sort = value.sortType {
                Task { @MainActor in
                    do {
                        try await feedLoader?.changeSortType(to: sort, forceRefresh: false)
                    } catch {
                        handleError(error)
                    }
                }
            }
        })
        self.showTopTimescaleInIcon = showTopTimescaleInIcon
    }

    init(feedLoader: AggregatePostFeedLoader?, showTopTimescaleInIcon: Bool = false) {
        self._value = .init(get: {
            if let feedLoader {
                .known(feedLoader.sortType)
            } else {
                .unknown
            }
        }, set: { value in
            if let sort = value.sortType {
                Task { @MainActor in
                    do {
                        try await feedLoader?.changeSortType(to: sort, forceRefresh: false)
                    } catch {
                        handleError(error)
                    }
                }
            }
        })
        self.showTopTimescaleInIcon = showTopTimescaleInIcon
    }

    var nonTopSortTypes: [PostSortType] {
        PostSortType.nonTopCases
            .filter { PinnedSortTracker.main.pinnedSortTypes.contains($0) }
            .filter { appState.firstApi.supports(.postSortType($0), defaultValue: true) }
    }
    
    var topSortTypes: [PostSortType] {
        PostSortType.legacyTopCases
            .filter { PinnedSortTracker.main.pinnedSortTypes.contains($0) }
            .filter { appState.firstApi.supports(.postSortType($0), defaultValue: true) }
    }
    
    var body: some View {
        Menu {
            Section {
                ForEach(nonTopSortTypes, id: \.self) { type in
                    Toggle(
                        type.label(),
                        icon: type.icon,
                        isOn: .init(get: { value.sortType == type }, set: { _ in value = .known(type) })
                    )
                }
                let topSortTypes = topSortTypes
                if topSortTypes.count > 3 {
                    Toggle(
                        "Top...",
                        icon: .lemmy.topSort,
                        isOn: .init(
                            get: {
                                if let sort = value.sortType {
                                    PostSortType.legacyTopCases.contains(sort)
                                } else {
                                    false
                                }
                            },
                            set: { _ in topSortPopupPresented = true }
                        )
                    )
                } else {
                    ForEach(topSortTypes, id: \.self) { type in
                        Toggle(
                            type.label(timeRangeFormat: .topAndTimescale),
                            icon: type.icon,
                            isOn: .init(get: { value.sortType == type }, set: { _ in value = .known(type) })
                        )
                    }
                }
            }
            Section {
                Button("More...", icon: .general.toolbarMenu) {
                    navigation.openSheet(.advancedSorting(.init(get: {
                        value.sortType ?? .hot
                    }, set: {
                        value = .known($0)
                    })))
                }
            }
        } label: {
            labelView
        }
        .disabled(!appState.firstApi.contextIsFetched)
        .popover(isPresented: $topSortPopupPresented) {
            TopSortPicker(
                action: { value = .known(.top($0)) },
                filter: { PinnedSortTracker.main.pinnedSortTypes.contains(.top($0)) }
            )
            // This background is always drawn over a material background unfortunately,
            // meaning that we can't use thin materials
            .presentationBackground(.clear)
            .presentationCornerRadius(18)
            .presentationCompactAdaptation(.popover)
        }
    }
    
    @ViewBuilder
    var labelView: some View {
        VStack {
            if showTopTimescaleInIcon, let sort = value.sortType, sort.isTop {
                HStack {
                    Image(icon: .lemmy.topSort)
                        .imageScale(.small)
                    Text(sort.label(timeRangeFormat: .timescaleAbbreviated))
                        .font(UIDevice.isIos26 ? .body : .footnote)
                        .fontDesign(.rounded)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background {
                    if !UIDevice.isIos26 {
                        Capsule()
                            // 1.51 is intentional - iOS doesn't render it quite right at 1.5 (iPhone 12)
                            .strokeBorder(.themedAccent, lineWidth: 1.51)
                    }
                }
                .accessibilityLabel(sort.label(timeRangeFormat: .topAndTimescale))
            } else if let sortType = value.sortType {
                Label(sortType.label(timeRangeFormat: topSortTypes.count == 1 ? .topOnly : .topAndTimescale), icon: sortType.icon)
            }
        }
        .animation(.easeOut(duration: 0.4), value: value == .unknown)
    }
    
    var formatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        return formatter
    }
}
