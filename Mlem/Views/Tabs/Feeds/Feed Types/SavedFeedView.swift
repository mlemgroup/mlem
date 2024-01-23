//
//  SavedFeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-21.
//

import Dependencies
import Foundation
import SwiftUI

struct SavedFeedView: View {
    // TODO: ERIC this whole view needs its own PR--needs its own tracker to handle loading user content, needs a different type of feed to handle mixed posts and comments, and needs a good way of determining the current user ID
    
    @Dependency(\.siteInformation) var siteInformation
    @Dependency(\.errorHandler) var errorHandler
    
    // ugly little hack to deal with the fact that dependencies don't propagate state changes nicely but we need to listen for siteInformation.myUserInfo to resolve
    @State var siteInformationLoaded: Bool
    
    init() {
        @Dependency(\.siteInformation) var siteInformation
        
        _siteInformationLoaded = .init(wrappedValue: siteInformation.myUserInfo != nil)
    }
    
    var body: some View {
        // note to reviewers: this is super ugly but exists just to get the app in a stable running state pending the aforementioned PR to make this view nice
        if !siteInformationLoaded {
            LoadingView(whatIsLoading: .posts)
                .task {
                    for _ in 0 ..< 5 {
                        if siteInformation.myUserInfo != nil {
                            siteInformationLoaded = true
                            break
                        }
                        
                        do {
                            try await Task.sleep(nanoseconds: 1_000_000_000)
                        } catch {
                            errorHandler.handle(error)
                        }
                    }
                }
        } else {
            AggregateFeedView(feedType: .saved)
        }
    }
}
