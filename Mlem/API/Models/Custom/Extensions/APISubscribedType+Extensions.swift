//
//  APISubscribedType+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension APISubscribedType {
    var isSubscribed: Bool { self != .notSubscribed }
}
