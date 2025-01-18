//
//  PostThumbnailSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-18.
//  

import SwiftUI

struct PostThumbnailSettingsView: View {
    @Setting(\.thumbnailLocation) var thumbnailLocation
    
    var body: some View {
        Form {
            Toggle(
                "Show Thumbnails",
                isOn: .init(
                    get: { thumbnailLocation != .none },
                    set: { thumbnailLocation = $0 ? .left : .none }
                )
            )
        }
        .navigationTitle("Thumbnail")
    }
}
