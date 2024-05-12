//
//  LoginDetails.swift
//  Mlem
//
//  Created by Sjmarf on 11/05/2024.
//

import Foundation
import MlemMiddleware

struct LoginDetails: Hashable {
    private(set) var instance: (any Instance)?
    private(set) var user: UserStub?
    private(set) var username: String?
    private(set) var password: String?
    
    init() {}
    
    init(instance: any Instance) {
        self.instance = instance
    }
    
    init(user: UserStub) {
        self.user = user
    }
    
    init(instance: any Instance, username: String, password: String) {
        self.instance = instance
        self.username = username
        self.password = password
    }
    
    static func == (lhs: LoginDetails, rhs: LoginDetails) -> Bool {
        lhs.instance?.name == rhs.instance?.host
            && lhs.username == rhs.username
            && lhs.password == rhs.password
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(instance?.host)
        hasher.combine(username)
        hasher.combine(password)
    }
}

extension NavigationPage {
    static func login() -> Self {
        .login(.init())
    }
    
    static func login(instance: any Instance) -> Self {
        .login(.init(instance: instance))
    }
    
    static func login(user: UserStub) -> Self {
        .login(.init(user: user))
    }
    
    static func login(instance: any Instance, username: String, password: String) -> Self {
        .login(.init(instance: instance, username: username, password: password))
    }
}
