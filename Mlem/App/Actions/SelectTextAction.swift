//
//  SelectTextAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-13.
//

import Actions
import MlemMiddleware
import SwiftUI

struct SelectTextAction: ConfigurableAction {
    static let configurationKey = "selectText"
    static let label: ActionLabel = .init("Select Text", icon: .general.select)
    
    let text: String
    
    func execute(environment: EnvironmentValues) {
        environment.navigation?.openSheet(.selectText(text))
    }
}

extension SelectTextAction: MessageConfigurableAction {
    init(_ message: any Message1Providing) { self.text = message.content }
}
