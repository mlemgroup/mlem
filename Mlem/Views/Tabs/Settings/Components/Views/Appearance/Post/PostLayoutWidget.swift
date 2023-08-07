//
//  PostLayoutWidget.swift
//  Mlem
//
//  Created by Sjmarf on 02/08/2023.
//

import SwiftUI

indirect enum PostLayoutWidgetType: Hashable {
    case placeholder(wrappedValue: PostLayoutWidgetType)
    case spacer
    case upvote
    case downvote
    case save
    case reply
    case share
    case upvoteCounter
    case downvoteCounter
    case scoreCounter
    
    var width: CGFloat {
        switch self {
        case .placeholder(let wrappedValue):
            return wrappedValue.width
        case .spacer:
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
