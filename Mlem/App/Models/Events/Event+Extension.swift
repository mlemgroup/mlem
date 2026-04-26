//
//  Event+Extension.swift
//  Mlem
//
//  Created by Sjmarf on 2026-04-24.
//

import Foundation
import FediverseEvents

extension Event {
    var navigationUrl: URL? {
        if let social = self.social.first(where: { $0.icon == .lemmy }) {
            return social.url
        } else {
            return self.endpoints.open
        }
    }
}
