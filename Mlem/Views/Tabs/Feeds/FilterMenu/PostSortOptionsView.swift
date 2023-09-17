//
//  PostSortOptions.swift
//  Mlem
//
//  Created by Sjmarf on 17/09/2023.
//

import SwiftUI

struct PostSortOptionsView: View {
     @AppStorage("postSize") var postSize: PostSize = .large
    @AppStorage("showReadPosts") var showReadPosts: Bool = true
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    
    @State var showingSortMenu: Bool = false
    @Binding var postSortType: PostSortType
    
    var body: some View {
        Menu {
            Picker("Sort mode", selection: $postSortType) {
                let sortTypes: [PostSortType] = [.hot, .new]
                ForEach(sortTypes, id: \.self) { type in
                    Label(type.label, systemImage: type.iconName)
                }
                let topSortTypes: [PostSortType] = [.topDay, .topWeek, .topMonth, .topYear, .topAll]
                Menu {
                    Picker("Sort mode", selection: $postSortType) {
                        ForEach(topSortTypes, id: \.self) { type in
                            Label(type.label, systemImage: type.iconName)
                        }
                    }
                } label: {
                    Label("Top...", systemImage: AppConstants.topSymbolName)
                }
            }
            Divider()
            Menu {
                Picker("Post Size", selection: $postSize) {
                    ForEach(PostSize.allCases, id: \.self) { postSize in
                        Label(postSize.label, systemImage: postSize.iconName)
                    }
                }
            } label: {
                Label("Post Size", systemImage: AppConstants.postSizeSettingsSymbolName)
            }
            Toggle(isOn: $shouldBlurNsfw) {
                Label("Blur NSFW", systemImage: "eye.trianglebadge.exclamationmark")
                
            }
            Toggle(isOn: $showReadPosts) {
                Label("Show Read", systemImage: "book")
                
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
