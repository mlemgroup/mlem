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
            VStack(spacing: Constants.main.standardSpacing) {
                ForEach(ApiSortType.nonTopCases, id: \.self) { type in
                    HStack(spacing: Constants.main.standardSpacing) {
                        HStack(spacing: Constants.main.standardSpacing) {
                            Image(systemName: type.systemImage)
                                .frame(width: 30, alignment: .center)
                                .foregroundStyle(.secondary)
                            Text(type.label)
                            Spacer()
                        }
                        .padding(.horizontal, Constants.main.standardSpacing)
                        .frame(height: 45)
                        .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
                        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
                        Button("Pin", systemImage: Icons.pin) {}
                            .labelStyle(.iconOnly)
                            .padding(.horizontal, Constants.main.standardSpacing)
                            .frame(height: 45)
                            .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
                            .paletteBorder(cornerRadius: Constants.main.standardSpacing)
                    }
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
