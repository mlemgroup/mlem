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
    @Setting(\.interactionBar_reply) var replyBarConfiguration

    var body: some View {
        Form {
            ForEach(replyBarConfiguration.contextMenu, id: \.key) { seed in
                Label(seed.label)
                    .foregroundStyle(seed.label.isDestructive ? .themedWarning : .themedPrimary)
            }
            .onMove { fromOffsets, toOffset in
                replyBarConfiguration.contextMenu.move(fromOffsets: fromOffsets, toOffset: toOffset)
            }
            .onDelete { offsets in
                replyBarConfiguration.contextMenu.remove(atOffsets: offsets)
            }
            ForEach(Array(ReplyBarConfiguration.availableActions.sections.enumerated()), id: \.offset) { _, seeds in
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
                replyBarConfiguration.contextMenu.append(seed)
            }
        } label: {
            HStack {
                Label(seed.label)
                    .foregroundStyle(seed.label.isDestructive ? .themedWarning : .themedPrimary)
                Spacer()
                if !replyBarConfiguration.contextMenu.contains(seed) {
                    Image(icon: .general.add)
                        .symbolVariant(.circle.fill)
                        .foregroundStyle(.themedAccent)
                        .imageScale(.large)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(replyBarConfiguration.contextMenu.contains(seed))
    }
}
