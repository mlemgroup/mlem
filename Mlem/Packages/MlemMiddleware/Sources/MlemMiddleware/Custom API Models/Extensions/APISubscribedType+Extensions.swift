//
//  ApiSubscribedType+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

public extension ApiSubscribedType {
    var isSubscribed: Bool { self != .notSubscribed }
}
