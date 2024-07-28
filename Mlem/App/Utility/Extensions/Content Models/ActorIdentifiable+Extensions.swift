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
        if let navigation, let host, let url = URL(string: "https://\(host)/") {
            callback = { navigation.push(.instance(InstanceStub(api: AppState.main.firstApi, actorId: url))) }
        } else {
            callback = nil
        }
        return .init(
            id: "instance\(actorId)",
            isOn: false,
            label: host ?? "Instance",
            color: .gray,
            icon: Icons.instance,
            callback: callback
        )
    }
}
