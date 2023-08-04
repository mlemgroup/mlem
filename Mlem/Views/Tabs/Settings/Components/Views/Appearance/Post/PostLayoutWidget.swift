//
//  PostLayoutWidget.swift
//  Mlem
//
//  Created by Sjmarf on 02/08/2023.
//

import SwiftUI

indirect enum WidgetType: Hashable {
    case placeholder(wrappedValue: WidgetType)
    case spacer
    case upvote
    case downvote
    case save
    case reply
    
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
        }
        
    }
}

class PostLayoutWidget: Equatable, Hashable {
    var type: WidgetType
    var rect: CGRect?
    
    init(_ type: WidgetType) {
        self.type = type
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
    
    static func == (lhs: PostLayoutWidget, rhs: PostLayoutWidget) -> Bool {
        return lhs.type == rhs.type
    }
}
