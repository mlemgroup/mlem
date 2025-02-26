//
//  LegacyInteractionBarConfigurations.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-17.
//

import SwiftUI

// MARK: Legacy Types

struct LegacyInteractionBarConfigurations: Codable {
    let post: [LegacyInterationBarItem]?
    let comment: [LegacyInterationBarItem]?
    let moderator: [LegacyInterationBarItem]?
    
    init(from decoder: any Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.post = try container.decodeIfPresent([LegacyInterationBarItem].self, forKey: .post)
            self.comment = try container.decodeIfPresent([LegacyInterationBarItem].self, forKey: .comment)
            self.moderator = try container.decodeIfPresent([LegacyInterationBarItem].self, forKey: .moderator)
        } catch {
            print(error)
            throw error
        }
    }
}

enum LegacyInterationBarItem: String, Codable {
    case infoStack, upvote, downvote, save, reply, share, upvoteCounter, downvoteCounter, scoreCounter, resolve, remove, purge, ban
    
    // TODO: pending #1768 update equivalent() functions to include new types
    
    // swiftlint:disable:next cyclomatic_complexity
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
        case .resolve: return .action(.resolve)
        case .remove: return .action(.remove)
        case .purge: return nil
        case .ban: return .action(.ban)
        }
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    func commentEquivalent() -> CommentBarConfiguration.Item? {
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
        case .resolve: return .action(.resolve)
        case .remove: return .action(.remove)
        case .purge: return nil
        case .ban: return .action(.ban)
        }
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    func replyEquivalent() -> ReplyBarConfiguration.Item? {
        switch self {
        case .infoStack: return nil
        case .upvote: return .action(.upvote)
        case .downvote: return .action(.downvote)
        case .save: return .action(.save)
        case .reply: return .action(.reply)
        case .share: return nil
        case .upvoteCounter: return .counter(.upvote)
        case .downvoteCounter: return .counter(.downvote)
        case .scoreCounter: return .counter(.score)
        case .resolve: return nil
        case .remove: return nil
        case .purge: return nil
        case .ban: return nil
        }
    }
}

// MARK: Initializers

extension InteractionBarConfigurations {
    init(legacyConfiguration: LegacyInteractionBarConfigurations) {
        if legacyConfiguration.moderator != nil {
            Settings.main.alternateInteractionBarLayoutForReports = true
        }
        
        self.post = .init(legacyItems: legacyConfiguration.post, moderator: false)
        self.comment = .init(legacyItems: legacyConfiguration.comment, moderator: false)
        self.reply = .init(legacyItems: legacyConfiguration.comment)
        self.postReport = .init(legacyItems: legacyConfiguration.moderator, moderator: true)
        self.commentReport = .init(legacyItems: legacyConfiguration.moderator, moderator: true)
    }
}

extension PostBarConfiguration {
    init(legacyItems: [LegacyInterationBarItem]?, moderator: Bool) {
        guard let legacyItems else {
            self = moderator ? .reportDefault_ : .default
            return
        }
        
        @AppStorage("showDownvotesSeparately") var showPostDownvotesSeparately: Bool = false
        @AppStorage("shouldShowScoreInPostBar") var shouldShowScoreInPostBar: Bool = false
        @AppStorage("shouldShowTimeInPostBar") var shouldShowTimeInPostBar: Bool = true
        @AppStorage("shouldShowSavedInPostBar") var shouldShowSavedInPostBar: Bool = false
        @AppStorage("shouldShowRepliesInPostBar") var shouldShowRepliesInPostBar: Bool = true
        
        guard legacyItems.count(where: { $0 == .infoStack }) == 1,
              let infoStackIndex = legacyItems.firstIndex(of: .infoStack) else {
            assertionFailure("Invalid legacy items")
            self = moderator ? .reportDefault_ : .default
            return
        }
        
        self.leading = legacyItems.prefix(upTo: infoStackIndex).compactMap { $0.postEquivalent() }
        self.trailing = legacyItems.suffix(from: infoStackIndex + 1).compactMap { $0.postEquivalent() }
        
        var newReadouts: [ReadoutType] = .init()
        if shouldShowTimeInPostBar { newReadouts.append(.created) }
        if shouldShowScoreInPostBar {
            if showPostDownvotesSeparately {
                newReadouts.append(contentsOf: [.upvote, .downvote])
            } else {
                newReadouts.append(.score)
            }
        }
        if shouldShowRepliesInPostBar { newReadouts.append(.comment) }
        if shouldShowSavedInPostBar { newReadouts.append(.saved) }
        self.readouts = newReadouts
        
        var newAvailableWidgets: Set<Item>
        if moderator {
            newAvailableWidgets = .init(ActionType.defaultReportWidgets.map { .action($0) })
        } else {
            newAvailableWidgets = .init(CounterType.defaultWidgets.map { .counter($0) } + ActionType.defaultWidgets.map { .action($0) })
        }
        newAvailableWidgets.formUnion(self.leading)
        newAvailableWidgets.formUnion(self.trailing)
        self.availableWidgets = newAvailableWidgets
    }
}

