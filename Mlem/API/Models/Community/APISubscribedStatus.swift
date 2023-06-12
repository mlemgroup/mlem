//
//  APISubscribedStatus.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_schema::SubscribedType
enum APISubscribedStatus: String, Decodable {
    case subscribed = "Subscribed"
    case pending = "Pending"
    case notSubscribed = "NotSubscribed"
}
