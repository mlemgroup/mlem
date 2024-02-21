//
//  SubscriptionTier.swift
//  Mlem
//
//  Created by Sjmarf on 15/02/2024.
//

import SwiftUI

enum SubscriptionTier {
    case unsubscribed, subscribed, favorited
    
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
}
