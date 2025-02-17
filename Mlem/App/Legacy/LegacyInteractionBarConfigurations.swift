//
//  LegacyInteractionBarConfigurations.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-17.
//

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
        case .resolve: return nil
        case .remove: return .action(.remove)
        case .purge: return nil
        case .ban: return nil
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
        case .resolve: return nil
        case .remove: return .action(.remove)
        case .purge: return nil
        case .ban: return nil
        }
    }
}
