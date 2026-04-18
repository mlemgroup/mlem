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
    func openInstanceAction(navigation: NavigationLayer?) -> BasicAction {
        let callback: (@MainActor () -> Void)?
        if let navigation {
            callback = { navigation.push(.hostInstance(of: self)) }
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
