//
//  Instance1Providing.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

protocol Instance1Providing: Identifiable {
    var instance1: Instance1 { get }
    
    var id: Int { get }
    var displayName: String { get }
    var description: String? { get }
    var avatar: URL? { get }
    var banner: URL? { get }
    var creationDate: Date { get }
    var publicKey: String { get }
    var lastRefreshDate: Date { get }
}

typealias Instance = Instance1Providing

extension Instance1Providing {
    var id: Int { instance1.id }
    var displayName: String { instance1.displayName }
    var description: String? { instance1.description }
    var avatar: URL? { instance1.avatar }
    var banner: URL? { instance1.banner }
    var creationDate: Date { instance1.creationDate }
    var publicKey: String { instance1.publicKey }
    var lastRefreshDate: Date { instance1.lastRefreshDate }
    
    var id_: Int? { instance1.id }
    var displayName_: String? { instance1.displayName }
    var description_: String? { instance1.description }
    var avatar_: URL? { instance1.avatar }
    var banner_: URL? { instance1.banner }
    var creationDate_: Date? { instance1.creationDate }
    var publicKey_: String? { instance1.publicKey }
    var lastRefreshDate_: Date? { instance1.lastRefreshDate }
}
