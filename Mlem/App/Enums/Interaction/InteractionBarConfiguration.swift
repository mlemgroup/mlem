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
    
    var leading: [Item] { get set }
    var trailing: [Item] { get set }
    var readouts: [ReadoutType] { get set }

    var availableWidgets: Set<Item> { get set }
    func widgetPickerPage(_ configuration: Binding<Self>) -> SettingsPage
    
    /// Default configuration for this type
    static var `default`: Self { get }
    /// Default report configuration for this type. `nil` if inapplicable.
    static var reportDefault: Self? { get }

    static var availableActions: ActionSeedSections { get }
    
    init(
        leading: [Item],
        trailing: [Item],
        savedSwipes: ActionSeedSwipeConfiguration?,
        readouts: [ReadoutType],
        availableWidgets: Set<Item>,
        savedContextMenu: [ActionSeed]?
    )
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
    
    static var defaultWidgets: [Self] { get }
}

struct InteractionBarConfigurations: Codable {
    var post: PostBarConfiguration
    var comment: CommentBarConfiguration
    var reply: ReplyBarConfiguration
    var postReport: PostBarConfiguration
    var commentReport: CommentBarConfiguration
    
    static var `default`: Self {
        .init(
            post: .default,
            comment: .default,
            reply: .default,
            postReport: .reportDefault_,
            commentReport: .reportDefault_
        )
    }
    
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
        self.post = try container.decodeIfPresent(PostBarConfiguration.self, forKey: .post) ?? .default
        self.comment = try container.decodeIfPresent(CommentBarConfiguration.self, forKey: .comment) ?? .default
        self.reply = try container.decodeIfPresent(ReplyBarConfiguration.self, forKey: .reply) ?? .default
        self.postReport = try container.decodeIfPresent(PostBarConfiguration.self, forKey: .postReport) ?? .reportDefault_
        self.commentReport = try container.decodeIfPresent(CommentBarConfiguration.self, forKey: .commentReport) ?? .reportDefault_
    }
}

struct MockReadoutAppearance {
    let icon: Icon
    let label: String
}
