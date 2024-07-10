//
//  ActorIdentifiable+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 02/07/2024.
//

import MlemMiddleware

extension ActorIdentifiable {
    func shareAction() -> ShareAction {
        .init(id: "share\(actorId)", url: actorId)
    }
    
    func openInstanceAction() -> BasicAction {
        .init(
            id: "instance\(actorId)",
            isOn: false,
            label: host ?? "Instance",
            color: .gray,
            icon: Icons.instance,
            callback: nil // TODO:
        )
    }
}
