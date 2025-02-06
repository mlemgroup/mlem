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
    var location: String?
    var systemImage: String?
    var buttonText: String?
    var refresh: (() async -> Bool)?
    var autoRefresh: Bool = false
    var when: Date
    
    init(
        title: String? = nil,
        body: String? = nil,
        error: Error? = nil,
        location: String? = nil,
        systemImage: String? = nil,
        buttonText: String? = nil,
        refresh: (() -> Bool)? = nil,
        autoRefresh: Bool = false
    ) {
        self.title = title
        self.body = body
        self.error = error
        self.location = location
        self.systemImage = systemImage
        self.buttonText = buttonText
        self.refresh = refresh
        self.autoRefresh = autoRefresh
        self.when = Date.now
        
        if let error {
            switch error {
            case ApiClientError.imageTooLarge:
                self.title = self.title ?? "Image too large"
            default:
                break
            }
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(body)
        hasher.combine(error?.localizedDescription)
        hasher.combine(location)
        hasher.combine(systemImage)
        hasher.combine(buttonText)
        hasher.combine(refresh == nil)
        hasher.combine(autoRefresh)
    }

    static func == (lhs: ErrorDetails, rhs: ErrorDetails) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    var errorDescription: String {
        if let error = error as? CustomStringConvertible {
            return error.description
        } else {
            return String(describing: error)
        }
    }
    
    var errorText: String {
        var output = errorDescription
        if let location {
            output += " (\(location))"
        }
        for account in AccountsTracker.main.userAccounts {
            if let token = account.api.token {
                output.replace(token, with: "TOKEN_REDACTED")
            }
        }
        return output
    }
}
