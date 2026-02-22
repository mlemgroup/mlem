//
//  ContextMenuSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-02-22.
//

import Actions
import SwiftUI

private var sheetSections: [[ActionSeed]] {
    [
        [
            .upvote,
            .downvote,
            .save,
            .reply,
            .markRead,
            .selectText,
            .share,
            .report,
            .edit,
            .delete
        ],
        [
            .blockCreator,
            .copyAuthorName,
            .openCreatorModlog,
            .sendCreatorMessage
        ],
        [
            .banCreator,
            .purgeCreator
        ]
    ]
}

struct ContextMenuSettingsView: View {
    @State var selected: [ActionSeed] = []

    var body: some View {
        Form {
            ForEach(selected, id: \.key) { seed in
                Label(seed.label)
                    .foregroundStyle(seed.label.isDestructive ? .themedWarning : .themedPrimary)
            }
            ForEach(Array(sheetSections.enumerated()), id: \.offset) { _, seeds in
                drawerActionSectionView(seeds)
            }
        }
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
