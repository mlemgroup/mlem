//
//  MarkdownImageProvider.swift
//  Mlem
//
//  Created by tht7 on 26/06/2023.
//

import Foundation
import SwiftUI
import MarkdownUI
import SDWebImageSwiftUI

struct CachedImageWithNsfwFilter: View {
    let isNsfw: Bool
    let url: URL?
    @State var error: Bool = false

    @State var showNsfwFilterToggle: Bool
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    var showNsfwFilter: Bool { self.isNsfw ? shouldBlurNsfw && showNsfwFilterToggle : false }

    init(isNsfw: Bool, url: URL?) {
        self.isNsfw = isNsfw
        self.url = url
        self._showNsfwFilterToggle = .init(initialValue: true)
    }
    
    var body: some View {
        Group {
            if !error {
                AnimatedImage(url: url)
                    .placeholder { ProgressView() }
                    .onFailure { _ in error.toggle() }
                    .resizable()
                    .scaledToFill()
                    .blur(radius: showNsfwFilter ? 30 : 0)
                    .allowsHitTesting(false)
                    .overlay(nsfwOverlay)
            } else {
                self.defaultError
            }
        }
    }
    
    @ViewBuilder
    var defaultError: some View {
        Color.red
            .blur(radius: 30)
            .allowsHitTesting(false)
            .overlay(VStack {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                Text("Error")
                    .fontWeight(.black)
            }
            .foregroundColor(.white)
            .padding(8))
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
