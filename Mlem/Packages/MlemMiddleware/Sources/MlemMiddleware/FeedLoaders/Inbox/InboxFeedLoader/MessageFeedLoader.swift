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
    
    convenience init(person: Person, pageSize: Int) {
        self.init(api: person.api, personId: person.id, pageSize: pageSize)
    }
    
    override func fetchContent(_ pageInfo: PageInfo) async throws -> PagedResponse<Message2> {
        try await api.getMessages(creatorId: personId, pageInfo: pageInfo)
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
        person: Person,
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
