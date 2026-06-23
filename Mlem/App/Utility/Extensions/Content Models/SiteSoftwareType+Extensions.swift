//
//  SiteSoftwareType+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-07-15.
//

import Foundation
import MlemMiddleware

extension SiteSoftwareType {
    var label: LocalizedStringResource {
        switch self {
        case .lemmy: "Lemmy"
        case .pieFed: "PieFed"
        }
    }

    var minimumSupportedVersion: SiteVersion {
        switch self {
        case .lemmy: .init("0.19.0")
        case .pieFed: .init("1.3.0")
        }
    }
}
