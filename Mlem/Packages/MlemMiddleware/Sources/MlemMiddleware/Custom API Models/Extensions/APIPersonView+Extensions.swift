//
//  ApiPersonView+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension ApiPersonView: Person2ApiBacker {
    public var admin: Bool {
        guard let admin = self.isAdmin ?? self.person.admin else {
            assertionFailure("Could not determine admin status")
            return false
        }
        return admin
    }
}
