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
    
    @Published private(set) var enableDownvotes = true
    @Published var version: SiteVersion?
    @Published private(set) var allLanguages: [APILanguage] = .init()
    @Published var myUserInfo: APIMyUserInfo?
    @Published var myUser: UserModel?
    
    func load(account: SavedAccount) {
        version = account.siteVersion
        Task {
            do {
                let response = try await apiClient.loadSiteInformation()
                enableDownvotes = response.siteView.localSite.enableDownvotes
                version = SiteVersion(response.version)
                if version != account.siteVersion {
                    let avatarUrl = response.myUser?.localUserView.person.avatarUrl
                    DispatchQueue.main.async {
                        self.accountsTracker.update(with: .init(from: account, avatarUrl: avatarUrl, siteVersion: self.version))
                    }
                }
                myUserInfo = response.myUser
                allLanguages = response.allLanguages
                if let userInfo = response.myUser {
                    myUser = UserModel(from: userInfo.localUserView.person)
                    myUser?.isAdmin = response.admins.contains { $0.person.id == myUser?.userId }
                }
                
            } catch {
                errorHandler.handle(error)
            }
        }
    }
}
