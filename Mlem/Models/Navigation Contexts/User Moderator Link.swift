//
//  Moderator User Link.swift
//  Mlem
//
//  Created by Jake Shirley on 6/30/23.
//

import Foundation
import SwiftUI

struct UserModeratorLink: Equatable, Identifiable, Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    var id: Int { user.person.id }

    let user: APIPersonView
    let moderatedCommunities: [APICommunityModeratorView]
}
