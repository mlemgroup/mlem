//
//  ApiMyUserInfo+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

extension ApiMyUserInfo: CacheIdentifiable {
    public var cacheId: Int { localUserView.person.id }
}
