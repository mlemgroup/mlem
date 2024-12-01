//
//  ErrorDetails.swift
//  Mlem
//
//  Created by Sjmarf on 31/08/2023.
//

import Combine
import MlemMiddleware
import SwiftUI
import UniformTypeIdentifiers

struct ErrorDetails: Hashable {
    var title: String?
    var body: String?
    var error: Error?
    var systemImage: String?
    var buttonText: String?
    var refresh: (() async -> Bool)?
    var autoRefresh: Bool = false
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(body)
        hasher.combine(error?.localizedDescription)
        hasher.combine(systemImage)
        hasher.combine(buttonText)
        hasher.combine(refresh == nil)
        hasher.combine(autoRefresh)
    }

    static func == (lhs: ErrorDetails, rhs: ErrorDetails) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    var errorText: String {
        var output: String
        if let error = error as? ApiClientError {
            output = error.description
        } else {
            output = error?.localizedDescription ?? ""
        }
        for account in AccountsTracker.main.userAccounts {
            if let token = account.api.token {
                output.replace(token, with: "TOKEN_REDACTED")
            }
        }
        return output
    }
}
