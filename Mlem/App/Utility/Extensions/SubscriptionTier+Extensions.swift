//
//  SubscriptionTier+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-28.
//

import Foundation
import MlemMiddleware
import SwiftUI

extension SubscriptionTier {
    var systemImage: String {
        switch self {
        case .unsubscribed:
            return Icons.personFill
        case .subscribed:
            return Icons.subscribed
        case .favorited:
            return Icons.favoriteFill
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .unsubscribed:
            return .secondary
        case .subscribed:
            return .green
        case .favorited:
            return .blue
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .unsubscribed:
            return .secondary
        case .subscribed:
            return .green
        case .favorited:
            return .clear
        }
    }
}
