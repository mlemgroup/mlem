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
    
    let post: any Post2Providing
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            content
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
    
    var content: some View {
        ScrollView {
            VStack {
                ScrollToView(appeared: $scrollToTopAppeared)
                    .id(scrollToTop)
                
                Text(post.title)
                
                Text("Some content really far below to scroll to")
                    .padding(.top, 700)
            }
        }
    }
}
