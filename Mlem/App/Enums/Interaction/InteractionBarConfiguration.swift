//
//  InteractionConfiguration.swift
//  Mlem
//
//  Created by Sjmarf on 15/08/2024.
//

import Actions
import Foundation
import Icons
import MlemMiddleware
import SwiftUI

protocol InteractionBarConfiguration: Codable, Equatable, SwipeActionConfiguration, ContextMenuConfiguration {
    associatedtype ActionType: ActionTypeProviding
    
    typealias Item = InteractionConfigurationItem<ActionType>

    static var availableActions: ActionSeedSections { get }
    
    init()
}

// swiftlint:disable:next type_name
enum InteractionBarConfigurationConversionType {
    case swipe, bar, contextMenu
}

enum InteractionConfigurationItem<ActionType: ActionTypeProviding>: Codable, Hashable {
    case action(ActionType)
    case counter(CounterType)
    
    static var allCases: [InteractionConfigurationItem] {
        CounterType.allCases.map { .counter($0) } + ActionType.allCases.map { .action($0) }
    }
    
    fileprivate func convert<A: ActionTypeProviding>() -> InteractionConfigurationItem<A>? {
        switch self {
        case let .action(action):
            if let value = A(rawValue: action.rawValue) {
                return .action(value)
            } else {
                return nil
            }
        case let .counter(counter):
            return .counter(counter)
        }
    }
    
    // This is used to determine when an interaction bar configuration is considered "full"
    var score: Int {
        switch self {
        case .action: 1
        case let .counter(counter):
            counter.appearance.leading == nil || counter.appearance.trailing == nil ? 2 : 3
        }
    }
    
    func toInteractionBarItem() -> InteractionBarItem {
        switch self {
        case let .action(action):
            .action(action.actionSeed)
        case let .counter(counter):
            .counter(counter)
        }
    }
}

protocol ActionTypeProviding: Codable, CaseIterable, Hashable, RawRepresentable where RawValue == String {
    associatedtype Configuration: InteractionBarConfiguration
    
    var appearance: ActionAppearance { get }
    var actionSeed: ActionSeed { get }
}

struct InteractionBarConfigurations: Codable {
    var post: PostBarConfiguration
    var comment: CommentBarConfiguration
    var reply: ReplyBarConfiguration
    var postReport: PostBarConfiguration
    var commentReport: CommentBarConfiguration

    init(
        post: PostBarConfiguration,
        comment: CommentBarConfiguration,
        reply: ReplyBarConfiguration,
        postReport: PostBarConfiguration,
        commentReport: CommentBarConfiguration
    ) {
        self.post = post
        self.comment = comment
        self.reply = reply
        self.postReport = postReport
        self.commentReport = commentReport
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.post = try container.decodeIfPresent(PostBarConfiguration.self, forKey: .post) ?? .init()
        self.comment = try container.decodeIfPresent(CommentBarConfiguration.self, forKey: .comment) ?? .init()
        self.reply = try container.decodeIfPresent(ReplyBarConfiguration.self, forKey: .reply) ?? .init()
        self.postReport = try container.decodeIfPresent(PostBarConfiguration.self, forKey: .postReport) ?? .init()
        self.commentReport = try container.decodeIfPresent(CommentBarConfiguration.self, forKey: .commentReport) ?? .init()
    }
}

struct MockReadoutAppearance {
    let icon: Icon
    let label: String
}
