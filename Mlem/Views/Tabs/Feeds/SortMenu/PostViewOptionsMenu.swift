//
//  PostSortOptions.swift
//  Mlem
//
//  Created by Sjmarf on 17/09/2023.
//

import SwiftUI

struct PostViewOptionsMenu: View {
    @AppStorage("postSize") var postSize: PostSize = .large
    @AppStorage("showReadPosts") var showReadPosts: Bool = true
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    
    @EnvironmentObject var pinnedViewOptions: PinnedViewOptionsTracker
    
    @State var showingSortMenu: Bool = false
    @Binding var postSortType: PostSortType
    
    var body: some View {
        Group {
            if pinnedViewOptions.pinned.isEmpty {
                Button {
                    showingSortMenu = true
                } label: {
                    Label(
                        "Selected sorting by \(postSortType.description)",
                        systemImage: postSortType.iconName
                    )
                }
            } else {
                Menu {
                    Picker("Sort mode", selection: $postSortType) {
                        ForEach(
                            pinnedViewOptions.pinned.sortTypes
                                .sorted(by: {
                                    PostSortType.outerTypes.firstIndex(of: $0)! < PostSortType.outerTypes.firstIndex(of: $1)!
                                }
                                       ), id: \.self) { type in
                                           Label(type.label, systemImage: type.iconName)
                                       }
                        let topTypes = pinnedViewOptions.pinned.topSortTypes.sorted(by: {
                            PostSortType.topTypes.firstIndex(of: $0)! < PostSortType.topTypes.firstIndex(of: $1)!
                        })
                        if pinnedViewOptions.pinned.topSortTypes.count >= 3
                            && (pinnedViewOptions.pinned.sortTypes.count
                                + pinnedViewOptions.pinned.topSortTypes.count >= 6) {
                            Menu {
                                Picker("Sort mode", selection: $postSortType) {
                                    ForEach(topTypes, id: \.self) { type in
                                        Label(type.switcherLabel, systemImage: type.iconName)
                                    }
                                }
                            } label: {
                                Label("Top...", systemImage: Icons.topSortMenu)
                            }
                        } else {
                            ForEach(topTypes, id: \.self) { type in
                                Label(type.label, systemImage: type.iconName)
                            }
                        }
                    }
                    Divider()
                    if pinnedViewOptions.pinned.options.contains(.postSize) {
                        Menu {
                            Picker("Post Size", selection: $postSize) {
                                ForEach(PostSize.allCases, id: \.self) { postSize in
                                    Label(postSize.label, systemImage: postSize.iconName)
                                }
                            }
                        } label: {
                            Label("Post Size", systemImage: Icons.postSizeSetting)
                        }
                    }
                    if pinnedViewOptions.pinned.options.contains(.blurNSFW) {
                        Toggle(isOn: $shouldBlurNsfw) {
                            Label("Blur NSFW", systemImage: "eye.trianglebadge.exclamationmark")
                            
                        }
                    }
                    if pinnedViewOptions.pinned.options.contains(.showRead) {
                        Toggle(isOn: $showReadPosts) {
                            Label("Show Read", systemImage: "book")
                        }
                    }
                    Divider()
                    Button {
                        showingSortMenu = true
                    } label: {
                        Label("Show All Options", systemImage: "line.horizontal.3.decrease.circle")
                    }
                } label: {
                    Label(
                        "Selected sorting by \(postSortType.description)",
                        systemImage: postSortType.iconName
                    )
                }
            }
        }
        .sheet(isPresented: $showingSortMenu) {
            PostSortView(
                isPresented: $showingSortMenu,
                selected: $postSortType,
                presentationDetent: .large,
                detents: [.large]
            )
        }
    }
}
