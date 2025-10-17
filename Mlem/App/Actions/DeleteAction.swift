//
//  DeleteAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-17.
//

import Actions
import MlemMiddleware
import SwiftUI

struct DeleteAction: ConfigurableAction {
    let entity: any DeletableProviding
}

// MARK: - Configurability

extension ActionSeed {
    static let delete = ActionSeed("delete") { entity in
        switch entity {
        case let entity as any DeletableProviding: DeleteAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension DeleteAction {
    static let deleteLabel: ActionLabel = .init("Delete", icon: .general.delete, isDestructive: true)
    static let restoreLabel: ActionLabel = .init("Restore", icon: .lemmy.restore)
    
    static var label: ActionLabel { deleteLabel }

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        if entity.deleted {
            Self.restoreLabel.withVisibility(visibility)
        } else {
            Self.deleteLabel.withVisibility(visibility)
        }
    }
    
    private var visibility: ActionVisiblity {
        guard let myPersonId = entity.api.myPerson?.id else { return .hidden }
        return entity.isOwnContent(myPersonId: myPersonId) ? .enabled : .hidden
    }
}

// MARK: - Behavior

extension DeleteAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        entity.toggleDeleted()
    }
}
