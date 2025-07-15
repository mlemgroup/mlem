//
//  SiteSoftwareType+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-07-15.
//

import Foundation
import MlemMiddleware

extension SiteSoftwareType {
    var minimumSupportedVersion: SiteVersion {
        switch self {
        case .lemmy: .init("0.19.0")
        case .pieFed: .init("1.0.0")
        }
    }
}
