//
//  NewSavedUser.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Foundation
import SwiftUI

protocol SavedUserProviding: AuthenticatedAPISource { }

@Observable
final class SavedUserStub: SavedUserProviding {
    let instance: NewInstanceStub
    var caches: DependentContentCacheGroup { instance.caches }
    let accessToken: String
    
    @ObservationIgnored lazy var api: AuthenticatedAPIClient = {
        if let url = URL(string: "https://\(instance.name)") {
            return .init(baseUrl: url, token: accessToken)
        }
        print("ERROR: Cannot resolve APIClient url!")
        return .init(baseUrl: URL(string: "https://lemmy.world!")!, token: "0")
    }()
    
    init(from account: SavedAccount) {
        if let hostName = account.hostName {
            self.instance = .create(name: hostName)
        } else {
            print("ERROR: Cannot resolve account hostname!")
            self.instance = .create(name: "lemmy.world")
        }
        self.accessToken = account.accessToken
    }
}
