//
//  SiteSoftware+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-06-14.
//

import Foundation
import MlemMiddleware

extension SiteSoftware {
    var label: String {
        "\(String(localized: type.label)) \(version)"
    }
}

extension SiteSoftwareType {
    var label: LocalizedStringResource {
        switch self {
        case .lemmy: "Lemmy"
        case .pieFed: "PieFed"
        }
    }
}
