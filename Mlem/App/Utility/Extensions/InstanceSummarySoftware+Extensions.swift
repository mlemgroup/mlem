//
//  InstanceSummarySoftware+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-03-27.
//

import MlemMiddleware
import MlemBackend

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
