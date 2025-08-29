//
//  AdvancedSortView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-08.
//

import ComponentViews
import MlemMiddleware
import SwiftUI

struct AdvancedSortView: View {
    enum Tab: CaseIterable {
        case sort, filter
        
        var label: LocalizedStringResource {
            switch self {
            case .sort: "Sort"
            case .filter: "Filter"
            }
        }
    }
    
    @Environment(AppState.self) var appState

    @State var selectedTab: Tab = .sort
    @Binding var selectedSort: PostSortType
    
    var body: some View {
        VStack {
            switch selectedTab {
            case .sort: sortTab
            case .filter: filterTab
            }
        }
        .background(.themedGroupedBackground)
        .presentationBackground(.themedGroupedBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CloseButtonView()
            }
//            Intentionally left commented out!
//
//            ToolbarItem(placement: .principal) {
//                Picker("Tab", selection: $selectedTab) {
//                    ForEach(Tab.allCases, id: \.self) {
//                        Text($0.label)
//                    }
//                }
//                .frame(maxWidth: .infinity)
//                .pickerStyle(.segmented)
//            }
        }
    }
    
    @ViewBuilder
    var sortTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                ForEach(nonTopCases, id: \.self) { type in
                    SortButton(type: type, selectedSort: $selectedSort)
                }
                subtitle("Top of...")
                ForEach(topCases, id: \.self) { type in
                    SortButton(type: type, selectedSort: $selectedSort)
                }
                let unavailableCases = unavailableCases
                if !unavailableCases.isEmpty {
                    subtitle("Unavailable")
                    ForEach(unavailableCases, id: \.self) { type in
                        SortButton(type: type, timeRangeFormat: .topAndTimescale, selectedSort: $selectedSort)
                    }
                }
            }
            .padding(.horizontal, 15)
        }
    }
    
    @ViewBuilder
    func subtitle(_ title: LocalizedStringResource) -> some View {
        Text(title)
            .foregroundStyle(.secondary)
            .fontWeight(.semibold)
            .padding(.leading, Constants.main.standardSpacing)
            .padding(.top, Constants.main.standardSpacing)
    }
    
    @ViewBuilder
    var filterTab: some View {
        Text("Filter")
    }
    
    var nonTopCases: [PostSortType] {
        PostSortType.nonTopCases.filter { appState.firstApi.supportsOrElse(.postSortType($0), defaultValue: true) }
    }
    
    var topCases: [PostSortType] {
        PostSortType.legacyTopCases.filter { appState.firstApi.supportsOrElse(.postSortType($0), defaultValue: true) }
    }
    
    var unavailableCases: [PostSortType] {
        PostSortType.legacyCases.filter { !(appState.firstApi.supportsOrElse(.postSortType($0), defaultValue: true)) }
    }
}
