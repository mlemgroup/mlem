//
//  MessageFeedLoader.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-22.
//

import Foundation

@Observable
class MessageFetcher: Fetcher<Message2> {
    var personId: Int?
    
    init(api: ApiClient, personId: Int?, pageSize: Int) {
        self.personId = personId
        
        super.init(api: api, pageSize: pageSize)
    }
    
    convenience init(person: any Person, pageSize: Int) {
        self.init(api: person.api, personId: person.id, pageSize: pageSize)
    }
    
    override func fetchPage(_ page: Int) async throws -> FetchResponse {
        let messages = try await api.getMessages(
            creatorId: personId,
            page: page,
            limit: pageSize
        )
        
        return .init(
            items: messages,
            prevCursor: nil,
            nextCursor: nil
        )
    }
}

@Observable
public class MessageFeedLoader: StandardFeedLoader<Message2> {
    public var api: ApiClient

    // force unwrap because this should ALWAYS be a MessageFetcher
    var messageFetcher: MessageFetcher { fetcher as! MessageFetcher }

    public init(
        api: ApiClient,
        personId: Int?,
        pageSize: Int = 20
    ) {
        self.api = api

        super.init(
            filter: .init(),
            fetcher: MessageFetcher(
                api: api,
                personId: personId,
                pageSize: pageSize
            )
        )
    }
    
    public init(
        person: any Person,
        pageSize: Int = 20
    ) {
        self.api = person.api

        super.init(
            filter: .init(),
            fetcher: MessageFetcher(
                person: person,
                pageSize: pageSize
            )
        )
    }
}
