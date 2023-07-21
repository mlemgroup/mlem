//
//  Sidebar Header Avatar.swift
//  Mlem
//
//  Created by Jake Shirley on 6/21/23.
//

import Foundation

import SwiftUI
import CachedAsyncImage

struct CommunitySidebarHeaderAvatar: View {
    @State var shouldClipAvatar: Bool = false
    @State var imageUrl: URL?

    var body: some View {
        ZStack {
            if let avatarURL = imageUrl {
                CachedAsyncImage(url: avatarURL) { image in
                    if shouldClipAvatar {
                        image
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                            .overlay(Circle()
                            .stroke(.secondary, lineWidth: 2))
                    } else {
                        image
                            .resizable()
                            .scaledToFill()
                    }

                } placeholder: {
                    ProgressView()
                }
            } else {
                // TODO: Default avatar?
                // TIL you cannot fill and stroke at the same time
                Circle().strokeBorder(.background, lineWidth: 2)
                    .background(Circle().fill(.secondary))
            }
        }
        .frame(width: 120, height: 120)
        .shadow(radius: 10)
        .background(shouldClipAvatar ? Circle()
            .foregroundColor(.systemBackground) : nil)
    }
}
