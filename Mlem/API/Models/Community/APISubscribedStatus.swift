//
//  APISubscribedStatus.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

enum APISubscribedStatus: String, Decodable {
    case subscribed = "Subscribed"
    case pending = "Pending"
    case notSubscribed = "NotSubscribed"
}
