//
//  InstanceUptimeView+Logic..swift
//  Mlem
//
//  Created by Eric Andrews on 2025-05-08.
//

import Foundation
import MlemMiddleware

enum UptimeDataStatus {
    case success(UptimeData)
    case unavailable
    case failure(Error)
}

func loadUptimeData(instance: any Instance) async -> UptimeDataStatus {
    if let url = instance.uptimeDataUrl {
        do {
            let data = try await URLSession.shared.data(from: url).0
            let uptimeData = try JSONDecoder.defaultDecoder.decode(UptimeData.self, from: data)
            return .success(uptimeData)
        } catch {
            handleError(error)
            return .failure(error)
        }
    } else {
        return .unavailable
    }
}
