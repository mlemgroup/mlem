//
//  ModlogContextLinkView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-11.
//

import Foundation
import SwiftUI

struct ModlogContextLinkView: View {
    let context: ModlogContext
    
    var body: some View {
        switch context {
        case let .user(user):
            EasyTapLinkView(linkType: .userFromModel(0, UserModel(from: user)), showCaption: false)
        case let .post(post):
            EasyTapLinkView(linkType: .postFromApiType(0, post), showCaption: false)
//        case let .comment(community, post, comment):
//            EmbeddedPost(community: community, post: post, comment: comment)
        default:
            EmptyView()
            // Text("TODO")
        }
    }
}
