//
//  Blockable+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-02-10.
//

import MlemMiddleware
import SwiftUI

extension Blockable {
    func blocked(environment: EnvironmentValues) -> Bool {
        if self is any InstanceActionProviding,
           let session = (environment.appState.firstSession as? UserSession) {
            return session.blocks?.contains(instanceActorId: actorId) ?? self.blocked.realizedValue
        }
        return self.blocked.realizedValue
    }
}
