//
//  CommunityDetailsView.swift
//  Mlem
//
//  Created by Sjmarf on 30/12/2023.
//

import SwiftUI

struct CommunityDetailsView: View {
    
    @Namespace var scrollToTop
    @State private var scrollToTopAppeared = false
    
    @Environment(\.navigationPathWithRoutes) private var navigationPath
    @Environment(\.scrollViewProxy) private var scrollViewProxy
    
    let community: CommunityModel
    
    var body: some View {
        ScrollView {
            ScrollToView(appeared: $scrollToTopAppeared)
                .id(scrollToTop)
            VStack(spacing: AppConstants.postAndCommentSpacing) {
                AvatarBannerView(community: community)
                    .padding(.horizontal, AppConstants.postAndCommentSpacing)
                    .padding(.top, 10)
                VStack(spacing: 5) {
                    Text(community.displayName)
                        .font(.title.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                    Text("@\(community.name)@\(community.communityUrl.host() ?? "unknown")")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                if let subscriberCount = community.subscriberCount {
                    VStack {
                        Text("\(subscriberCount) Subscribers")
                    }
                    
                }
            }
        }
        .hoistNavigation {
            if navigationPath.isEmpty {
                withAnimation {
                    scrollViewProxy?.scrollTo(scrollToTop)
                }
                return true
            } else {
                if scrollToTopAppeared {
                    return false
                } else {
                    withAnimation {
                        scrollViewProxy?.scrollTo(scrollToTop)
                    }
                    return true
                }
            }
        }
        .onAppear {

        }
    }
}
