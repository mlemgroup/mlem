//
//  SelectTextAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-13.
//

import Actions
import MlemMiddleware
import SwiftUI

struct SelectTextAction: Actions.SimpleLabelAction {
    static let label: ActionLabel = .init("Select Text", icon: .general.select)
    
    let text: String
    
    func execute(environment: EnvironmentValues) {
        environment.navigation?.openSheet(.selectText(text))
    }
}

extension ActionSeed {
    static let selectText = ActionSeed("selectText") { entity in
        switch entity {
        case let entity as any Message1Providing:
            SelectTextAction(text: entity.content)
        case let entity as Comment:
            SelectTextAction(text: entity.content.string)
        case let entity as Post:
            SelectTextAction(text: entity.selectableContent ?? "")
        case let entity as Person:
            SelectTextAction(text: entity.displayName + "\n\n" + (entity.description ?? ""))
        case let entity as Community:
            SelectTextAction(text: entity.displayName + "\n\n" + (entity.description ?? ""))
        default:
            nil
        }
    }
}
