//
//  UserLabelView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct UserLabelView: View {
    let avatar: URL?
    let username: String
    let instance: String
    
    init(person: (any Person1Providing)?) {
        self.avatar = person?.avatar
        // TODO: this PR get this from Person1Providing
        self.username = person?.name ?? "user"
        self.instance = person?.actorId.host() ?? "instance"
    }
    
    var body: some View {
        FullyQualifiedNameView(name: username, instance: instance)
    }
}
