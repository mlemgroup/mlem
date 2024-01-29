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
    @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
    
    @Dependency(\.siteInformation) var siteInformation
    @Dependency(\.errorHandler) var errorHandler
    
    // ugly little hack to deal with the fact that dependencies don't propagate state changes nicely but we need to listen for siteInformation.myUserInfo to resolve
    @State var userId: Int?
    
    @Binding var selectedFeed: FeedType?
    
    var body: some View {
        content
    }
    
    @ViewBuilder
    var content: some View {
        if let userId {
            UserContentFeedView(userId: userId, saved: true, selectedFeed: $selectedFeed)
        } else {
            // TODO: better site information loading state handling
            LoadingView(whatIsLoading: .posts)
                .task {
                    for _ in 0 ..< 5 {
                        if let resolvedId = siteInformation.myUserInfo?.localUserView.localUser.id {
                            userId = resolvedId
                            break
                        }
                        
                        do {
                            try await Task.sleep(nanoseconds: 1_000_000_000)
                        } catch {
                            errorHandler.handle(error)
                        }
                    }
                }
        }
    }
}
