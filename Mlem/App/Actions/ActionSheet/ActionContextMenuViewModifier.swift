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
    let createAction: (ActionSeed, EnvironmentValues) -> (any Actions.Action)?
    let customizable: Bool

    fileprivate init(
        customizable: Bool = true,
        configuration keyPathGenerator: @escaping (EnvironmentValues) -> ReferenceWritableKeyPath<SettingsValues, Configuration>,
        createAction: @escaping (ActionSeed, EnvironmentValues) -> (any Actions.Action)?,
    ) {
        self.configurationKeyPathGenerator = keyPathGenerator
        self.customizable = customizable
        self.createAction = createAction
    }

    init(
        configuration keyPath: ReferenceWritableKeyPath<SettingsValues, Configuration>,
        customizable: Bool = true,
        createAction: @escaping (ActionSeed, EnvironmentValues) -> (any Actions.Action)?,
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
        seeds.compactMap { self.createAction($0, environment) }
    }
}

extension ActionContextMenuViewModifier {
    init(
        entity: Any,
        configuration keyPath: ReferenceWritableKeyPath<SettingsValues, Configuration>,
        customizable: Bool = true
    ) {
        self.init(configuration: keyPath, customizable: customizable) { seed, _ in
            seed.createAction(entity)
        }
    }

    init(
        entity: Any,
        configuration: ReferenceWritableKeyPath<SettingsValues, Configuration>,
        modMailConfiguration: ReferenceWritableKeyPath<SettingsValues, Configuration>,
        customizable: Bool = true
    ) {
        self.init(
        customizable: customizable,
        configuration: { environment in
            if environment.reportContext != nil && Settings.get(\.interactionBar_alternateReportLayout) {
                configuration
            } else {
                modMailConfiguration
            }
        },
        createAction: { seed, environment in
            if let report = environment.reportContext {
                if let action = seed.createAction(report) {
                    return action
                }
            }
            return seed.createAction(entity)
        })
    }
}
