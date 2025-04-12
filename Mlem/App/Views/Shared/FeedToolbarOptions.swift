//
//  FeedToolbarOptions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-16.
//

import SwiftUI

struct FeedToolbarOptions: ToolbarContent {
    @Environment(AppState.self) var appState
    
    @Setting(\.post_size) var postSize
    @Setting(\.feed_showRead) var showRead
    @Setting(\.safety_blurNsfw) var blurNsfw

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .secondaryAction) {
            SwiftUI.Section {
                Button(showRead ? "Hide Read" : "Show Read", systemImage: Icons.read) {
                    showRead.toggle()
                }
                
                Menu {
                    Picker("Post Size", selection: $postSize) {
                        ForEach(PostSize.allCases, id: \.self) { item in
                            Label(String(localized: item.label), icon: item.icon)
                        }
                    }
                } label: {
                    Label("Post Size", systemImage: Icons.postSizeSetting)
                }
                
                if appState.firstPerson?.showNsfw ?? false {
                    Toggle(
                        "Blur NSFW",
                        systemImage: Icons.blurNsfw,
                        isOn: .init(get: { blurNsfw != .never }, set: { blurNsfw = $0 ? .always : .never })
                    )
                }
            }
        }
    }
}
