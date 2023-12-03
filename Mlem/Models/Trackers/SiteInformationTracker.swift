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
    @Published private(set) var version: SiteVersion?
    
    func load(onLoaded: ((SiteVersion) -> Void)? = nil) {
        Task {
            let information = try await apiClient.loadSiteInformation()
            enableDownvotes = information.siteView.localSite.enableDownvotes
            version = SiteVersion(information.version)
            print("LOADED VERSION: \(version)")
            if let version, let onLoaded {
                print("CALLING onLoaded")
                onLoaded(version)
            }
        }
    }
}
