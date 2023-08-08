//
//  PostLayoutWidget.swift
//  Mlem
//
//  Created by Sjmarf on 02/08/2023.
//

import SwiftUI

indirect enum PostLayoutWidgetType: String, Hashable, Codable, CaseIterable {
    var id: Self { self }
    
    case infoStack
    case upvote
    case downvote
    case save
    case reply
    case share
    case upvoteCounter
    case downvoteCounter
    case scoreCounter
    
    static var allCases: [PostLayoutWidgetType] {
        return [.infoStack, .upvote, .downvote, .save, .reply, .share, .upvoteCounter, .downvoteCounter, .scoreCounter]
    }
    
    var width: CGFloat {
        switch self {
        case .infoStack:
            return .infinity
        case .upvote:
            return 40
        case .downvote:
            return 40
        case .save:
            return 40
        case .reply:
            return 40
        case .share:
            return 40
        case .upvoteCounter:
            return 70
        case .downvoteCounter:
            return 70
        case .scoreCounter:
            return 90
        }
    }
    
    var cost: Float {
        switch self {
        case .scoreCounter:
            return 3
        case .upvoteCounter:
            return 2
        case .downvoteCounter:
            return 2
        case .infoStack:
            return 0
        default:
            return 1
        }
    }
    
    var canRemove: Bool {
        return self != .infoStack
    }
}

class PostLayoutWidget: Equatable, Hashable {
    var type: PostLayoutWidgetType
    var rect: CGRect?
    
    init(_ type: PostLayoutWidgetType) {
        self.type = type
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
    
    static func == (lhs: PostLayoutWidget, rhs: PostLayoutWidget) -> Bool {
        return lhs.type == rhs.type
    }
}
