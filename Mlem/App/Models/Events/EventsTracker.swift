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

    private(set) var events: [Event]?
    private var lastRefreshedAt: Date?

    var environment: EventsEnvironment { client.environment }

    func changeEnvironment(to environment: EventsEnvironment) {
        self.client.changeEnvironment(to: environment)
        self.lastRefreshedAt = nil
        self.events = nil
        self.refreshIfStale()
    }

    private func refresh() async throws {
        self.events = try await self.client.listEvents()
        self.lastRefreshedAt = .now
    }

    func refreshIfStale() {
        if self.needsRefresh {
            Task {
                do {
                    try await refresh()
                } catch {
                    handleError(error, silent: true)
                }
            }
        }
    }

    private var needsRefresh: Bool {
        if let lastRefreshedAt {
            abs(lastRefreshedAt.timeIntervalSinceNow) > 60 * 60 // 1 hour
        } else {
            true
        }
    }
}
