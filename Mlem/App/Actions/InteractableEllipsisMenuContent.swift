//
//  InteractableEllipsisMenuContent.swift
//  Mlem
//
//  Created by Sjmarf on 2026-04-03.
//

import Actions
import MlemMiddleware
import SwiftUI

struct InteractableEllipsisMenuContent<Configuration: ContextMenuConfiguration>: View {
    @Environment(\.reportContext) var reportContext: Report?

    enum ActionListType {
        case basic, moderator
    }

    let entity: Any
    let configuration: Configuration
    let type: Set<ActionListType>

    var body: some View {
        Group {
            if type.contains(.basic) {
                Section {
                    ActionButtons { _ in
                        self.actions(type: .basic)
                    }
                }
            }
            if type.contains(.moderator) {
                Section {
                    ActionButtons { _ in
                        var ret = configuration.contextMenu
                            .filter(\.isModeratorAction)
                            .compactMap { $0.createAction(entity) }
                        if let reportContext,
                            let resolveAction = ActionSeed.resolveReport.createAction(reportContext) {
                            ret.append(resolveAction)
                        }
                        return ret
                    }
                }
            }
        }
        .environment(\.isContextMenu, true)
    }

    func actions(type: ActionListType) -> [any Actions.Action] {
        return configuration.contextMenu
            .filter { self.actionSeedHasType($0, type: type) }
            .compactMap { seed in
                if let report = reportContext {
                    if let action = seed.createAction(report) {
                        return action
                    }
                }
                return seed.createAction(entity)
            }
    }

    func actionSeedHasType(_ seed: ActionSeed, type: ActionListType) -> Bool {
        switch type {
        case .basic: seed.isBasicAction
        case .moderator: seed.isModeratorAction
        }
    }
}

extension InteractableEllipsisMenuContent {
    init(
        entity: Any,
        configuration keyPath: ReferenceWritableKeyPath<SettingsValues, Configuration>,
        type: Set<ActionListType>
    ) {
        self.init(
            entity: entity,
            configuration: Settings.get(keyPath),
            type: type
        )
    }
}
