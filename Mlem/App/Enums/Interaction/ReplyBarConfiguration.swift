//
//  InboxInteraction.swift
//  Mlem
//
//  Created by Sjmarf on 14/06/2024.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct ReplyBarConfiguration: InteractionBarConfiguration {
    enum ActionType: String, ActionTypeProviding {
        typealias Configuration = ReplyBarConfiguration // swiftlint:disable:this nesting
        
        case upvote
        case downvote
        case save
        case reply
        case markRead
        case selectText
        case report
        
        static var defaultWidgets: [ActionType] { [
            .upvote,
            .downvote,
            .save,
            .reply,
            .markRead
        ] }
        
        var appearance: ActionAppearance {
            switch self {
            case .upvote: .upvote(isOn: false)
            case .downvote: .downvote(isOn: false)
            case .save: .save(isOn: false)
            case .reply: .reply()
            case .markRead: .markRead(isOn: false)
            case .selectText: .selectText()
            case .report: .report()
            }
        }
        
        func associatedReadouts(context: any Interactable1Providing) -> Set<ReplyBarConfiguration.ReadoutType> {
            switch self {
            case .upvote: context.votes_?.myVote ?? .none == .upvote ? [.upvote, .score] : [.upvote]
            case .downvote: context.votes_?.myVote ?? .none == .downvote ? [.downvote, .score] : [.downvote]
            case .save: [.saved]
            case .reply, .markRead, .selectText, .report: []
            }
        }
    }
    
    enum CounterType: String, CounterTypeProviding {
        typealias Configuration = ReplyBarConfiguration // swiftlint:disable:this nesting
        
        case score
        case upvote
        case downvote
        case reply
        
        static var defaultWidgets: [CounterType] { allCases }
        
        var appearance: CounterAppearance {
            switch self {
            case .score: .score()
            case .upvote: .upvote()
            case .downvote: .downvote()
            case .reply: .reply()
            }
        }
        
        func associatedReadouts(context: any Interactable1Providing) -> Set<ReplyBarConfiguration.ReadoutType> {
            switch self {
            case .score: [.upvote, .downvote, .score]
            case .upvote: context.votes_?.myVote ?? .none == .upvote ? [.upvote, .score] : [.upvote]
            case .downvote: context.votes_?.myVote ?? .none == .downvote ? [.downvote, .score] : [.downvote]
            case .reply: []
            }
        }
    }
    
    enum ReadoutType: String, ReadoutTypeProviding {
        case created
        case score
        case upvote
        case downvote
        case comment
        case saved
        
        var appearance: MockReadoutAppearance {
            switch self {
            case .created: .init(icon: .general.time, label: "18h")
            case .score: .init(icon: .lemmy.votes, label: "7")
            case .upvote: .init(icon: .lemmy.upvoted, label: "9")
            case .downvote: .init(icon: .lemmy.downvoted, label: "2")
            case .comment: .init(icon: .lemmy.replies, label: "1")
            case .saved: .init(icon: .lemmy.saved, label: "")
            }
        }
        
        func compatibleWith(otherReadouts: Set<Self>) -> Bool {
            switch self {
            case .score: otherReadouts.isDisjoint(with: [.upvote, .downvote])
            case .upvote, .downvote: !otherReadouts.contains(.score)
            default: true
            }
        }
    }

    var leading: [Item]
    var trailing: [Item]
    var readouts: [ReadoutType]
    var leadingSwipes: [ActionType]
    var trailingSwipes: [ActionType]

    var availableWidgets: Set<Item>
    func widgetPickerPage(_ configuration: Binding<Self>) -> SettingsPage { .replyBarWidgetPicker(configuration) }
    
    init(
        leading: [Item],
        trailing: [Item],
        leadingSwipes: [ActionType],
        trailingSwipes: [ActionType],
        readouts: [ReadoutType],
        availableWidgets: Set<Item>
    ) {
        self.leading = leading
        self.trailing = trailing
        self.leadingSwipes = leadingSwipes
        self.trailingSwipes = trailingSwipes
        self.readouts = readouts
        self.availableWidgets = availableWidgets
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.leading = try container.decodeIfPresent([Item].self, forKey: .leading) ?? [.counter(.score)]
        self.trailing = try container.decodeIfPresent([Item].self, forKey: .trailing) ?? [.action(.save), .action(.reply)]
        self.leadingSwipes = try container.decodeIfPresent([ActionType].self, forKey: .leadingSwipes) ?? [.upvote, .downvote]
        self.trailingSwipes = try container.decodeIfPresent([ActionType].self, forKey: .trailingSwipes) ?? [.markRead, .reply]
        self.readouts = try container.decodeIfPresent([ReadoutType].self, forKey: .readouts) ?? [.created, .comment]
        self.availableWidgets = try container.decodeIfPresent(Set<Item>.self, forKey: .availableWidgets) ??
            .init(CounterType.defaultWidgets.map { .counter($0) } + ActionType.defaultWidgets.map { .action($0) })
    }
    
    static var `default`: Self {
        .init(
            leading: [.counter(.score)],
            trailing: [.action(.save), .action(.reply)],
            leadingSwipes: [.upvote, .downvote],
            trailingSwipes: [.markRead, .reply],
            readouts: [.created, .comment],
            availableWidgets: .init(CounterType.defaultWidgets.map { .counter($0) } + ActionType.defaultWidgets.map { .action($0) })
        )
    }
    
    static var reportDefault: Self? { nil }
}
