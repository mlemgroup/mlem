//
//  PostFeedView+Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-21.
//

import Dependencies
import SwiftUI

extension PostFeedView {
    func setDefaultSortMode() {
        @Dependency(\.siteInformation) var siteInformationn
        
        @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
        @AppStorage("fallbackDefaultPostSorting") var fallbackDefaultPostSorting: PostSortType = .hot
        
        if let siteVersion = siteInformation.version, siteVersion < defaultPostSorting.minimumVersion {
            postSortType = fallbackDefaultPostSorting
        } else {
            postSortType = defaultPostSorting
        }
        
        if siteInformation.version != nil {
            siteVersionResolved = true
        }
    }
}
