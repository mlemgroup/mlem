//
//  LayoutWidget.swift
//  Mlem
//
//  Created by Sjmarf on 02/08/2023.
//

import SwiftUI

indirect enum LayoutWidgetType: String, Hashable, Codable, CaseIterable {
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
    case resolve
    case remove
    case purge
    case ban
    
    static var allCases: [LayoutWidgetType] {
        [.infoStack, .upvote, .downvote, .save, .reply, .share, .upvoteCounter, .downvoteCounter, .scoreCounter]
    }
    
    static var upvoteContaining: Set<Self> = [.upvote, .upvoteCounter, .scoreCounter]
    static var downvoteContaining: Set<Self> = [.downvote, .downvoteCounter, .scoreCounter]
    
    var width: CGFloat {
        switch self {
        case .infoStack: .infinity
        case .upvote, .downvote, .save, .reply, .share, .resolve, .remove, .purge, .ban: 40
        case .upvoteCounter: 70
        case .downvoteCounter: 70
        case .scoreCounter: 90
        }
    }
    
    var cost: Float {
        switch self {
        case .scoreCounter: 3
        case .upvoteCounter, .downvoteCounter: 2
        case .infoStack: 0
        default: 1
        }
    }
    
    var canRemove: Bool {
        self != .infoStack
    }
}

class LayoutWidget: Equatable, Hashable {
    var id = UUID()
    var type: LayoutWidgetType
    var rect: CGRect?
    
    init(_ type: LayoutWidgetType, rect: CGRect? = nil) {
        self.type = type
        self.rect = rect
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: LayoutWidget, rhs: LayoutWidget) -> Bool {
        lhs.id == rhs.id
    }
}
