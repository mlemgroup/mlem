//
//  EventsClient+Requests.swift
//  Mlem
//
//  Created by Sjmarf on 2026-04-23.
//

extension EventsClient {
    public func listEvents() async throws -> [Event] {
        let response = try await perform(ListEventsRequest())
        return response.events
    }
}
