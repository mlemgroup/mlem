//
//  SendLinkInMessageAction.swift
//  Mlem
//
//  Created by Sjmarf on 2026-09-04.
//

import Actions
import SwiftUI

struct SendLinkInMessageAction: SimpleLabelAction {
    let url: URL

    static let appearance: ActionAppearance = .init("Send Message in Mlem", icon: .lemmy.message)

    func execute(environment: EnvironmentValues) {
        environment.navigation?.openSheet(.personPicker(callback: { person, navigation in
            navigation.push(
                .messageFeed(person, messageContent: url.absoluteString, focusTextField: true)
            )
        }))
    }
}
