//
//  InteractionConfiguration.swift
//  Mlem
//
//  Created by Sjmarf on 15/08/2024.
//

import Foundation
import SwiftUICore
import MlemMiddleware

protocol InteractionBarConfiguration: Codable, Equatable {
    associatedtype ActionType: ActionTypeProviding
    associatedtype CounterType: CounterTypeProviding
    associatedtype ReadoutType: ReadoutTypeProviding
    
    typealias Item = InteractionConfigurationItem<ActionType, CounterType, ReadoutType>
    
    var leading: [Item] { get set }
    var trailing: [Item] { get set }
    var leadingSwipes: [ActionType] { get set }
    var trailingSwipes: [ActionType] { get set }
    var readouts: [ReadoutType] { get set }

    var availableWidgets: Set<Item> { get set }
    func widgetPickerPage(_ configuration: Binding<Self>) -> SettingsPage
    
    /// Default configuration for this type
    static var `default`: Self { get }
    /// Default report configuration for this type. `nil` if inapplicable.
    static var reportDefault: Self? { get }
    
    init(
        leading: [Item],
        trailing: [Item],
        leadingSwipes: [ActionType],
        trailingSwipes: [ActionType],
        readouts: [ReadoutType],
        availableWidgets: Set<Item>
    )
}

extension InteractionBarConfiguration {
    /// Convert the `InteractionBarConfiguration` to another type of `InteractionBarConfiguration`. This is done by finding cases with
    /// matching `rawValue` in the new type. If one cannot be found, the item is omitted.
    func applying(other: some InteractionBarConfiguration, types: Set<InteractionBarConfigurationConversionType>) -> Self {
        .init(
            leading: types.contains(.bar) ? other.leading.compactMap { $0.convert() } : leading,
            trailing: types.contains(.bar) ? other.trailing.compactMap { $0.convert() } : trailing,
            leadingSwipes: types.contains(.swipe) ? other.leadingSwipes.compactMap { .init(rawValue: $0.rawValue) } : leadingSwipes,
            trailingSwipes: types.contains(.swipe) ? other.trailingSwipes.compactMap { .init(rawValue: $0.rawValue) } : trailingSwipes,
            readouts: types.contains(.bar) ? other.readouts.compactMap { .init(rawValue: $0.rawValue) } : readouts,
            availableWidgets: types.contains(.bar) ? .init(other.availableWidgets.compactMap { $0.convert() }) : availableWidgets
        )
    }
    
    var all: [Item] { leading + trailing }
    
    func associatedReadouts(context: any Interactable1Providing) -> Set<ReadoutType> {
        var ret: Set<ReadoutType> = .init()
        for element in all {
            ret.formUnion(element.associatedReadouts(context: context))
        }
        return ret
    }
}

// swiftlint:disable:next type_name
enum InteractionBarConfigurationConversionType {
    case swipe, bar
}

enum InteractionConfigurationItem<
    ActionType: ActionTypeProviding,
    CounterType: CounterTypeProviding,
    ReadoutType: ReadoutTypeProviding>: Codable, Hashable {
    case action(ActionType)
    case counter(CounterType)
    
    static var allCases: [InteractionConfigurationItem] {
        CounterType.allCases.map { .counter($0) } + ActionType.allCases.map { .action($0) }
    }
    
    fileprivate func convert<
        A: ActionTypeProviding,
        C: CounterTypeProviding,
        R: ReadoutTypeProviding>() -> InteractionConfigurationItem<A, C, R>? {
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
    
    func associatedReadouts(context: any Interactable1Providing) -> Set<ReadoutType> {
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
    
    func associatedReadouts(context: any Interactable1Providing) -> Set<Configuration.ReadoutType>
}

protocol CounterTypeProviding: Codable, CaseIterable, Hashable, RawRepresentable where RawValue == String {
    associatedtype Configuration: InteractionBarConfiguration
    
    var appearance: CounterAppearance { get }
    
    static var defaultWidgets: [Self] { get }
    
    func associatedReadouts(context: any Interactable1Providing) -> Set<Configuration.ReadoutType>
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
    let icon: String
    let label: String
}
