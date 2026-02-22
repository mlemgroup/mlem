//
//  ContextMenuSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-02-22.
//

import ComponentViews
import Actions
import SwiftUI

struct ContextMenuSettingsView: View {
    @State var selected: [ActionSeed] = []

    var body: some View {
        Form {
            ForEach(selected, id: \.key) { seed in
                Label(seed.label)
                    .foregroundStyle(seed.label.isDestructive ? .themedWarning : .themedPrimary)
            }
            .onMove { fromOffsets, toOffset in
                selected.move(fromOffsets: fromOffsets, toOffset: toOffset)
            }
            .onDelete { offsets in
                selected.remove(atOffsets: offsets)
            }
            ForEach(Array(ReplyBarConfiguration.availableActions.enumerated()), id: \.offset) { _, seeds in
                drawerActionSectionView(seeds)
            }
        }
        .toolbar {
            CloseButtonToolbarItem(ios18Label: .xmark)
        }
        .navigationTitle("Customize Context Menu")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.editMode, .constant(.active))
    }

    @ViewBuilder
    func drawerActionSectionView(_ seeds: [ActionSeed]) -> some View {
        Section {
            ForEach(seeds, id: \.key, content: drawerActionRowView)
        }
    }

    @ViewBuilder
    func drawerActionRowView(_ seed: ActionSeed) -> some View {
        Button {
            withAnimation {
                selected.append(seed)
            }
        } label: {
            HStack {
                Label(seed.label)
                    .foregroundStyle(seed.label.isDestructive ? .themedWarning : .themedPrimary)
                Spacer()
                if !selected.contains(seed) {
                    Image(icon: .general.add)
                        .symbolVariant(.circle.fill)
                        .foregroundStyle(.themedAccent)
                        .imageScale(.large)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(selected.contains(seed))
    }
}
