//
//  PostFeedView+Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-21.
//

import Dependencies
import SwiftUI

extension PostFeedView {
    func setDefaultSortMode() async {
        if let siteVersion = siteInformation.version, versionSafePostSort == nil {
            let newPostSort = siteVersion < defaultPostSorting.minimumVersion ? fallbackDefaultPostSorting : defaultPostSorting
            
            // manually change the tracker sort type here so that view is not redrawn by `task(id: internalPostSortType)`
            await postTracker.changeSortType(to: newPostSort)
            postSortType = newPostSort
        }
    }
}
