//
//  Profile2Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-13.
//

import Foundation
import MlemMiddleware

extension Profile2Providing {
    var isCakeDay: Bool { created.isAnniversaryToday }
    
    var createdRecently: Bool {
        var intervalSinceCreation = Date.now.timeIntervalSince(created)
        return intervalSinceCreation < 30 * 24 * 60 * 60
    }
}
