//
//  LoginVersionWarningView+Context.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-06.
//

import MlemMiddleware
import SwiftUI

extension LoginVersionWarningView {
    enum Content: Hashable {
        case resolvedInstance(Instance)
        case unresolvedInstance(host: String, software: SiteSoftware)

        var host: String {
            switch self {
            case let .resolvedInstance(instance): instance.host
            case let .unresolvedInstance(host: host, software: _): host
            }
        }

        var software: SiteSoftware? {
            switch self {
            case let .resolvedInstance(instance): instance.software.value
            case let .unresolvedInstance(host: _, software: software): software
            }
        }

        var instance: Instance? {
            switch self {
            case let .resolvedInstance(instance): instance
            case .unresolvedInstance: nil
            }
        }
    }
}
