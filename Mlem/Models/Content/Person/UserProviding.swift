//
//  MyUserProviding.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

protocol UserProviding: ApiSource, CommunityOrPersonStub, AnyObject, Identifiable {
    var stub: UserStub { get }
    var source: any ApiSource { get }
    
    var id: Int { get }
    var name: String { get }
    
    var accessToken: String { get set }
    var nickname: String? { get set }
    var cachedSiteVersion: SiteVersion? { get set }
    var lastLoggedIn: Date? { get set }
    var avatarUrl: URL? { get set }
}

extension UserProviding {
    static var identifierPrefix: String { "@" }
    
    var source: any ApiSource { stub }
    
    var caches: BaseCacheGroup { source.caches }
    var api: ApiClient { source.api }
    var instance: InstanceStub { stub.instance }
    
    var id: Int { stub.id }
    var name: String { stub.name }
    
    var accessToken: String { get { stub.accessToken } set { stub.accessToken = newValue } }
    var nickname: String? { get { stub.nickname } set { stub.nickname = newValue } }
    var cachedSiteVersion: SiteVersion? { get { stub.cachedSiteVersion } set { stub.cachedSiteVersion = newValue } }
    var lastLoggedIn: Date? { get { stub.lastLoggedIn } set { stub.lastLoggedIn = newValue } }
    var avatarUrl: URL? { get { stub.avatarUrl } set { stub.avatarUrl = newValue } }
}

extension UserProviding {
    func login(password: String, twoFactorToken: String? = nil) async throws {
        let response = try await source.api.login(username: name, password: password, totpToken: twoFactorToken)
        accessToken = response.jwt ?? "" // TODO: throw nice error
    }
    
    var nicknameSortKey: String { "\(nickname ?? name)\(instance.host ?? "")" }
    
    var instanceSortKey: String { "\(instance.host ?? "")\(nickname ?? name)" }
}
