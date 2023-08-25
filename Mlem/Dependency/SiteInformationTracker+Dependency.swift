//
//  SiteInformationTracker+Dependency.swift
//  Mlem
//
//  Created by mormaer on 25/08/2023.
//
//

import Dependencies

extension SiteInformationTracker: DependencyKey {
    static let liveValue = SiteInformationTracker()
}

extension DependencyValues {
    var siteInformation: SiteInformationTracker {
        get { self[SiteInformationTracker.self] }
        set { self[SiteInformationTracker.self] = newValue }
    }
}
