//
//  ContextMenu+Person.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-17.
//

import Actions
import MlemMiddleware
import SwiftUI

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
            ActionButtons(person: person)
        }
    }
}
