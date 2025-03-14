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
    func shareAction(navigation: NavigationLayer?) -> BasicAction {
        .init(id: "share\(actorId)", appearance: .share(), callback: {
            let url: URL? = switch Settings.main.linkSharingMode {
            case .myInstance: self.url()
            case .originalInstance: self.actorId.url
            case .askEveryTime: nil
            }
            if let url, let navigation {
                navigation.model?.shareInfo = .init(url: url, actions: self.shareSheetActions())
            } else {
                navigation?.openSheet(.shareInstancePicker(self))
            }
        })
    }
    
    func shareSheetActions() -> [BasicAction] {
        var shareActions: [BasicAction] = [sendLinkInPrivateMessageAction()]
        if let post = self as? any Post1Providing {
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
