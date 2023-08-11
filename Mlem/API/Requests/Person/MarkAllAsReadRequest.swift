//
//  MarkAllAsReadRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-27.
//

import Foundation

struct MarkAllAsRead: APIPostRequest {
    
    // no idea why the Lemmy API returns an empty dictionary, but it does
    typealias Response = [String: [String]]
    
    let instanceURL: URL
    let path = "user/mark_all_as_read"
    let body: Body
    
    struct Body: Encodable {
        let auth: String
    }
    
    init(
        session: APISession
    ) {
        self.instanceURL = session.URL
        self.body = .init(
            auth: session.token
        )
    }
}
