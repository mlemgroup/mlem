//
//  MarkdownImageProvider.swift
//  Mlem
//
//  Created by tht7 on 26/06/2023.
//

import Foundation
import SwiftUI
import MarkdownUI
import CachedAsyncImage

struct CachedImageWithNsfwFilter: View {

    let isNsfw: Bool
    let url: URL?

    @State var showNsfwFilterToggle: Bool
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    var showNsfwFilter: Bool { self.isNsfw ? shouldBlurNsfw && showNsfwFilterToggle : false }

    init(isNsfw: Bool, url: URL?) {
        self.isNsfw = isNsfw
        self.url = url
        self._showNsfwFilterToggle = .init(initialValue: true)
    }

    var body: some View {
        ZStack {
            CachedAsyncImage(url: url, urlCache: AppConstants.urlCache) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .blur(radius: showNsfwFilter ? 30 : 0)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 1))
            } placeholder: {
                ProgressView()
            }

            if showNsfwFilter {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                    Text("NSFW")
                        .fontWeight(.black)
                    Text("Tap to view")
                        .font(.callout)
                }
                .foregroundColor(.white)
                .padding(8)
                .onTapGesture {
                    showNsfwFilterToggle.toggle()
                }
            } else if isNsfw && shouldBlurNsfw {
                // stacks are here to align image to top left of ZStack
                // TODO: less janky way to do this?
                HStack {
                    VStack {
                        Image(systemName: "eye.slash")
                            .padding(4)
                            .frame(alignment: .topLeading)
                            .background(RoundedRectangle(cornerRadius: 4)
                                .foregroundColor(.systemBackground))
                            .onTapGesture {
                                showNsfwFilterToggle.toggle()
                            }
                            .padding(4)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
}
