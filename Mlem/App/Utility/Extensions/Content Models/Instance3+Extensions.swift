//
//  Instance3+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-02.
//

import Foundation
import MlemBackend
import MlemMiddleware

extension Instance3 {
    var instanceSummary: InstanceSummary {
        .init(
            displayName: displayName,
            name: name,
            totalUsers: userCount,
            avatar: avatar,
            software: .init(from: software)
        )
    }
}

extension InstanceSummarySoftware {
    init(from software: SiteSoftware) {
        let type: InstanceSummarySoftwareType = switch software.type {
        case .lemmy: .lemmy
        case .pieFed: .pieFed
        }
        
        self.init(
            type: type,
            version: software.version.description
        )
    }
}
