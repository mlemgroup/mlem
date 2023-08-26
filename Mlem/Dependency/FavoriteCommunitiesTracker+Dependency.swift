// 
//  FavoriteCommunitiesTracker+Dependency.swift
//  Mlem
//
//  Created by mormaer on 11/08/2023.
//  
//

import Dependencies
import Foundation

extension FavoriteCommunitiesTracker: DependencyKey {
      static let liveValue = FavoriteCommunitiesTracker()
    }

    extension DependencyValues {
      var favoriteCommunitiesTracker: FavoriteCommunitiesTracker {
        get { self[FavoriteCommunitiesTracker.self] }
        set { self[FavoriteCommunitiesTracker.self] = newValue }
      }
}
