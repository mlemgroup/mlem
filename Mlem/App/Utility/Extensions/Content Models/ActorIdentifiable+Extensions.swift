//
//  ActorIdentifiable+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 02/07/2024.
//

import Foundation
import MlemMiddleware

extension ActorIdentifiable {
    func shareAction() -> ShareAction {
        .init(id: "share\(actorId)", url: actorId.url, actions: [sendLinkInPrivateMessageAction()])
    }
    
    func sendLinkInPrivateMessageAction() -> BasicAction {
        .init(
            id: "sendLinkInPrivateMessage\(actorId)",
            appearance: .init(
                label: "Send to Lemmy User",
                color: Palette.main.accent,
                icon: Icons.personCircle
            ),
            callback: {
                NavigationModel.main.openSheet(.personPicker(callback: { person, navigation in
                    navigation.push(
                        .messageFeed(person, messageContent: String(describing: actorId), focusTextField: true)
                    )
                }))
            }
        )
    }
    
    func openInstanceAction(navigation: NavigationLayer?) -> BasicAction {
        let callback: (@MainActor () -> Void)?
        if let navigation {
            callback = { navigation.push(.instance(hostOf: self)) }
        } else {
            callback = nil
        }
        return .init(
            id: "instance\(actorId)",
            appearance: .init(label: host, color: .gray, icon: Icons.instance),
            callback: callback
        )
    }
}
