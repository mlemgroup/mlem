//
//  ActorIdentifiable+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 02/07/2024.
//

import Foundation
import MlemMiddleware
import SwiftUI

extension ActorIdentifiable {
    func openInstanceAction(environment: EnvironmentValues) -> BasicAction {
        let callback: (@MainActor () -> Void)?
        if let navigation = environment[NavigationLayer.self] {
            callback = { navigation.push(.instance(hostOf: self)) }
        } else {
            callback = nil
        }
        return .init(
            id: "instance\(actorId)",
            appearance: .init(label: host, color: .themedNeutralAccent, icon: Icons.instance),
            callback: callback
        )
    }
}
