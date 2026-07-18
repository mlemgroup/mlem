//
//  ContextMenuSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-02-22.
//

import ComponentViews
import Actions
import SwiftUI

struct ContextMenuSettingsView<Configuration: ContextMenuConfiguration>: View {
    @Environment(NavigationLayer.self) var navigation
    @Binding var configuration: [ActionSeed]

    var body: some View {
        Form {
            ForEach(configuration, id: \.key) { seed in
                Label(seed.label)
                    .foregroundStyle(seed.label.isDestructive ? .themedWarning : .themedPrimary)
            }
            .onMove { fromOffsets, toOffset in
                configuration.move(fromOffsets: fromOffsets, toOffset: toOffset)
            }
            .onDelete { offsets in
                configuration.remove(atOffsets: offsets)
            }
            ForEach(Array(Configuration.availableActions.sections.enumerated()), id: \.offset) { _, seeds in
                drawerActionSectionView(seeds)
            }
        }
        .toolbar {
            if navigation.isInsideSheet {
                CloseButtonToolbarItem()
            }
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
                configuration.append(seed)
            }
        } label: {
            HStack {
                Label(seed.label)
                    .foregroundStyle(seed.label.isDestructive ? .themedWarning : .themedPrimary)
                Spacer()
                if !configuration.contains(seed) {
                    Image(icon: .general.add)
                        .symbolVariant(.circle.fill)
                        .foregroundStyle(.themedAccent)
                        .imageScale(.large)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(configuration.contains(seed))
    }
}

extension ContextMenuSettingsView {
    init(_ keyPath: ReferenceWritableKeyPath<SettingsValues, Configuration>) {
        self.init(configuration: .init(get: {
            Settings.get(keyPath).contextMenu
        }, set: { newValue in
            Settings.mutate(keyPath) { $0.contextMenu = newValue }
        }))
    }
}
