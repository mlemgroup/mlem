//
//  SiteInformationTracker.swift
//  Mlem
//
//  Created by mormaer on 25/08/2023.
//
//

import Dependencies
import Foundation

class SiteInformationTracker: ObservableObject {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.accountsTracker) var accountsTracker
    @Dependency(\.markReadBatcher) var markReadBatcher
    @Dependency(\.personRepository) var personRepository
    
    @Published private(set) var instance: InstanceModel?
    @Published private(set) var enableDownvotes = true
    @Published var version: SiteVersion?
    @Published private(set) var allLanguages: [APILanguage] = .init()
    @Published var myUserInfo: APIMyUserInfo?
    @Published var myUser: UserModel?
    @Published var moderatedCommunities: Set<Int> = .init(minimumCapacity: 10)
    
    var userId: Int? { myUserInfo?.localUserView.person.id }
    
    func isMod(communityId: Int) -> Bool {
        moderatedCommunities.contains(communityId)
    }
    
    func isModOrAdmin(communityId: Int) -> Bool {
        isMod(communityId: communityId) || (myUser?.isAdmin ?? false)
    }
    
    var isAdmin: Bool {
        myUser?.isAdmin ?? false
    }
    
    func load(account: SavedAccount) {
        version = account.siteVersion
        Task {
            do {
                let response = try await apiClient.loadSiteInformation()
                instance = .init(from: response)
                enableDownvotes = response.siteView.localSite.enableDownvotes
                version = SiteVersion(response.version)
                let avatarUrl = response.myUser?.localUserView.person.avatarUrl
                if version != account.siteVersion || avatarUrl != account.avatarUrl {
                    DispatchQueue.main.async {
                        self.accountsTracker.update(with: .init(from: account, avatarUrl: avatarUrl, siteVersion: self.version))
                    }
                }
                myUserInfo = response.myUser
                allLanguages = response.allLanguages
                if let userInfo = response.myUser {
                    myUser = UserModel(from: userInfo.localUserView.person)
                    myUser?.isAdmin = response.admins.contains { $0.person.id == myUser?.userId }
                    
                    if let communities = response.myUser?.moderates {
                        moderatedCommunities = Set(communities.map(\.community.id))
                    } else {
                        moderatedCommunities = .init(minimumCapacity: 1)
                    }
                }
                
                if let version {
                    markReadBatcher.resolveSiteVersion(to: version)
                }
            } catch {
                errorHandler.handle(error)
            }
        }
    }
}
