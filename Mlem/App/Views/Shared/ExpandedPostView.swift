//
//  ExpandedPostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-12.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct ExpandedPostView: View {
    @Environment(\.dismiss) var dismiss
    
    let post: AnyPost
    
    var body: some View {
        ContentLoader(model: post) { post1 in
            content(for: post1)
        }
    }
    
    func content(for post: any Post1Providing) -> some View {
        FancyScrollView {
            VStack {
                Text(post.title)
                Text("Some content really far below to scroll to")
                    .padding([.top, .bottom], 700)
            }
        }
    }
}
