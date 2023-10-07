//
//  UserModel.swift
//  Mlem
//
//  Created by Sjmarf on 23/09/2023.
//

import Dependencies
import Foundation
import SwiftUI

enum UserFlair {
    case admin
    case bot
    case banned
    case developer
    
    var color: Color {
        switch self {
        case .admin:
            return .pink
        case .bot:
            return .indigo
        case .banned:
            return .red
        case .developer:
            return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .admin:
            return Icons.adminFlair
        case .bot:
            return Icons.botFlair
        case .banned:
            return Icons.bannedFlair
        case .developer:
            return Icons.developerFlair
        }
    }
}

struct UserModel {
    let userId: Int
    var user: APIPerson
    var postCount: Int
    var commentCount: Int
    
    static private let developerNames = [
        "https://lemmy.tespia.org/u/navi",
        "https://beehaw.org/u/jojo",
        "https://beehaw.org/u/kronusdark",
        "https://lemmy.ml/u/ericbandrews",
        "https://programming.dev/u/tht7",
        "https://sh.itjust.works/u/sjmarf"
    ]
    
    /// Creates a UserModel from an APIPersonView
    /// - Parameter apiPersonView: APIPersonView to create a UserModel representation of
    init(from apiPersonView: APIPersonView) {
        self.userId = apiPersonView.person.id
        self.user = apiPersonView.person
        self.postCount = apiPersonView.counts.postCount
        self.commentCount = apiPersonView.counts.commentCount
    }
    
    // This is a function and not a computed property because in future it will
    // take in parameters for calculating flairs within specific contexts.
    func getFlair() -> UserFlair? {
        if user.admin ?? false {
            return .admin
        }
        if user.botAccount {
            return .bot
        }
        if user.banned {
            return .banned
        }
        if UserModel.developerNames.contains(user.actorId.absoluteString) {
            return .developer
        }
        return nil
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

extension UserModel: ContentModel {
    var uid: ContentModelIdentifier { .init(contentType: .user, contentId: userId) }
    
    var imageUrls: [URL] {
        if let url = user.avatarUrl {
            return [url.withIcon64Parameters]
        }
        return []
    }
    var searchResultScore: Int {
        let result = self.commentCount / 4 + self.postCount
        return Int(result)
    }
}
