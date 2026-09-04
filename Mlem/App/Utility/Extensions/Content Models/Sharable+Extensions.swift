//
//  Sharable+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-09.
//

import Foundation
import MlemMiddleware
import SwiftUI

extension Sharable {
    var lemmyverseUrl: URL? {
        (URL(string: "https://lemmyverse.link/")?
            .appendingPathComponent(actorId.host)
            .appendingPathComponent(actorId.url.path()))
    }
    
    func shareSheetActions() -> [BasicAction] {
        var shareActions: [BasicAction] = [sendLinkInPrivateMessageAction()]
        if let post = self as? Post {
            shareActions.prepend(post.crossPostAction())
        }
        return shareActions
    }
        
    func sendLinkInPrivateMessageAction() -> BasicAction {
        .init(
            id: "sendLinkInPrivateMessage\(actorId)",
            appearance: .init(
                label: "Send to Lemmy User",
                color: .themedAccent,
                icon: Icons.personCircle
            ),
            callback: {
                NavigationModel.main.openSheet(.personPicker(callback: { person, navigation in
                    navigation.push(
                        .messageFeed(person, messageContent: String(describing: self.actorId), focusTextField: true)
                    )
                }))
            }
        )
    }
}
