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
    @Environment(\.self) var environment

    let configurationKeyPathGenerator: (EnvironmentValues) -> ReferenceWritableKeyPath<SettingsValues, Configuration>
    let createAction: (ActionSeed) -> (any Actions.Action)?
    let customizable: Bool

    init(
        customizable: Bool = true,
        configuration keyPathGenerator: @escaping (EnvironmentValues) -> ReferenceWritableKeyPath<SettingsValues, Configuration>,
        createAction: @escaping (ActionSeed) -> (any Actions.Action)?,
    ) {
        self.configurationKeyPathGenerator = keyPathGenerator
        self.customizable = customizable
        self.createAction = createAction
    }

    init(
        configuration keyPath: ReferenceWritableKeyPath<SettingsValues, Configuration>,
        customizable: Bool = true,
        createAction: @escaping (ActionSeed) -> (any Actions.Action)?,
    ) {
        self.configurationKeyPathGenerator = { _ in keyPath }
        self.customizable = customizable
        self.createAction = createAction
    }

    var configuration: Configuration {
        Settings.get(configurationKeyPathGenerator(environment))
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
                            navigation.openSheet(.actionSheet(sheetSections, configuration: configurationKeyPathGenerator(environment)))
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

extension ActionContextMenuViewModifier {
    init(
        entity: Any,
        customizable: Bool = true,
        configuration keyPathGenerator: @escaping (EnvironmentValues) -> ReferenceWritableKeyPath<SettingsValues, Configuration>
    ) {
        self.init(customizable: customizable, configuration: keyPathGenerator) { 
            $0.createAction(entity)
        }
    }
    init(
        entity: Any,
        configuration keyPath: ReferenceWritableKeyPath<SettingsValues, Configuration>,
        customizable: Bool = true
    ) {
        self.init(configuration: keyPath, customizable: customizable) { 
            $0.createAction(entity)
        }
    }
}
