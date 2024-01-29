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
    var person: APIPerson!
    
    // Ids
    var userId: Int!
    var instanceId: Int!
    var matrixUserId: String?
    
    // Text
    var name: String!
    var displayName: String!
    var bio: String?
    
    // Images
    var avatar: URL?
    var banner: URL?
    
    // State
    var banned: Bool!
    var local: Bool!
    var deleted: Bool!
    var isBot: Bool!
    var blocked: Bool!

    // Dates
    var creationDate: Date!
    var updatedDate: Date?
    var banExpirationDate: Date?
    
    // URLs
    var profileUrl: URL!
    var sharedInboxUrl: URL?
    
    // From APIPersonView
    var isAdmin: Bool?
    var postCount: Int?
    var commentCount: Int?
    
    // From GetPersonDetailsResponse
    var site: APISite?
    var moderatedCommunities: [CommunityModel]?
    
    static let developerNames = [
        "https://lemmy.tespia.org/u/navi",
        "https://beehaw.org/u/jojo",
        "https://beehaw.org/u/kronusdark",
        "https://lemmy.ml/u/ericbandrews",
        "https://programming.dev/u/tht7",
        "https://lemmy.ml/u/sjmarf"
    ]
    
    /// Is True when the UserModel was created using data fetched from an instance other than the logged-in instance
    var usesExternalData: Bool = false
    
    /// Creates a UserModel from an GetPersonDetailsResponse
    /// - Parameter response: GetPersonDetailsResponse to create a UserModel representation of
    init(from response: GetPersonDetailsResponse) {
        update(with: response)
    }
    
    /// Creates a UserModel from an APIPersonView
    /// - Parameter apiPersonView: APIPersonView to create a UserModel representation of
    init(from personView: APIPersonView) {
        update(with: personView)
    }
    
    /// Creates a UserModel from an APIPerson. Note that using this initialiser nullifies count values, since
    /// those are only accessable from APIPersonView.
    /// - Parameter apiPerson: APIPerson to create a UserModel representation of
    init(from person: APIPerson) {
        update(with: person)
    }
    
    mutating func update(with response: GetPersonDetailsResponse) {
        moderatedCommunities = response.moderates.map { CommunityModel(from: $0.community) }
        update(with: response.personView)
    }
    
    mutating func update(with personView: APIPersonView) {
        postCount = personView.counts.postCount
        commentCount = personView.counts.commentCount
             
        // TODO: 0.18 Deprecation
        @Dependency(\.siteInformation) var siteInformation
        if (siteInformation.version ?? .infinity) > .init("0.19.0") {
            isAdmin = personView.isAdmin
        }
        
        update(with: personView.person)
    }
    
    mutating func update(with person: APIPerson) {
        self.person = person
        
        userId = person.id
        name = person.name
        displayName = person.displayName ?? person.name
        bio = person.bio
        
        avatar = person.avatarUrl
        banner = person.bannerUrl
        
        banned = person.banned
        local = person.local
        deleted = person.deleted
        isBot = person.botAccount
        
        isAdmin = person.admin
        
        creationDate = person.published
        updatedDate = person.updated
        banExpirationDate = person.banExpires
        
        instanceId = person.instanceId
        matrixUserId = person.matrixUserId
        
        profileUrl = person.actorId
        sharedInboxUrl = person.sharedInboxLink
        
        // Annoyingly, PersonView doesn't include whether the user is blocked so we can't
        // actually determine this without making extra requests...
        if blocked == nil {
            blocked = false
        }
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
            blocked = response.blocked
            RunLoop.main.perform { [self] in
                callback(self)
            }
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
        }
    }
    
    static func mock() -> UserModel {
        self.init(from: APIPerson.mock())
    }
    
    var isActiveAccount: Bool {
        siteInformation.myUserInfo?.localUserView.person.id == userId
    }
    
    var fullyQualifiedUsername: String? {
        if let host = profileUrl.host() {
            return "\(name!)@\(host)"
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
        lhs.hashValue == rhs.hashValue
    }
    
    /// Hashes all fields for which state changes should trigger view updates.
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
        hasher.combine(blocked)
        hasher.combine(postCount)
        hasher.combine(commentCount)
        hasher.combine(displayName)
        hasher.combine(bio)
        hasher.combine(avatar)
        hasher.combine(banner)
        hasher.combine(matrixUserId)
    }
}
