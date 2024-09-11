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
        .init(id: "share\(actorId)", url: actorId)
    }
    
    func openInstanceAction(navigation: NavigationLayer?) -> BasicAction {
        let callback: (() -> Void)?
        if let navigation {
            callback = { navigation.push(.instance(hostOf: self)) }
        } else {
            callback = nil
        }
        return .init(
            id: "instance\(actorId)",
            appearance: .init(label: host ?? String(localized: "Instance"), color: .gray, icon: Icons.instance),
            callback: callback
        )
    }
}
