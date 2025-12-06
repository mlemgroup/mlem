//
//  CopyNameAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-13.
//

import Actions
import MlemMiddleware
import SwiftUI

struct CopyNameAction: Actions.ConfigurableAction {
    static let label: ActionLabel = .init("Copy Name", icon: .general.copy)
    
    let text: String
    
    func execute(environment: EnvironmentValues) {
        environment.toastModel?.add(.success("Copied"))
        UIPasteboard.general.string = self.text
    }
}

extension ActionSeed {
    static let copyName = ActionSeed("copyName") { entity in
        switch entity {
        case let entity as any Person1Providing:
            CopyNameAction(text: entity.fullNameWithPrefix)
        default:
            nil
        }
    }
}
