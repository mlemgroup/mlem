//
//  AccountsTracker+Dependency.swift
//  Mlem
//
//  Created by mormaer on 26/08/2023.
//
//

import Dependencies
import Foundation

extension AccountsTracker: DependencyKey {
    static let liveValue = AccountsTracker()
}

extension DependencyValues {
    var accountsTracker: AccountsTracker {
        get { self[AccountsTracker.self] }
        set { self[AccountsTracker.self] = newValue }
    }
}
