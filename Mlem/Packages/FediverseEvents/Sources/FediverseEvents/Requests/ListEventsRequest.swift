//
//  ListEventsRequest.swift
//  Mlem
//
//  Created by Sjmarf on 2026-04-23.
//

import Rest

internal struct ListEventsRequest: GetRequest {
    typealias Parameters = Never
    
    let path: String = "v1/events"
    let parameters: Parameters? = nil

    struct Response: Codable {
        let events: [Event]
    }
}
