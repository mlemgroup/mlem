//
//  InstanceModel.swift
//  Mlem
//
//  Created by Sjmarf on 13/01/2024.
//

import Dependencies
import SwiftUI

struct InstanceModel {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.notifier) var notifier
    
    enum InstanceError: Error {
        case invalidUrl
    }
    
    var displayName: String!
    var description: String?
    var avatar: URL?
    var banner: URL?
    var administrators: [UserModel]?
    var url: URL!
    var version: SiteVersion?
    var creationDate: Date?
    
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
    var slurFilterString: String?
    var captchaDifficulty: APICaptchaDifficulty?
    var registrationMode: APIRegistrationMode?
    var defaultFeedType: APIListingType?
    var hideModlogModNames: Bool?
    var applicationsEmailAdmins: Bool?
    var reportsEmailAdmins: Bool?
    
    // Not included in any API types; assumed to be false
    var blocked: Bool = false
    
    // This is included in APISite, but should ONLY be set when fetched from local instance
    var localSiteId: Int?
    
    init(domainName: String) throws {
        var components = URLComponents()
        components.scheme = "https"
        components.host = domainName
        if let url = components.url {
            self.url = url
            self.displayName = name
        } else {
            throw InstanceError.invalidUrl
        }
    }
    
    init(from response: SiteResponse) {
        update(with: response)
    }
    
    init(from siteView: APISiteView) {
        update(with: siteView)
    }
    
    init(from site: APISite, isLocal: Bool = false) {
        update(with: site)
        if isLocal {
            self.localSiteId = site.instanceId
        }
    }
    
    init(from stub: InstanceStub) {
        update(with: stub)
    }
    
    var name: String { url.host() ?? displayName }
    
    mutating func update(with response: SiteResponse) {
        administrators = response.admins.map {
            var user = UserModel(from: $0)
            user.usesExternalData = true
            user.isAdmin = true
            return user
        }
        version = SiteVersion(response.version)
        
        let localSite = response.siteView.localSite
        allowsDownvotes = localSite.enableDownvotes
        allowsNSFW = localSite.enableNsfw
        allowsCommunityCreation = !localSite.communityCreationAdminOnly
        requiresEmailVerification = localSite.requireEmailVerification
        captchaDifficulty = localSite.captchaEnabled ? localSite.captchaDifficulty : nil
        self.private = localSite.privateInstance
        federates = localSite.federationEnabled
        federationSignedFetch = localSite.federationSignedFetch
        defaultFeedType = localSite.defaultPostListingType
        hideModlogModNames = localSite.hideModlogModNames
        applicationsEmailAdmins = localSite.applicationEmailAdmins
        reportsEmailAdmins = localSite.reportsEmailAdmins

        registrationMode = localSite.registrationMode
        do {
            if let regex = localSite.slurFilterRegex {
                slurFilterString = regex
                slurFilterRegex = try .init(regex)
            }
        } catch {
            print("Invalid slur filter regex")
        }
        
        update(with: response.siteView)
    }
    
    mutating func update(with siteView: APISiteView) {
        userCount = siteView.counts.users
        communityCount = siteView.counts.communities
        postCount = siteView.counts.posts
        commentCount = siteView.counts.comments
        
        activeUserCount = .init(
            sixMonths: siteView.counts.usersActiveHalfYear,
            month: siteView.counts.usersActiveMonth,
            week: siteView.counts.usersActiveWeek,
            day: siteView.counts.usersActiveDay
        )
        
        update(with: siteView.site)
    }
    
    mutating func update(with site: APISite) {
        displayName = site.name
        description = site.sidebar
        avatar = site.iconUrl
        banner = site.bannerUrl
        creationDate = site.published
        
        if var components = URLComponents(string: site.inboxUrl) {
            components.path = ""
            url = components.url
        }
    }
    
    mutating func update(with stub: InstanceStub) {
        displayName = stub.name
        url = URL(string: "https://\(stub.host)")
        version = stub.version
        userCount = stub.userCount
        if let avatar = stub.avatar {
            self.avatar = URL(string: avatar)
        }
    }
    
    func firstSlurFilterMatch(_ input: String) -> String? {
        do {
            if let slurFilterRegex {
                if let output = try slurFilterRegex.firstMatch(in: input.lowercased()) {
                    return String(input[output.range])
                }
            }
        } catch {
            print("REGEX FAILED")
        }
        return nil
    }
    
    func toggleBlock(_ callback: @escaping (_ item: Self) -> Void = { _ in }) async {
        guard let localSiteId else { return }
        var new = self
        new.blocked = !blocked
        RunLoop.main.perform { [new] in
            callback(new)
        }
        do {
            let response: BlockInstanceResponse
            if !blocked {
                response = try await apiClient.blockSite(id: localSiteId, shouldBlock: true)
            } else {
                response = try await apiClient.blockSite(id: localSiteId, shouldBlock: false)
            }
            new.blocked = response.blocked
            RunLoop.main.perform { [new] in
                callback(new)
            }
            await notifier.add(.success(response.blocked ? "Blocked instance" : "Unblocked instance"))
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
            let phrase = !blocked ? "block" : "unblock"
            errorHandler.handle(
                .init(title: "Failed to \(phrase) instance", style: .toast, underlyingError: error)
            )
        }
    }
    
    static func mock() -> InstanceModel {
        .init(from: SiteResponse.mock())
    }
}

extension InstanceModel: Identifiable {
    var id: Int { hashValue }
}

extension InstanceModel: Hashable {
    static func == (lhs: InstanceModel, rhs: InstanceModel) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    /// Hashes all fields for which state changes should trigger view updates.
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(creationDate)
        hasher.combine(blocked)
    }
}
