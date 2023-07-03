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
import SwiftyGif

struct CachedImageWithNsfwFilter: View {
    
    let isNsfw: Bool
    let url: URL?
    let isGif: Bool
    
    @State var showNsfwFilterToggle: Bool
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    
    var showNsfwFilter: Bool { self.isNsfw ? shouldBlurNsfw && showNsfwFilterToggle : false }
    
    @State var isFullscreen: Bool
    
    init(isNsfw: Bool, url: URL?) {
        self.isNsfw = isNsfw
        self.url = url
        self.isGif = url?.absoluteString.contains([".gif"]) ?? false
        self._showNsfwFilterToggle = .init(initialValue: true)
        _isFullscreen = .init(initialValue: false)
    }
    
    @ViewBuilder
    var image: some View {
        Group {
            if let url = url, isGif {
                AnimatedGifView(url: url)
                    .scaledToFit()
                    .blur(radius: showNsfwFilter ? 30 : 0)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 1))
            } else {
                CachedAsyncImage(url: url, urlCache: AppConstants.urlCache) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .blur(radius: showNsfwFilter ? 30 : 0)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 1))
                } placeholder: {
                    ProgressView()
                }
            }
        }.onTapGesture {
            isFullscreen.toggle()
            offset_stale = CGSize()
            magnifyBy_stale = 1.0
        }
    }
    
    var fullScreen: some View {
        ZStack {
            Color.black
                .onTapGesture {
                    isFullscreen = false
                    offset_stale = CGSize()
                    magnifyBy_stale = 1.0
                }
            image
                .offset(isDragging ? offset : offset_stale)
                .scaleEffect(isZooming ? magnifyBy : magnifyBy_stale)
                .gesture(magnification)
        }
        .ignoresSafeArea()
    }
    
    var body: some View {
        ZStack {
            image
            
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
        }.fullScreenCover(isPresented: $isFullscreen) { fullScreen }
    }
    
    // MARK: - Gestures
    @State private var isZooming: Bool = false
    @GestureState private var magnifyBy = 1.0
    @State private var magnifyBy_stale = 1.0
    
    @State private var isDragging: Bool = false
    @GestureState private var offset = CGSize(width: 0, height: 0)
    @State private var offset_stale = CGSize(width: 0, height: 0)
    //    @GestureState private var
    
    var magnification: some Gesture {
        MagnificationGesture()
            .updating($magnifyBy) { value, gestureState, _ in
                isZooming = true
                gestureState = value
            }
            .onEnded { value in
                magnifyBy_stale = value
                isZooming = false
            }
            .simultaneously(with: drag)
    }
    
    var drag: some Gesture {
        DragGesture()
            .updating($offset) { value, gestureState, _ in
                self.isDragging = true
                let difX = value.location.x - value.startLocation.x
                let difY = value.location.y - value.startLocation.y
                gestureState = CGSize(
                    width: offset_stale.width + difX,
                    height: offset_stale.height + difY
                )
//                offset_stale = gestureState
            }
            .onEnded { value in
                isDragging = false
                let difX = value.location.x - value.startLocation.x
                let difY = value.location.y - value.startLocation.y
                offset_stale = CGSize(
                    width: offset_stale.width + difX,
                    height: offset_stale.height + difY
                )
                print(value.velocity.width)
                if difX > 4 && value.velocity.width > 500 {
                    isFullscreen = false
                }
            }
    }
}

struct AnimatedGifView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView(gifURL: self.url)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        uiView.setGifFromURL(self.url)
    }
}
