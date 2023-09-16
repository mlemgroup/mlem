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
    
    @Published private(set) var enableDownvotes = true
    
    func load() {
        Task {
            let information = try await apiClient.loadSiteInformation()
            enableDownvotes = information.siteView.localSite.enableDownvotes
        }
    }
}
