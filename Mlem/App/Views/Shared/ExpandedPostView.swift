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
    
    @State private var scrollToTopAppeared = false
    
    @Namespace var scrollToTop
    
    let post: AnyPost
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ContentLoader(model: post) { post1 in
                content(for: post1)
            }
            .onReselectTab {
                if scrollToTopAppeared {
                    dismiss()
                } else {
                    withAnimation {
                        scrollProxy.scrollTo(scrollToTop)
                    }
                }
            }
        }
    }
    
    func content(for post: any Post1Providing) -> some View {
        ScrollView {
            VStack {
                ScrollToView(appeared: $scrollToTopAppeared)
                    .id(scrollToTop)
                
                Text(post.title)
                
                Text("Some content really far below to scroll to")
                    .padding([.top, .bottom], 700)
            }
        }
    }
}
