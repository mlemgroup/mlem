//
//  InteractionConfiguration.swift
//  Mlem
//
//  Created by Sjmarf on 15/08/2024.
//

// swiftlint:disable line_length

import Actions
import Foundation
import Icons
import MlemMiddleware
import SwiftUI

protocol InteractionBarConfiguration: Codable, Equatable, SwipeActionConfiguration, ContextMenuConfiguration {
    associatedtype ActionType: ActionTypeProviding
    associatedtype CounterType: CounterTypeProviding
    
    typealias Item = InteractionConfigurationItem<ActionType, CounterType>
    
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

extension InteractionBarConfiguration {
    /// Convert the `InteractionBarConfiguration` to another type of `InteractionBarConfiguration`. This is done by finding cases with
    /// matching `rawValue` in the new type. If one cannot be found, the item is omitted.
    func applying(other: some InteractionBarConfiguration, types: Set<InteractionBarConfigurationConversionType>) -> Self {
        .init(
            leading: types.contains(.bar) ? other.leading.compactMap { $0.convert() } : leading,
            trailing: types.contains(.bar) ? other.trailing.compactMap { $0.convert() } : trailing,
            savedSwipes: types.contains(.swipe) ? other.savedSwipes?.filter(allowed: Self.availableActions.all) : savedSwipes,
            readouts: types.contains(.bar) ? other.readouts.compactMap { .init(rawValue: $0.rawValue) } : readouts,
            availableWidgets: types.contains(.bar) ? .init(other.availableWidgets.compactMap { $0.convert() }) : availableWidgets,
            savedContextMenu: types.contains(.contextMenu) ? other.savedContextMenu.map { $0.filter { Self.availableActions.all.contains($0) } } : savedContextMenu
        )
    }
    
    var all: [Item] { leading + trailing }
    
    func associatedReadouts(context: any InteractableProviding) -> Set<ReadoutType> {
        all.reduce(into: Set<ReadoutType>()) { result, element in
            result.formUnion(element.associatedReadouts(context: context))
        }
    }
}

// swiftlint:disable:next type_name
enum InteractionBarConfigurationConversionType {
    case swipe, bar, contextMenu
}

enum InteractionConfigurationItem<
    ActionType: ActionTypeProviding,
    CounterType: CounterTypeProviding
>: Codable, Hashable {
    case action(ActionType)
    case counter(CounterType)
    
    static var allCases: [InteractionConfigurationItem] {
        CounterType.allCases.map { .counter($0) } + ActionType.allCases.map { .action($0) }
    }
    
    fileprivate func convert<
        A: ActionTypeProviding,
        C: CounterTypeProviding
    >() -> InteractionConfigurationItem<A, C>? {
        switch self {
        case let .action(action):
            if let value = A(rawValue: action.rawValue) {
                return .action(value)
            } else {
                return nil
            }
        case let .counter(counter):
            if let value = C(rawValue: counter.rawValue) {
                return .counter(value)
            } else {
                return nil
            }
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
    
    func associatedReadouts(context: any InteractableProviding) -> Set<ReadoutType> {
        switch self {
        case let .action(actionType):
            guard let ret = actionType.associatedReadouts(context: context) as? Set<ReadoutType> else {
                assertionFailure("Could not cast to ReadoutType")
                return []
            }
            return ret
        case let .counter(counterType):
            guard let ret = counterType.associatedReadouts(context: context) as? Set<ReadoutType> else {
                assertionFailure("Could not cast to ReadoutType")
                return []
            }
            return ret
        }
    }
}

protocol ActionTypeProviding: Codable, CaseIterable, Hashable, RawRepresentable where RawValue == String {
    associatedtype Configuration: InteractionBarConfiguration
    
    var appearance: ActionAppearance { get }
    
    static var defaultWidgets: [Self] { get }
    
    func associatedReadouts(context: any InteractableProviding) -> Set<ReadoutType>
}

protocol CounterTypeProviding: Codable, CaseIterable, Hashable, RawRepresentable where RawValue == String {
    associatedtype Configuration: InteractionBarConfiguration
    
    var appearance: CounterAppearance { get }
    
    static var defaultWidgets: [Self] { get }
    
    func associatedReadouts(context: any InteractableProviding) -> Set<ReadoutType>
}

protocol ReadoutTypeProviding: Codable, CaseIterable, Hashable, RawRepresentable where RawValue == String {
    var appearance: MockReadoutAppearance { get }
    
    func compatibleWith(otherReadouts: Set<Self>) -> Bool
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

// swiftlint:enable line_length
