//
//  FeedSortPicker+TopSortPicker.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-12.
//

import Flow
import MlemMiddleware
import SwiftUI

struct TopSortPicker: View {
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var selected: PostSortType
    var includeAll: Bool = false
    
    var sortTypes: [PostSortType] {
        PostSortType.legacyTopCases
            .filter { includeAll ? true : PinnedSortTracker.main.pinnedSortTypes.contains($0) }
            .filter { (appState.firstApi.fetchedVersion ?? .infinity) >= $0.minimumVersion }
    }
    
    var body: some View {
        HFlow(spacing: 10, justification: .stretchItems) {
            ForEach(sortTypes, id: \.self) { type in
                button(type)
                    .frame(minWidth: 60)
            }
        }
        .padding(10)
        .frame(width: 222)
    }
    
    @ViewBuilder
    func button(_ type: PostSortType) -> some View {
        Button {
            selected = type
            dismiss()
        } label: {
            Group {
                if type == .top(nil) {
                    if sortTypes.count % 3 == 0 {
                        Text("All")
                    } else {
                        Text("All Time")
                    }
                } else {
                    Text(type.label(topFormat: .timescaleAbbreviated))
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(.rect)
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
}
