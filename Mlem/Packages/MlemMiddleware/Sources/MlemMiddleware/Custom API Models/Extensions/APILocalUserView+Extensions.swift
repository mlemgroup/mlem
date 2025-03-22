//
//  ApiLocalUserView+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension ApiLocalUserView: Person2ApiBacker {
    public var admin: Bool {
        if let admin = localUser.admin ?? person.admin {
            return admin
        }
        assertionFailure()
        return false
    }
}
