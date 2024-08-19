//
//  EndOfFeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-19.
//

import Foundation
import MlemMiddleware
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
    @Environment(Palette.self) var palette
    
    let loadingState: LoadingState
    let viewType: EndOfFeedViewType
    
    var body: some View {
        Group {
            switch loadingState {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView()
            case .done:
                HStack {
                    Image(systemName: viewType.viewContent.icon)
                    
                    Text(viewType.viewContent.message)
                }
                .foregroundColor(palette.secondary)
            }
        }
        .frame(minHeight: 100)
    }
}
