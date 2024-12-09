//
//  AdvancedSortView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-08.
//

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
    
    @Environment(Palette.self) var palette

    @State var selectedTab: Tab = .sort
    @State var pinnedSortTypes: Set<ApiSortType> = []
    @Binding var selectedSort: ApiSortType
    
    var body: some View {
        VStack {
            switch selectedTab {
            case .sort: sortTab
            case .filter: filterTab
            }
        }
        .background(palette.groupedBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Tab", selection: $selectedTab) {
                    ForEach(Tab.allCases, id: \.self) {
                        Text($0.label)
                    }
                }
                .frame(maxWidth: .infinity)
                .pickerStyle(.segmented)
            }
        }
    }
    
    @ViewBuilder
    var sortTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                ForEach(ApiSortType.nonTopCases, id: \.self) { type in
                    SortButton(type: type, selectedSort: $selectedSort, pinnedSortTypes: $pinnedSortTypes)
                }
                Text("Top of...")
                    .foregroundStyle(.secondary)
                    .fontWeight(.semibold)
                    .padding(.leading, Constants.main.standardSpacing)
                    .padding(.top, Constants.main.standardSpacing)
                ForEach(ApiSortType.topCases, id: \.self) { type in
                    SortButton(type: type, selectedSort: $selectedSort, pinnedSortTypes: $pinnedSortTypes)
                }
            }
            .padding(.horizontal, 15)
        }
    }
    
    @ViewBuilder
    var filterTab: some View {
        Text("Filter")
    }
}

private struct SortButton: View {
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss

    let type: ApiSortType

    @Binding var selectedSort: ApiSortType
    @Binding var pinnedSortTypes: Set<ApiSortType>
    
    @State var showingExplanation: Bool = false
    
    var body: some View {
        HStack(spacing: Constants.main.standardSpacing) {
            Button {
                selectedSort = type
                dismiss()
            } label: {
                HStack(spacing: Constants.main.standardSpacing) {
                    Image(systemName: type.systemImage)
                        .frame(width: 30, alignment: .center)
                        .foregroundStyle(palette.secondary)
                    Text(type.label)
                    if let explanation = type.explanation {
                        Button {
                            showingExplanation.toggle()
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .foregroundStyle(palette.secondary)
                                .foregroundStyle(palette.primary)
                        }
                        .popover(isPresented: $showingExplanation) {
                            Text(explanation)
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.footnote)
                                .frame(maxWidth: 200)
                                .padding(10)
                                .presentationCompactAdaptation(.popover)
                        }
                    }
                    Spacer()
                    if selectedSort == type {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                            .foregroundStyle(palette.accent)
                            .padding(.trailing, Constants.main.halfSpacing)
                    }
                }
                .foregroundStyle(palette.primary)
                .buttonStyle(.plain)
                .padding(.horizontal, Constants.main.standardSpacing)
                .frame(height: 45)
                .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
                .paletteBorder(cornerRadius: Constants.main.standardSpacing)
            }
            Button("Pin", systemImage: pinnedSortTypes.contains(type) ? Icons.pinFill : Icons.pin) {
                HapticManager.main.play(haptic: .gentleInfo, priority: .low)
                if pinnedSortTypes.contains(type) {
                    pinnedSortTypes.remove(type)
                } else {
                    pinnedSortTypes.insert(type)
                }
            }
            .labelStyle(.iconOnly)
            .padding(.horizontal, Constants.main.standardSpacing)
            .frame(height: 45)
            .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
            .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        }
    }
}
