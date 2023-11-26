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
    @Published var myUserInfo: APIMyUserInfo?
    
    func load() {
        Task {
            do {
                let information = try await apiClient.loadSiteInformation()
                enableDownvotes = information.siteView.localSite.enableDownvotes
                version = SiteVersion(information.version)
                myUserInfo = information.myUser
            } catch {
                errorHandler.handle(error)
            }
        }
    }
}
