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
    let cornerRadius: CGFloat

    @State var showNsfwFilterToggle: Bool
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    var showNsfwFilter: Bool { self.isNsfw ? shouldBlurNsfw && showNsfwFilterToggle : false }

    init(isNsfw: Bool, url: URL?, cornerRadius: CGFloat = 0) {
        self.isNsfw = isNsfw
        self.url = url
        self.cornerRadius = cornerRadius
        
        self._showNsfwFilterToggle = .init(initialValue: true)
    }
    
    var body: some View {
        CachedAsyncImage(url: url, urlCache: AppConstants.urlCache) { image in
            image
                .resizable()
                .scaledToFit()
                .cornerRadius(cornerRadius)
                .blur(radius: showNsfwFilter ? 30 : 0)
                .allowsHitTesting(false)
                .overlay(nsfwOverlay)
        } placeholder: {
            ProgressView()
        }
    }
    
    @ViewBuilder
    var nsfwOverlay: some View {
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
            Image(systemName: "eye.slash")
                .padding(4)
                .background(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius)
                    .foregroundColor(.systemBackground))
                .onTapGesture {
                    showNsfwFilterToggle.toggle()
                }
                .padding(4)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}
