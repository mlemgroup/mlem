//
//  PostSettingsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-27.
//

import Foundation
import SwiftUI

// note: this is a very lazy categorization of "properties that affect posts"
struct PostSettingsView: View {
    @Setting(\.postSize) var postSize
    @AppStorage("post.thumbnailLocation") var thumbnailLocation: ThumbnailLocation = .left
    @AppStorage("post.showCreator") var showCreator: Bool = false
    @AppStorage("user.showAvatar") var showUserAvatar: Bool = true
    @AppStorage("community.showAvatar") var showCommunityAvatar: Bool = true
    
    var body: some View {
        Form {
            Picker("Post Size", selection: $postSize) {
                ForEach(PostSize.allCases, id: \.rawValue) { item in
                    Text(item.label).tag(item)
                }
            }
            
            Picker("Thumbnail Location", selection: $thumbnailLocation) {
                ForEach(ThumbnailLocation.allCases, id: \.rawValue) { item in
                    Text(item.label).tag(item)
                }
            }
            
            Toggle(isOn: $showCreator) {
                Text("Show Post Creator")
            }
            
            Toggle(isOn: $showUserAvatar) {
                Text("Show User Avatar")
            }
            
            Toggle(isOn: $showCommunityAvatar) {
                Text("Show Community Avatar")
            }
        }
    }
}
