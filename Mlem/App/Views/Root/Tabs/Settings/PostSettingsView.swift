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
    @Setting(\.thumbnailLocation) var thumbnailLocation
    @Setting(\.showPostCreator) var showCreator
    @Setting(\.showPersonAvatar) var showPersonAvatar
    @Setting(\.showCommunityAvatar) var showCommunityAvatar
    
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
            
            Toggle(isOn: $showPersonAvatar) {
                Text("Show User Avatar")
            }
            
            Toggle(isOn: $showCommunityAvatar) {
                Text("Show Community Avatar")
            }
        }
    }
}
