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
    // This is a `LocalizedStringResource` because different languages
    // may want to change this icon in order to have it match the locale-specific idiom
    let icon: LocalizedStringResource
    let message: LocalizedStringResource
}

enum EndOfFeedViewType {
    case hobbit, cartoon, turtle
    
    var viewContent: EndOfFeedViewContent {
        switch self {
        case .hobbit:
            return EndOfFeedViewContent(
                icon: .init("end.of.feed.icon.1", defaultValue: .init(Icons.endOfFeedHobbit)),
                message: "I think I've found the bottom!"
            )
        case .cartoon:
            return EndOfFeedViewContent(
                icon: .init("end.of.feed.icon.2", defaultValue: .init(Icons.endOfFeedCartoon)),
                message: "That's all, folks!"
            )
        case .turtle:
            return EndOfFeedViewContent(
                icon: .init("end.of.feed.icon.3", defaultValue: .init(Icons.endOfFeedTurtle)),
                message: "It's turtles all the way down"
            )
        }
    }
}

struct EndOfFeedView: View {
    @Environment(Palette.self) var palette
    @Setting(\.developerMode) var developerMode
    
    let loadingState: LoadingState
    let loadMore: (() -> Void)?
    let viewType: EndOfFeedViewType
    
    var body: some View {
        Group {
            switch loadingState {
            case .idle:
                if let loadMore {
                    Button("Load More") {
                        loadMore()
                    }
                    .buttonStyle(.bordered)
                } else {
                    if developerMode {
                        Text(verbatim: "IDLE")
                    } else {
                        ProgressView()
                    }
                }
            case .loading:
                ProgressView()
            case .done:
                HStack {
                    Image(systemName: .init(localized: viewType.viewContent.icon))
                    Text(viewType.viewContent.message)
                }
                .foregroundColor(palette.secondary)
            }
        }
        .frame(minHeight: 100)
    }
}
