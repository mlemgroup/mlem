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
    let isAdmin: Bool
    
    // Dates
    let creationDate: Date
    let updatedDate: Date?
    let banExpirationDate: Date?
    
    // URLs
    let profileUrl: URL
    let sharedInboxUrl: URL?
    
    // These values are nil if the UserModel was created from an APIPerson and not an APIPersonView
    var postCount: Int?
    var commentCount: Int?
    
    static let developerNames = [
        "https://lemmy.tespia.org/u/navi",
        "https://beehaw.org/u/jojo",
        "https://beehaw.org/u/kronusdark",
        "https://lemmy.ml/u/ericbandrews",
        "https://programming.dev/u/tht7",
        "https://sh.itjust.works/u/sjmarf"
    ]
    
    /// Creates a UserModel from an APIPersonView
    /// - Parameter apiPersonView: APIPersonView to create a UserModel representation of
    init(from personView: APIPersonView) {
        self.init(from: personView.person)
        self.postCount = personView.counts.postCount
        self.commentCount = personView.counts.commentCount
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
        self.isAdmin = person.admin ?? false // is nil on Beehaw
        
        self.creationDate = person.published
        self.updatedDate = person.updated
        self.banExpirationDate = person.banExpires
        
        self.instanceId = person.instanceId
        self.matrixUserId = person.matrixUserId
        
        self.profileUrl = person.actorId
        self.sharedInboxUrl = person.sharedInboxLink
    }
    
    // Once we've done other model types we should stop this from relying on API types
    func getFlairs(
        postContext: APIPost? = nil,
        commentContext: APIComment? = nil,
        communityContext: GetCommunityResponse? = nil
    ) -> [UserFlair] {
        var ret: [UserFlair] = .init()
        if let post = postContext, post.creatorId == self.userId {
            ret.append(.op)
        }
        if isAdmin {
            ret.append(.admin)
        }
        if UserModel.developerNames.contains(profileUrl.absoluteString) {
            ret.append(.developer)
        }
        if let comment = commentContext, comment.distinguished {
            ret.append(.moderator)
        } else if let community = communityContext, community.moderators.contains(where: { $0.moderator.id == userId }) {
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
    }
}
