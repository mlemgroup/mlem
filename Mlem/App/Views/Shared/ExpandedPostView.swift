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
    @State private var post: (any Post2Providing)?
    
    @Namespace var scrollToTop
    
    let postStub: any PostStubProviding
    
    init(postStub: any PostStubProviding) {
        if let post = postStub as? any Post2Providing {
            self._post = .init(wrappedValue: post)
        }
        
        self.postStub = postStub
    }
    
    var body: some View {
        ScrollViewReader { _ in
            ContentLoader(model: post) { post2 in
                content(for: post2)
            } upgrade: {
                post = try await postStub.upgrade()
            }
        }
    }
    
    @ViewBuilder
    var contentLoader: some View {
        if let post {
            content(for: post)
        } else {
            Text("Loading...")
                .task {
                    do {
                        post = try await postStub.upgrade()
                    } catch {
                        print(error)
                    }
                }
        }
    }
    
    func content(for post: any Post2Providing) -> some View {
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
