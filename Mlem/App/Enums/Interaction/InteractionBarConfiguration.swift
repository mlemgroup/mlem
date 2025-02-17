//
//  InteractionConfiguration.swift
//  Mlem
//
//  Created by Sjmarf on 15/08/2024.
//

import Foundation
import SwiftUICore

protocol InteractionBarConfiguration: Codable {
    associatedtype ActionType: ActionTypeProviding
    associatedtype CounterType: CounterTypeProviding
    associatedtype ReadoutType: ReadoutTypeProviding
    
    typealias Item = InteractionConfigurationItem<ActionType, CounterType>
    
    var leading: [Item] { get set }
    var trailing: [Item] { get set }
    var readouts: [ReadoutType] { get set }
    
    var availableWidgets: Set<Item> { get set }
    func widgetPickerPage(_ configuration: Binding<Self>) -> SettingsPage
    
    static var `default`: Self { get }
    
    init(leading: [Item], trailing: [Item], readouts: [ReadoutType], availableWidgets: Set<Item>)
}

extension InteractionBarConfiguration {
    /// Convert the `InteractionBarConfiguration` to another type of `InteractionBarConfiguration`. This is done by finding cases with
    /// matching `rawValue` in the new type. If one cannot be found, the item is omitted.
    func convert<T: InteractionBarConfiguration>() -> T {
        .init(
            leading: leading.compactMap { $0.convert() },
            trailing: trailing.compactMap { $0.convert() },
            readouts: readouts.compactMap { .init(rawValue: $0.rawValue) },
            availableWidgets: .init(availableWidgets.compactMap { $0.convert() })
        )
    }
    
    var all: [Item] { leading + trailing }
}

enum InteractionConfigurationItem<ActionType: ActionTypeProviding, CounterType: CounterTypeProviding>: Codable, Hashable {
    case action(ActionType)
    case counter(CounterType)
    
    static var allCases: [InteractionConfigurationItem] {
        CounterType.allCases.map { .counter($0) } + ActionType.allCases.map { .action($0) }
    }
    
    fileprivate func convert<A: ActionTypeProviding, C: CounterTypeProviding>() -> InteractionConfigurationItem<A, C>? {
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
}

protocol ActionTypeProviding: Codable, CaseIterable, Hashable, RawRepresentable where RawValue == String {
    var appearance: ActionAppearance { get }
    
    static var defaultWidgets: [Self] { get }
}

protocol CounterTypeProviding: Codable, CaseIterable, Hashable, RawRepresentable where RawValue == String {
    var appearance: CounterAppearance { get }
    
    static var defaultWidgets: [Self] { get }
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
            postReport: .reportDefault,
            commentReport: .reportDefault
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
        do {
            self.post = try container.decodeIfPresent(PostBarConfiguration.self, forKey: .post) ?? .default
            self.comment = try container.decodeIfPresent(CommentBarConfiguration.self, forKey: .comment) ?? .default
            self.reply = try container.decodeIfPresent(ReplyBarConfiguration.self, forKey: .reply) ?? .default
            self.postReport = try container.decodeIfPresent(PostBarConfiguration.self, forKey: .postReport) ?? .reportDefault
            self.commentReport = try container.decodeIfPresent(CommentBarConfiguration.self, forKey: .commentReport) ?? .reportDefault
        } catch {
            // legacy decoding
            let allPostItems = try container.decodeIfPresent([LegacyInterationBarItems].self, forKey: .post)
        }
    }
}

struct MockReadoutAppearance {
    let icon: String
    let label: String
}

enum LegacyInterationBarItems: Decodable {
    case infoStack, upvote, downvote, save, reply, share, upvoteCounter, downvoteCounter, scoreCounter, resolve, remove, purge, ban
    
    func postEquivalent() -> PostBarConfiguration.Item? {
        switch self {
        case .infoStack: return nil
        case .upvote: return .action(.upvote)
        case .downvote: return .action(.downvote)
        case .save: return .action(.save)
        case .reply: return .action(.reply)
        case .share: return .action(.share)
        case .upvoteCounter: return .counter(.upvote)
        case .downvoteCounter: return .counter(.downvote)
        case .scoreCounter: return .counter(.score)
        case .resolve: return nil
        case .remove: return .action(.remove)
        case .purge: return nil
        case .ban: return nil
        }
    }
}
