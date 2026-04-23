//
//  EventsTracker.swift
//  Mlem
//
//  Created by Sjmarf on 2026-04-23.
//

import Foundation
import FediverseEvents

@Observable
class EventsTracker {
    private let client = EventsClient()

    var environment: EventsEnvironment { client.environment }

    func changeEnvironment(to environment: EventsEnvironment) {
        self.client.changeEnvironment(to: environment)
    }
}
