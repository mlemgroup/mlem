//
//  InstanceTier1.swift
//  Mlem
//
//  Created by Sjmarf on 09/02/2024.
//

import Foundation
import SwiftUI

@Observable
final class Instance1: Instance1Providing {
    var api: ApiClient
    var instance1: Instance1 { self }
    
    let id: Int
    let creationDate: Date
    let publicKey: String
    
    var displayName: String = ""
    var description: String?
    var avatar: URL?
    var banner: URL?
    var lastRefreshDate: Date = .distantPast
    
    init(
        api: ApiClient,
        id: Int,
        creationDate: Date,
        publicKey: String,
        displayName: String = "",
        description: String? = nil,
        avatar: URL? = nil,
        banner: URL? = nil,
        lastRefreshDate: Date = .distantPast
    ) {
        self.api = api
        self.id = id
        self.creationDate = creationDate
        self.publicKey = publicKey
        self.displayName = displayName
        self.description = description
        self.avatar = avatar
        self.banner = banner
        self.lastRefreshDate = lastRefreshDate
    }
}
