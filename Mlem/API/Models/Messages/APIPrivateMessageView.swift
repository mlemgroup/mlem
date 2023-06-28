//
//  APIPrivateMessageView.swift
//  Mlem
//
//  Created by Jake Shirley on 6/25/23.
//

import Foundation

struct APIPrivateMessageView: Decodable {
    let creator: APIPerson
    let recipient: APIPerson
    let privateMessage: APIPrivateMessage
}

extension APIPrivateMessageView: Identifiable {
    var id: Int { privateMessage.id }
}
