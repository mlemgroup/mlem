//
//  EditNoteAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-12-13.
//

import Actions
import MlemMiddleware
import SwiftUI

struct EditNoteAction: SimpleLabelAction {
    let entity: any Person1Providing
}

// MARK: - Configurability

extension ActionSeed {
    static let editNote = ActionSeed("editNote") { entity in
        switch entity {
        case let entity as any Person1Providing: EditNoteAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension EditNoteAction {
    static let label: ActionLabel = .init("Edit Note", icon: .lemmy.editNote)

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        Self.label.withVisibility(entity.api.supports(.userNotes, defaultValue: false) ? .enabled : .hidden)
    }
}

// MARK: - Behavior

extension EditNoteAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
    }
}
