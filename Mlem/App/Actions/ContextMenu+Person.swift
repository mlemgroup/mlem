//
//  ContextMenu+Person.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-17.
//

import Actions
import MlemMiddleware
import SwiftUI
import QuickSwipes

extension ActionButtons {
    init(person: Person) {
        self.init { _ in
            PersonActionConfiguration.availableActions.all.compactMap { $0.createAction(person) }
        }
    }
}

extension View {
    func contextMenu(person: Person) -> some View {
        contextMenu {
            CustomizableActionMenu(
                entity: person,
                configuration: \.interactionBar_person,
                customizable: true
            )
        }
    }

    @ViewBuilder
    func quickSwipes(person: Person, configuration: PersonActionConfiguration, leadingBuffer: SwipeBuffer) -> some View {
        quickSwipes(
            leading: configuration.swipes.leading.compactMap { $0.createAction(person) },
            trailing: configuration.swipes.trailing.compactMap { $0.createAction(person) },
            leadingBuffer: leadingBuffer
        )
    }
}
