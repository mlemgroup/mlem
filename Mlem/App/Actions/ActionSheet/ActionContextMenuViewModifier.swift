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

    var configuration: Configuration {
        Settings.get(configurationKeyPath)
    }

    func body(content: Content) -> some View {
        content
            .contextMenu {
                ActionButtons { _ in
                    self.createActions(seeds: configuration.contextMenu)
                }
                Section {
                    Button("More...", icon: .general.menu) {
                        navigation.openSheet(.actionSheet(sheetSections, configuration: configurationKeyPath))
                    }
                    .symbolVariant(.circle)
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
