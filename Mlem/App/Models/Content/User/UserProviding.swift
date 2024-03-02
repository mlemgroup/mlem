//
//  MyUserProviding.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

protocol UserProviding: CommunityOrPersonStub, AnyObject, Identifiable {
    var stub: UserStub { get }
    var api: ApiClient { get }
    
    var id: Int { get }
    var name: String { get }
    
    var nickname: String? { get set }
    var cachedSiteVersion: SiteVersion? { get set }
    var lastLoggedIn: Date? { get set }
    var avatarUrl: URL? { get set }
}

extension UserProviding {
    static var identifierPrefix: String { "@" }
    
    var id: Int { stub.id }
    var name: String { stub.name }
    
    var nickname: String? { get { stub.nickname } set { stub.nickname = newValue } }
    var cachedSiteVersion: SiteVersion? { get { stub.cachedSiteVersion } set { stub.cachedSiteVersion = newValue } }
    var lastLoggedIn: Date? { get { stub.lastLoggedIn } set { stub.lastLoggedIn = newValue } }
    var avatarUrl: URL? { get { stub.avatarUrl } set { stub.avatarUrl = newValue } }
}

extension UserProviding {
    var nicknameSortKey: String { "\(nickname ?? name)\(api.baseUrl.absoluteString)" }
    
    var instanceSortKey: String { "\(api.baseUrl.absoluteString)\(nickname ?? name)" }
}
