//
//  InstanceModel.swift
//  Mlem
//
//  Created by Sjmarf on 13/01/2024.
//

import SwiftUI

struct InstanceModel {
    var instanceId: Int!
    var name: String!
    var description: String?
    var avatar: URL?
    var banner: URL?
    var administrators: [UserModel]?
    var url: URL!
    var version: SiteVersion?
    
    // From APISiteView
    var userCount: Int?
    var communityCount: Int?
    var postCount: Int?
    var commentCount: Int?
    var activeUserCount: ActiveUserCount?
    
    // From APILocalSite (only accessible via SiteResponse)
    var `private`: Bool?
    var federates: Bool?
    var federationSignedFetch: Bool?
    var allowsDownvotes: Bool?
    var allowsNSFW: Bool?
    var allowsCommunityCreation: Bool?
    var requiresEmailVerification: Bool?
    var slurFilterRegex: Regex<AnyRegexOutput>?
    var captchaDifficulty: APICaptchaDifficulty?
    var registrationMode: APIRegistrationMode?
    
    init(from response: SiteResponse) {
        self.update(with: response)
    }
    
    init(from siteView: APISiteView) {
        self.update(with: siteView)
    }
    
    init(from site: APISite) {
        self.update(with: site)
    }
    
    mutating func update(with response: SiteResponse) {
        self.administrators = response.admins.map {
            var user = UserModel(from: $0, usesExternalData: true)
            user.isAdmin = true
            return user
        }
        self.version = SiteVersion(response.version)
        
        let localSite = response.siteView.localSite
        self.allowsDownvotes = localSite.enableDownvotes
        self.allowsNSFW = localSite.enableNsfw
        self.allowsCommunityCreation = !localSite.communityCreationAdminOnly
        self.requiresEmailVerification = localSite.requireEmailVerification
        self.captchaDifficulty = localSite.captchaEnabled ? localSite.captchaDifficulty : nil
        self.private = localSite.privateInstance
        self.federates = localSite.federationEnabled
        self.federationSignedFetch = localSite.federationSignedFetch

        self.registrationMode = localSite.registrationMode
        do {
            if let regex = localSite.slurFilterRegex {
                self.slurFilterRegex = try .init(regex)
            }
        } catch {
            print("Invalid slur filter regex")
        }
        
        self.update(with: response.siteView)
    }
    
    mutating func update(with siteView: APISiteView) {
        userCount = siteView.counts.users
        communityCount = siteView.counts.communities
        postCount = siteView.counts.posts
        commentCount = siteView.counts.comments
        
        self.activeUserCount = .init(
            sixMonths: siteView.counts.usersActiveHalfYear,
            month: siteView.counts.usersActiveMonth,
            week: siteView.counts.usersActiveWeek,
            day: siteView.counts.usersActiveDay
        )
        
        self.update(with: siteView.site)
    }
    
    mutating func update(with site: APISite) {
        instanceId = site.id
        name = site.name
        description = site.sidebar
        avatar = site.iconUrl
        banner = site.bannerUrl
        
        if var components = URLComponents(string: site.inboxUrl) {
            components.path = ""
            url = components.url
        }
    }
}

extension InstanceModel: Identifiable {
    var id: Int { hashValue }
}

extension InstanceModel: Hashable {
    static func == (lhs: InstanceModel, rhs: InstanceModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    /// Hashes all fields for which state changes should trigger view updates.
    func hash(into hasher: inout Hasher) {
        hasher.combine(instanceId)
    }
}
