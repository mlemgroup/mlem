//
//  End Of Feed View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-22.
//

import Foundation
import SwiftUI

struct EndOfFeedViewContent {
    let icon: String
    let message: String
}

enum EndOfFeedViewType {
    case hobbit, cartoon, turtle
    
    var viewContent: EndOfFeedViewContent {
        switch self {
        case .hobbit:
            return EndOfFeedViewContent(icon: Icons.endOfFeedHobbit, message: "I think I've found the bottom!")
        case .cartoon:
            return EndOfFeedViewContent(icon: Icons.endOfFeedCartoon, message: "That's all, folks!")
        case .turtle:
            return EndOfFeedViewContent(icon: Icons.endOfFeedTurtle, message: "It's turtles all the way down")
        }
    }
}

struct EndOfFeedView: View {
    let loadingState: LoadingState
    let viewType: EndOfFeedViewType
    let whatIsLoading: LoadingView.PossibleThingsToLoad
    
    var body: some View {
        Group {
            switch loadingState {
            case .idle:
                EmptyView()
            case .loading:
                LoadingView(whatIsLoading: whatIsLoading)
            case .done:
                HStack {
                    Image(systemName: viewType.viewContent.icon)
                    
                    Text(viewType.viewContent.message)
                }
                .foregroundColor(.secondary)
            }
        }
        .frame(minHeight: 100)
    }
}
