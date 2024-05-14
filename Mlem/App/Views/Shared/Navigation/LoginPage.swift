//
//  LoginPage.swift
//  Mlem
//
//  Created by Sjmarf on 13/05/2024.
//

import MlemMiddleware
import SwiftUI

enum LoginPage: Hashable {
    case pickInstance
    case instance(_ instance: any Instance)
    case reauth(_ userStub: UserStub)
    case totp(url: URL, username: String, password: String)
    
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .pickInstance:
            LoginInstancePickerView()
        case let .instance(instance):
            LoginCredentialsView(instance: instance)
        case let .reauth(userStub):
            LoginCredentialsView(userStub: userStub)
        case let .totp(url, username, password):
            LoginTotpView(url: url, username: username, password: password)
        }
    }
    
    static func == (lhs: LoginPage, rhs: LoginPage) -> Bool {
        switch (lhs, rhs) {
        case (.pickInstance, .pickInstance):
            true
        case let (.totp(url1, username1, password1), .totp(url2, username2, password2)):
            url1 == url2 && username1 == username2 && password1 == password2
        case let (.instance(instance1), .instance(instance2)):
            instance1.actorId == instance2.actorId
        case let (.reauth(user1), .reauth(user2)):
            user1 == user2
        default:
            false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .pickInstance:
            hasher.combine(0)
        case .totp:
            hasher.combine(1)
        case let .instance(instance):
            hasher.combine(instance.actorId)
        case let .reauth(user):
            hasher.combine(user.actorId)
        }
    }
}
