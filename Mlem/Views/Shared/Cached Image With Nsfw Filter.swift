//
//  MarkdownImageProvider.swift
//  Mlem
//
//  Created by tht7 on 26/06/2023.
//

import Foundation
import SwiftUI
import MarkdownUI
import NukeUI
import Nuke

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
        GeometryReader { proxy in
            let width = proxy.frame(in: .local).width
            let processors: [ImageProcessing] = [.resize(size: .init(width: width, height: 200))]

            LazyImage(url: url) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 400)
                        .frame(maxWidth: .infinity)
                        .blur(radius: showNsfwFilter ? 30 : 0)
                        .allowsHitTesting(false)
                        .overlay(nsfwOverlay)
                } else if state.error != nil {
                    // Indicates an error
                    Color.red
                        .frame(minWidth: 300, minHeight: 300)
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
                } else {
                    ProgressView() // Acts as a placeholder
                        .frame(minWidth: 300, minHeight: 300)
                }
            }
            .processors(processors)
            .fixedSize(horizontal: false, vertical: true)
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
