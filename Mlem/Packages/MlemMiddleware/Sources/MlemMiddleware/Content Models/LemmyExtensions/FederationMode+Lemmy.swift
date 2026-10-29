//
//  FederationMode+Lemmy.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-11-30.
//

import Foundation

extension VoteSettingsMode {
    init(from federationMode: LemmyVoteSettings) {
        self = switch federationMode {
        case .all: .all
        case .local: .local
        case .subscribed: .subscribed
        case .disable: .disable
        }
    }
}
