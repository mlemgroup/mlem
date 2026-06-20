//
//  SiteSoftware+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-06-14.
//

import Foundation
import MlemBackend
import MlemMiddleware

extension SiteSoftware {
    init(from software: InstanceSummarySoftware) {
        let type: SiteSoftwareType = switch software.type {
        case .lemmy: .lemmy
        case .pieFed: .pieFed
        }
        
        let version: SiteVersion = .init(software.version)
        self.init(type: type, version: version)
    }
    
    var label: String {
        "\(String(localized: type.label)) \(version)"
    }

    var isSupported: Bool {
        version >= type.minimumSupportedVersion
    }
}
