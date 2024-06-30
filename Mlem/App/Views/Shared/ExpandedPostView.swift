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
        ContentLoader(model: post) { proxy in
            if let post = proxy.entity {
                content(for: post)
            }
        }
    }
    
    func content(for post: any Post1Providing) -> some View {
        FancyScrollView {
            LargePostView(post: post, isExpanded: true)
        }
    }
}
