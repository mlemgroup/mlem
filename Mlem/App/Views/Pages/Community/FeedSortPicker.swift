//
//  FeedSortPicker.swift
//  Mlem
//
//  Created by Sjmarf on 10/08/2024.
//

import MlemMiddleware
import SwiftUI

struct FeedSortPicker: View {
    enum Filter {
        case alwaysAvailable, availableOnInstance, communitySearchable, personSearchable
    }
    
    @Environment(AppState.self) var appState
    
    let filters: Set<Filter>
    @Binding var sort: ApiSortType
    
    @State var topSortPopupPresented: Bool = false
    
    init(sort: Binding<ApiSortType>, filters: Set<Filter> = []) {
        self._sort = sort
        self.filters = filters
    }
    
    init(feedLoader: CorePostFeedLoader) {
        self.init(sort: .init(get: { feedLoader.sortType }, set: { newSort in
            Task { @MainActor in
                do {
                    try await feedLoader.changeSortType(to: newSort, forceRefresh: false)
                } catch {
                    handleError(error)
                }
            }
        }), filters: [.availableOnInstance])
    }
    
    var body: some View {
        let topModes = filterSortModes(ApiSortType.topCases)
        Menu(sort.fullLabel(shortTopMode: topModes.count == 1), systemImage: sort.systemImage) {
            Section("Sort by...") {
                Toggle(
                    "Hot",
                    systemImage: Icons.hotSort,
                    isOn: .init(get: { sort == .hot }, set: { _ in sort = .hot })
                )
                Toggle(
                    "New",
                    systemImage: Icons.newSort,
                    isOn: .init(get: { sort == .new }, set: { _ in sort = .new })
                )
                Toggle(
                    "Top...",
                    systemImage: Icons.topSort,
                    isOn: .init(get: { ApiSortType.topCases.contains(sort) }, set: { _ in topSortPopupPresented = true })
                )
            }
            Section("Filters") {
                Toggle("Show Read", systemImage: Icons.read, isOn: .constant(true))
                Toggle("Show Hidden", systemImage: Icons.hide, isOn: .constant(false))
            }
            Section {
                Button("More...", systemImage: Icons.menuCircle) {}
            }
        }
        .disabled(filters.contains(.availableOnInstance) && appState.firstApi.fetchedVersion == nil)
        .popover(isPresented: $topSortPopupPresented) {
            TopSortPicker(selected: $sort)
                // This background is always drawn over a material background unfortunately,
                // meaning that we can't use thin materials
                .presentationBackground(.clear)
                .presentationCornerRadius(18)
                .presentationCompactAdaptation(.popover)
        }
    }
    
    @ViewBuilder
    func itemLabels(_ collection: [ApiSortType]) -> some View {
        ForEach(collection, id: \.self) { item in
            Label(String(localized: item.label), systemImage: item.systemImage)
        }
    }
    
    private func filterSortModes(_ collection: any Collection<ApiSortType>) -> [ApiSortType] {
        collection.filter { sortType in
            filters.allSatisfy { filter in
                switch filter {
                case .alwaysAvailable: sortType.minimumVersion == .zero
                case .availableOnInstance:
                    (appState.firstApi.fetchedVersion ?? .infinity) >= sortType.minimumVersion
                case .communitySearchable:
                    ApiSortType.communitySearchCases.contains(sortType)
                case .personSearchable:
                    ApiSortType.personSearchCases.contains(sortType)
                }
            }
        }
    }
}

struct TopSortPicker: View {
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var selected: ApiSortType
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Choose Timeframe...")
                .font(.footnote)
                .foregroundStyle(palette.secondary)
                .fontWeight(.semibold)
            HStack(spacing: 10) {
                button(.topSixHour)
                button(.topDay)
                button(.topWeek)
            }
            HStack(spacing: 10) {
                button(.topMonth)
                button(.topYear)
                button(.topAll, label: "All")
            }
//            HStack(spacing: 10) {
//                button(.topHour)
//                button(.topSixHour)
//                button(.topTwelveHour)
//            }
//            HStack(spacing: 10) {
//                button(.topDay)
//                button(.topWeek)
//                button(.topMonth)
//            }
//            if (appState.firstSession.api.fetchedVersion ?? .infinity) >= .v18_1 {
//                HStack(spacing: 10) {
//                    button(.topThreeMonths)
//                    button(.topSixMonths)
//                    button(.topNineMonths)
//                }
//            }
//            HStack(spacing: 10) {
//                button(.topYear)
//                    .frame(width: 54)
//                button(.topAll, label: .init(localized: "All Time"))
//            }
        }
        .padding(10)
        .frame(width: 222)
    }
    
    @ViewBuilder
    func button(_ type: ApiSortType, label: String? = nil, systemImage: String? = nil) -> some View {
        Button {
            selected = type
            dismiss()
        } label: {
            if let systemImage {
                Label {
                    Text(label ?? "")
                } icon: {
                    Image(systemName: systemImage)
                        .imageScale(.small)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text(label ?? formatter.string(from: type.dateComponents ?? .init()) ?? "")
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .background {
            if colorScheme == .dark {
                RoundedRectangle(cornerRadius: 8)
                    .fill(palette.primary.opacity(0.2))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(palette.background)
                    .shadow(color: .black.opacity(0.05), radius: 3)
            }
        }
        .foregroundStyle(palette.primary)
    }
    
    var formatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        return formatter
    }
}
