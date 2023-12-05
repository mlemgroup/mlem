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
    case hobbit, cartoon
    
    var viewContent: EndOfFeedViewContent {
        switch self {
        case .hobbit:
            return EndOfFeedViewContent(icon: Icons.endOfFeedHobbit, message: "I think I've found the bottom!")
        case .cartoon:
            return EndOfFeedViewContent(icon: Icons.endOfFeedCartoon, message: "That's all, folks!")
        }
    }
}

struct EndOfFeedView: View {
    let loadingState: LoadingState
    let viewType: EndOfFeedViewType
    
    var body: some View {
        Group {
            switch loadingState {
            case .idle:
                EmptyView()
            case .loading:
                LoadingView(whatIsLoading: .posts)
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
