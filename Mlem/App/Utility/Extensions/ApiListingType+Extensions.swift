//
//  ApiListingType+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 29/07/2024.
//

import Foundation
import MlemMiddleware

extension ApiListingType {
    var label: LocalizedStringResource {
        switch self {
        case .all: "All"
        case .local: "Local"
        case .subscribed: "Subscribed"
        case .moderatorView: "Moderated"
        }
    }
}
