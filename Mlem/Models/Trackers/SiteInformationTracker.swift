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
    
    @Published private(set) var enableDownvotes = true
    @Published private(set) var version: SiteVersion?
    @Published private(set) var allLanguages: [APILanguage] = .init()
    @Published var myUserInfo: APIMyUserInfo?
    
    func load() {
        Task {
            do {
                let response = try await apiClient.loadSiteInformation()
                enableDownvotes = response.siteView.localSite.enableDownvotes
                version = SiteVersion(response.version)
                myUserInfo = response.myUser
                allLanguages = response.allLanguages
            } catch {
                errorHandler.handle(error)
            }
        }
    }
}
