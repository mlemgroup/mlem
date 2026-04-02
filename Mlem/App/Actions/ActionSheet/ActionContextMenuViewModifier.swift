//
//  ActionContextMenuViewModifier.swift
//  Mlem
//
//  Created by Sjmarf on 2026-04-02.
//

import Actions
import SwiftUI

struct ActionContextMenuViewModifier<Configuration: ContextMenuConfiguration>: ViewModifier {
    @Environment(NavigationLayer.self) var navigation

    let configurationKeyPath: ReferenceWritableKeyPath<SettingsValues, Configuration>
    let createAction: (ActionSeed) -> (any Actions.Action)?
    let customizable: Bool

    init(
        configuration keyPath: ReferenceWritableKeyPath<SettingsValues, Configuration>,
        customizable: Bool = true,
        createAction: @escaping (ActionSeed) -> (any Actions.Action)?,
    ) {
        self.configurationKeyPath = keyPath
        self.customizable = customizable
        self.createAction = createAction
    }

    var configuration: Configuration {
        Settings.get(configurationKeyPath)
    }

    func body(content: Content) -> some View {
        content
            .contextMenu {
                ActionButtons { _ in
                    self.createActions(seeds: configuration.contextMenu)
                }
                .environment(\.isContextMenu, true)
                if customizable {
                    Section {
                        Button("More...", icon: .general.menu) {
                            navigation.openSheet(.actionSheet(sheetSections, configuration: configurationKeyPath))
                        }
                        .symbolVariant(.circle)
                    }
                }
        }
    }

    var sheetSections: [ActionSheetSection] {
        ReplyBarConfiguration.availableActions.sections.map { seeds in
            .init(actions: self.createActions(seeds: seeds))
        }
    }

    func createActions(seeds: [ActionSeed]) -> [any Actions.Action] {
        seeds.compactMap(self.createAction)
    }
}
