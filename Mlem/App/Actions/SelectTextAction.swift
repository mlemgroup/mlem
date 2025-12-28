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
        case let entity as any Comment1Providing:
            SelectTextAction(text: entity.content)
        case let entity as any Post1Providing:
            SelectTextAction(text: entity.selectableContent ?? "")
        default:
            nil
        }
    }
}
