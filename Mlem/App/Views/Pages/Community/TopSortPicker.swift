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
    
    var action: (SortTimeRange) -> Void
    var filter: (SortTimeRange) -> Bool = { _ in true }
    
    var timeRanges: [SortTimeRange] {
        SortTimeRange.legacyCases
            .filter(filter)
            .filter { (appState.firstApi.fetchedVersion ?? .infinity) >= $0.minimumVersion }
    }
    
    var body: some View {
        HFlow(spacing: 10, justification: .stretchItems) {
            ForEach(timeRanges, id: \.self) { type in
                button(type)
                    .frame(minWidth: 60)
            }
        }
        .padding(10)
        .frame(width: 222)
    }
    
    @ViewBuilder
    func button(_ type: SortTimeRange) -> some View {
        Button {
            action(type)
            dismiss()
        } label: {
            Group {
                if type == .allTime {
                    if timeRanges.count % 3 == 0 {
                        Text("All")
                    } else {
                        Text("All Time")
                    }
                } else {
                    Text(type.label(prefix: "Top", format: .timescaleAbbreviated))
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