extension CommentBarConfiguration {
    init(legacyItems: [LegacyInterationBarItem]?, moderator: Bool) {
        guard let legacyItems else {
            self = moderator ? .reportDefault_ : .default
            return
        }
        
        @AppStorage("showCommentDownvotesSeparately") var showCommentDownvotesSeparately: Bool = false
        @AppStorage("shouldShowScoreInCommentBar") var shouldShowScoreInCommentBar: Bool = false
        @AppStorage("shouldShowTimeInCommentBar") var shouldShowTimeInCommentBar: Bool = true
        @AppStorage("shouldShowSavedInCommentBar") var shouldShowSavedInCommentBar: Bool = false
        @AppStorage("shouldShowRepliesInCommentBar") var shouldShowRepliesInCommentBar: Bool = true
        
        guard legacyItems.count(where: { $0 == .infoStack }) == 1,
              let infoStackIndex = legacyItems.firstIndex(of: .infoStack) else {
            assertionFailure("Invalid legacy items")
            self = moderator ? .reportDefault_ : .default
            return
        }
        
        self.leading = legacyItems.prefix(upTo: infoStackIndex).compactMap { $0.commentEquivalent() }
        self.trailing = legacyItems.suffix(from: infoStackIndex + 1).compactMap { $0.commentEquivalent() }
        
        var newReadouts: [ReadoutType] = .init()
        if shouldShowTimeInCommentBar { newReadouts.append(.created) }
        if shouldShowScoreInCommentBar {
            if showCommentDownvotesSeparately {
                newReadouts.append(contentsOf: [.upvote, .downvote])
            } else {
                newReadouts.append(.score)
            }
        }
        if shouldShowRepliesInCommentBar { newReadouts.append(.comment) }
        if shouldShowSavedInCommentBar { newReadouts.append(.saved) }
        self.readouts = newReadouts
        
        var newAvailableWidgets: Set<Item>
        if moderator {
            newAvailableWidgets = .init(ActionType.defaultReportWidgets.map { .action($0) })
        } else {
            newAvailableWidgets = .init(CounterType.defaultWidgets.map { .counter($0) } + ActionType.defaultWidgets.map { .action($0) })
        }
        newAvailableWidgets.formUnion(self.leading)
        newAvailableWidgets.formUnion(self.trailing)
        self.availableWidgets = newAvailableWidgets
    }
}

extension ReplyBarConfiguration {
    init(legacyItems: [LegacyInterationBarItem]?) {
        guard let legacyItems else {
            self = .default
            return
        }
        
        @AppStorage("showCommentDownvotesSeparately") var showCommentDownvotesSeparately: Bool = false
        @AppStorage("shouldShowScoreInCommentBar") var shouldShowScoreInCommentBar: Bool = false
        @AppStorage("shouldShowTimeInCommentBar") var shouldShowTimeInCommentBar: Bool = true
        @AppStorage("shouldShowSavedInCommentBar") var shouldShowSavedInCommentBar: Bool = false
        @AppStorage("shouldShowRepliesInCommentBar") var shouldShowRepliesInCommentBar: Bool = true
        
        guard legacyItems.count(where: { $0 == .infoStack }) == 1,
              let infoStackIndex = legacyItems.firstIndex(of: .infoStack) else {
            assertionFailure("Invalid legacy items")
            self = .default
            return
        }
        
        self.leading = legacyItems.prefix(upTo: infoStackIndex).compactMap { $0.replyEquivalent() }
        self.trailing = legacyItems.suffix(from: infoStackIndex + 1).compactMap { $0.replyEquivalent() }
        
        var newReadouts: [ReadoutType] = .init()
        if shouldShowTimeInCommentBar { newReadouts.append(.created) }
        if shouldShowScoreInCommentBar {
            if showCommentDownvotesSeparately {
                newReadouts.append(contentsOf: [.upvote, .downvote])
            } else {
                newReadouts.append(.score)
            }
        }
        if shouldShowRepliesInCommentBar { newReadouts.append(.comment) }
        if shouldShowSavedInCommentBar { newReadouts.append(.saved) }
        self.readouts = newReadouts
        
        var newAvailableWidgets: Set<Item> = .init(
            CounterType.defaultWidgets.map { .counter($0) } + ActionType.defaultWidgets.map { .action($0) }
        )
        newAvailableWidgets.formUnion(self.leading)
        newAvailableWidgets.formUnion(self.trailing)
        self.availableWidgets = newAvailableWidgets
    }
}
