//
//  MyUserProviding.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

protocol MyUserProviding: AnyObject, Identifiable {
    var stub: MyUserStub { get }
    var source: any APISource { get }
    
    var id: Int { get }
    var username: String { get }
    
    var accessToken: String { get set }
    var nickname: String? { get set }
    var cachedSiteVersion: SiteVersion? { get set }
    var lastLoggedIn: Date? { get set }
    var avatarUrl: URL? { get set }
}

extension MyUserProviding {
    var id: Int { stub.id }
    var username: String { stub.username }
    
    var accessToken: String { get { stub.accessToken } set { stub.accessToken = newValue } }
    var nickname: String? { get { stub.nickname } set { stub.nickname = newValue } }
    var cachedSiteVersion: SiteVersion? { get { stub.cachedSiteVersion } set { stub.cachedSiteVersion = newValue } }
    var lastLoggedIn: Date? { get { stub.lastLoggedIn } set { stub.lastLoggedIn = newValue } }
    var avatarUrl: URL? { get { stub.avatarUrl } set { stub.avatarUrl = newValue } }
}

extension MyUserProviding {
    func login(password: String, twoFactorToken: String? = nil) async throws {
        let response = try await source.api.login(username: username, password: password, totpToken: twoFactorToken)
        accessToken = response.jwt
    }
}