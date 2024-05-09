//
//  UserProviding+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 09/05/2024.
//

import MlemMiddleware

extension UserProviding {
    func signOut() {
        AccountsTracker.main.removeAccount(account: stub)
    }
}
