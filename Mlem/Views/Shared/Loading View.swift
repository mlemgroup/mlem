//
//  Loading View.swift
//  Mlem
//
//  Created by David Bureš on 01.04.2022.
//

import SwiftUI

struct LoadingView: View {
    enum PossibleThingsToLoad {
        case posts, image, comments, inbox, replies, mentions, messages, communityDetails, search, instances, instanceDetails
    }

    let whatIsLoading: PossibleThingsToLoad

    var body: some View {
        VStack(spacing: AppConstants.postAndCommentSpacing) {
            Spacer()

            ProgressView()
                .accessibilityHidden(true)
            switch whatIsLoading {
            case .posts:
                Text("Loading posts")
            case .image:
                Text("Loading image")
            case .comments:
                Text("Loading comments")
            case .inbox:
                Text("Loading inbox")
            case .replies:
                Text("Loading replies")
            case .mentions:
                Text("Loading mentions")
            case .messages:
                Text("Loading messages")
            case .communityDetails:
                Text("Loading community details")
            case .search:
                Text("Searching...")
            case .instances:
                Text("Loading instances")
            case .instanceDetails:
                Text("Loading instance details")
            }

            Spacer()
        }
        .accessibilityElement(children: .combine)
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity)
    }
}

struct LoadingViewPreview: PreviewProvider {
    static var previews: some View {
        LoadingView(whatIsLoading: .posts)
    }
}
