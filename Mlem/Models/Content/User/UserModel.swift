//
//  UserModel.swift
//  Mlem
//
//  Created by Sjmarf on 23/09/2023.
//

import Dependencies
import Foundation
import SwiftUI

struct UserModel {
    @Dependency(\.personRepository) var personRepository
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.siteInformation) var siteInformation
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.notifier) var notifier
    
    @available(*, deprecated, message: "Use attributes of the UserModel directly instead.")
    var person: APIPerson
    
    // Ids
    let userId: Int
    let instanceId: Int
    let matrixUserId: String?
    
    // Text
    let name: String
    let displayName: String
    let bio: String?
    
    // Images
    let avatar: URL?
    let banner: URL?
    
    // State
    let banned: Bool
    let local: Bool
    let deleted: Bool
    let isBot: Bool
    var blocked: Bool

    // Dates
    let creationDate: Date
    let updatedDate: Date?
    let banExpirationDate: Date?
    
    // URLs
    let profileUrl: URL
    let sharedInboxUrl: URL?
    
    // From APIPersonView
    var isAdmin: Bool?
    var postCount: Int?
    var commentCount: Int?
    
    // From GetPersonDetailsResponse
    var moderatedCommunities: [CommunityModel]?
    
    static let developerNames = [
        "https://lemmy.tespia.org/u/navi",
        "https://beehaw.org/u/jojo",
        "https://beehaw.org/u/kronusdark",
        "https://lemmy.ml/u/ericbandrews",
        "https://programming.dev/u/tht7",
        "https://lemmy.ml/u/sjmarf"
    ]
    
    /// Creates a UserModel from an GetPersonDetailsResponse
    /// - Parameter response: GetPersonDetailsResponse to create a UserModel representation of
    init(from response: GetPersonDetailsResponse) {
        self.init(from: response.personView)
        self.moderatedCommunities = response.moderates.map { CommunityModel(from: $0.community) }
    }
    
    /// Creates a UserModel from an APIPersonView
    /// - Parameter apiPersonView: APIPersonView to create a UserModel representation of
    init(from personView: APIPersonView) {
        self.init(from: personView.person)
        
        self.postCount = personView.counts.postCount
        self.commentCount = personView.counts.commentCount
             
        // TODO: 0.18 Deprecation
        @Dependency(\.siteInformation) var siteInformation
        if (siteInformation.version ?? .infinity) > .init("0.19.0") {
            self.isAdmin = personView.isAdmin
        }
    }
    
    /// Creates a UserModel from an APIPerson. Note that using this initialiser nullifies count values, since
    /// those are only accessable from APIPersonView.
    /// - Parameter apiPerson: APIPerson to create a UserModel representation of
    init(from person: APIPerson) {
        self.person = person
        
        self.userId = person.id
        self.name = person.name
        self.displayName = person.displayName ?? person.name
        self.bio = person.bio
        
        self.avatar = person.avatarUrl
        self.banner = person.bannerUrl
        
        self.banned = person.banned
        self.local = person.local
        self.deleted = person.deleted
        self.isBot = person.botAccount
        
        self.isAdmin = person.admin
        
        self.creationDate = person.published
        self.updatedDate = person.updated
        self.banExpirationDate = person.banExpires
        
        self.instanceId = person.instanceId
        self.matrixUserId = person.matrixUserId
        
        self.profileUrl = person.actorId
        self.sharedInboxUrl = person.sharedInboxLink
        
        // Annoyingly, PersonView doesn't include whether the user is blocked so we can't
        // actually determine this without making extra requests...
        self.blocked = false
    }
    
    // Once we've done other model types we should stop this from relying on API types
    func getFlairs(
        postContext: APIPost? = nil,
        commentContext: APIComment? = nil,
        communityContext: CommunityModel? = nil
    ) -> [UserFlair] {
        var ret: [UserFlair] = .init()
        if let post = postContext, post.creatorId == self.userId {
            ret.append(.op)
        }
        if isAdmin ?? false {
            ret.append(.admin)
        }
        if UserModel.developerNames.contains(profileUrl.absoluteString) {
            ret.append(.developer)
        }
        if let comment = commentContext, comment.distinguished {
            ret.append(.moderator)
        } else if let community = communityContext,
                  let moderators = community.moderators,
                  moderators.contains(where: { $0.userId == userId }) {
            ret.append(.moderator)
        }
        if isBot {
            ret.append(.bot)
        }
        if banned {
            ret.append(.banned)
        }
        return ret
    }
    
    mutating func toggleBlock(_ callback: @escaping (_ item: Self) -> Void = { _ in }) async {
        blocked.toggle()
        RunLoop.main.perform { [self] in
            callback(self)
        }
        do {
            let response = try await personRepository.updateBlocked(for: userId, blocked: blocked)
            self.blocked = response.blocked
            RunLoop.main.perform { [self] in
                callback(self)
            }
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
        }
    }
    
    static func mock() -> UserModel {
        return self.init(from: APIPerson.mock())
    }
    
    var fullyQualifiedUsername: String? {
        if let host = self.profileUrl.host() {
            return "\(name)@\(host)"
        }
        return nil
    }
    
    func copyFullyQualifiedUsername() {
        let pasteboard = UIPasteboard.general
        if let fullyQualifiedUsername {
            pasteboard.string = "@\(fullyQualifiedUsername)"
            Task {
                await notifier.add(.success("Username Copied"))
            }
        } else {
            Task {
                await notifier.add(.failure("Failed to copy"))
            }
        }
    }
}

extension UserModel: Identifiable {
    var id: Int { hashValue }
}

extension UserModel: Hashable {
    static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    /// Hashes all fields for which state changes should trigger view updates.
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
        hasher.combine(blocked)
        hasher.combine(postCount)
        hasher.combine(commentCount)
    }
}
